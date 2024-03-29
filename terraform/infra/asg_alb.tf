# S3 Bucket to keep the Artifacts
data "aws_caller_identity" "current" {}

module "alb_s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  bucket        = format("%s-%s-alb-logs-bucket", local.environment, local.name)
  force_destroy = true
  control_object_ownership = true
  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]
  access_log_delivery_policy_source_buckets  = ["arn:aws:s3:::${format("%s-%s-alb-logs-bucket", local.environment, local.name)}"]
}

resource "aws_iam_role" "bucket_logs" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::797873946194:root"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "logs_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.bucket_logs.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${format("%s-%s-alb-logs-bucket", local.environment, local.name)}",
    ]
  }
}

# key pair to connect with appliction server
module "key_pair" {
  source             = "squareops/keypair/aws"
  key_name           = format("%s-%s-key", local.environment, local.name)
  environment        = local.environment
  ssm_parameter_path = format("%s-%s-key", local.environment, local.name)
}

# security group for the application server
module "app_sg" {
  name       = format("%s-%s-app-sg", local.environment, local.name)
  source     = "terraform-aws-modules/security-group/aws"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
  ingress_with_source_security_group_id = [
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.alb.security_group_id
    },
    {
      to_port                  = 0
      from_port                = 0
      protocol                 = "-1"
      source_security_group_id = module.vpc.vpn_security_group
    },
  ]

  egress_with_cidr_blocks = [
    {
      to_port     = 0
      from_port   = 0
      protocol    = "-1"
      description = "outbound rule"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# security group for the  background server application 

module "back_app_sg" {
  name       = format("%s-%s-background-app-sg", local.environment, local.name)
  source     = "terraform-aws-modules/security-group/aws"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
  ingress_with_source_security_group_id = [
    {
      to_port                  = 0
      from_port                = 0
      protocol                 = "-1"
      source_security_group_id = module.vpc.vpn_security_group
    },
  ]

  egress_with_cidr_blocks = [
    {
      to_port     = 0
      from_port   = 0
      protocol    = "-1"
      description = "outbound rule"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# applicaion load balancer
module "alb" {
  name                  = format("%s-%s-alb", local.environment, local.name)
  source                = "terraform-aws-modules/alb/aws"
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.public_subnets
  depends_on            = [module.vpc]
  idle_timeout          = var.app_alb_configuration.idle_timeout
  create_security_group = true
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
  access_logs = {
    bucket = module.alb_s3_bucket.s3_bucket_id
    prefix = "access-logs"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# target group for alb
resource "aws_lb_target_group" "app_tg" {
  name     = format("%s-%s-tg", local.environment, local.name)
  port     = var.health_check_parameters.port
  vpc_id   = module.vpc.vpc_id
  protocol = var.health_check_parameters.protocol
  load_balancing_algorithm_type = "least_outstanding_requests"
  deregistration_delay = var.app_alb_configuration.deregistration_delay

  health_check {
    path     = var.health_check_parameters.path
    matcher  = var.health_check_parameters.success_code
    timeout = var.health_check_parameters.timeout
    interval = var.health_check_parameters.interval
    protocol = var.health_check_parameters.protocol
    healthy_threshold = var.health_check_parameters.healthy_threshold
    unhealthy_threshold = var.health_check_parameters.unhealthy_threshold
  }

  stickiness {
    type = "lb_cookie"
    enabled = true
    cookie_duration = 300
  }
  
}

# asg and launch Template for application server
module "asg" {
  name                = format("%s-%s-asg", local.environment, local.name)
  source              = "terraform-aws-modules/autoscaling/aws"
  min_size            = var.app_server_configuration.min_size
  max_size            = var.app_server_configuration.max_size
  key_name            = module.key_pair.key_pair_name
  user_data           = base64encode(file("${path.module}/script.sh"))
  depends_on          = [module.alb]
  enabled_metrics     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  desired_capacity    = var.app_server_configuration.desired_capacity
  health_check_type   = "EC2"
  vpc_zone_identifier = module.vpc.private_subnets

  # Launch template
  image_id               = var.app_server_configuration.image_id
  instance_type          = var.app_server_configuration.instance_type
  enable_monitoring      = true
  target_group_arns      = [aws_lb_target_group.app_tg.arn]
  launch_template_name   = format("%s-%s-launch-template", local.environment, local.name)
  update_default_version = true
  health_check_grace_period = var.app_server_configuration.health_check_grace_period

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = format("%s-%s-app-role", local.environment, local.name)
  iam_role_policies = {
    # AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMFullAccess          = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
    AmazonS3ReadOnlyAccess       = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    SecretsManagerReadWrite      = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    AmazonRDSReadOnlyAccess      = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
    CloudWatchAgentAdminPolicy   = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
    AmazonElastiCacheFullAccess  = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    AmazonElastiCacheFullAccess  = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/sda1"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.app_server_configuration.volume_size
        volume_type           = var.app_server_configuration.volume_type
      } 
    }
  ]

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.app_sg.security_group_id]
    }
  ]

  placement = {
    availability_zone = "${local.region}a"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = local.additional_tags
    },
    {
      resource_type = "volume"
      tags          = local.additional_tags
    }
  ]
  tags = local.additional_tags
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = format("%s-%s-cpu-scaling", local.environment, local.name)
  cooldown               = "120"
  depends_on             = [module.asg]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.asg.autoscaling_group_name
}

resource "aws_autoscaling_policy" "mem" {
  name                   = format("%s-%s-mem-scaling", local.environment, local.name)
  cooldown               = "120"
  depends_on             = [module.asg]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.asg.autoscaling_group_name
}

resource "aws_autoscaling_policy" "disk" {
  name                   = format("%s-%s-disk-scaling", local.environment, local.name)
  cooldown               = "120"
  depends_on             = [module.asg]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.asg.autoscaling_group_name
}

#################
resource "aws_autoscaling_policy" "cpu_down" {
  name                   = format("%s-%s-cpu-scale-down", local.environment, local.name)
  cooldown               = "120"
  depends_on             = [module.asg]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  autoscaling_group_name = module.asg.autoscaling_group_name
}

# resource "aws_autoscaling_policy" "mem_down" {
#   name                   = format("%s-%s-mem-scale-down", local.environment, local.name)
#   cooldown               = "120"
#   depends_on             = [module.asg]
#   policy_type            = "SimpleScaling"
#   adjustment_type        = "ChangeInCapacity"
#   scaling_adjustment     = "-1"
#   autoscaling_group_name = module.asg.autoscaling_group_name
# }

# resource "aws_autoscaling_policy" "disk_down" {
#   name                   = format("%s-%s-disk-scale-down", local.environment, local.name)
#   cooldown               = "120"
#   depends_on             = [module.asg]
#   policy_type            = "SimpleScaling"
#   adjustment_type        = "ChangeInCapacity"
#   scaling_adjustment     = "-1"
#   autoscaling_group_name = module.asg.autoscaling_group_name
# }
#################

# asg and launch Template for backend server
# create seperate sg 
module "back_asg" {
  name                = format("%s-%s-background-asg", local.environment, local.name)
  source              = "terraform-aws-modules/autoscaling/aws"
  min_size            = var.bakend_server_configurations.min_size
  max_size            = var.bakend_server_configurations.max_size
  key_name            = module.key_pair.key_pair_name
  user_data           = base64encode(file("${path.module}/background_user_data.sh"))
  depends_on          = [module.back_app_sg]
  enabled_metrics     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  desired_capacity    = var.bakend_server_configurations.desired_capacity
  health_check_type   = "EC2"
  vpc_zone_identifier = module.vpc.public_subnets

  scaling_policies = {
    cpu_utilization_policy = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70.0
      }
    }
  }

  # Launch template
  image_id               = var.bakend_server_configurations.image_id
  instance_type          = var.bakend_server_configurations.instance_type
  enable_monitoring      = true
  launch_template_name   = format("%s-%s-background-launch-template", local.environment, local.name)
  update_default_version = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = format("%s-%s-backend-app-role", local.environment, local.name)
  iam_role_policies = {
    # AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMFullAccess          = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
    AmazonS3ReadOnlyAccess       = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    SecretsManagerReadWrite      = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    AmazonRDSReadOnlyAccess      = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
    CloudWatchAgentAdminPolicy   = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      no_device   = 0
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.bakend_server_configurations.volume_size
        volume_type           = var.bakend_server_configurations.volume_type
      }
    }
  ]

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.back_app_sg.security_group_id]
    }
  ]

  placement = {
    availability_zone = "${local.region}a"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = local.additional_tags
    },
    {
      resource_type = "volume"
      tags          = local.additional_tags
    }
  ]
  tags = local.additional_tags
}

# not required for now 
resource "aws_autoscaling_policy" "back_mem" {
  name                   = format("%s-%s-mem-scaling", local.environment, local.name)
  cooldown               = "300"
  depends_on             = [module.back_asg]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.back_asg.autoscaling_group_name
}

resource "aws_autoscaling_policy" "back_disk" {
  name                   = format("%s-%s-disk-scaling", local.environment, local.name)
  cooldown               = "300"
  depends_on             = [module.back_asg]
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.back_asg.autoscaling_group_name
}



 