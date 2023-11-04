# security group for the application 
module "app_sg" {
  name                = format("%s-%s-sg", local.environment, local.name)
  source              = "terraform-aws-modules/security-group/aws"
  vpc_id              = module.vpc.vpc_id
  ingress_rules       = ["https-443-tcp"]
  ingress_cidr_blocks = ["10.10.0.0/16"]
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

# key pair to connect with appliction server
module "key_pair" {
  source             = "squareops/keypair/aws"
  key_name           = format("%s-%s-key", local.environment, local.name)
  environment        = local.environment
  ssm_parameter_path = format("%s-%s-key", local.environment, local.name)
}

# applicaion load balancer
module "alb" {
  name                  = format("%s-%s-alb", local.environment, local.name)
  source                = "terraform-aws-modules/alb/aws"
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.public_subnets
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
}
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-west-2:678109907733:certificate/1acc7ec6-ac55-48b5-b3dd-e1f7c44364f9"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# target group for alb
resource "aws_lb_target_group" "app_tg" {
  name = format("%s-%s-tg", local.environment, local.name)
  port = var.health_check_parameters.port
  health_check {
    path = var.health_check_parameters.path
  }
  protocol = var.health_check_parameters.protocol
  vpc_id   = module.vpc.vpc_id
}

# asg and launch Template
module "asg" {
  name   = format("%s-%s-asg", local.environment, local.name)
  source = "terraform-aws-modules/autoscaling/aws"
  # key_name            = module.key_pair.key_pair_name
  depends_on          = [module.alb]
  user_data           = base64encode(file("${path.module}/script.sh"))
  min_size            = var.server_configurations.min_size
  max_size            = var.server_configurations.max_size
  desired_capacity    = var.server_configurations.desired_capacity
  enabled_metrics     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
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
  launch_template_name   = format("%s-%s-launch-template", local.environment, local.name)
  update_default_version = true

  image_id          = var.server_configurations.image_id
  instance_type     = var.server_configurations.instance_type
  enable_monitoring = true
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = format("%s-%s-template", local.environment, local.name)
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonS3ReadOnlyAccess       = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    AmazonSSMFullAccess          = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
    CloudWatchAgentAdminPolicy   = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 100
        volume_type           = "gp2"
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
    availability_zone = "us-west-1b"
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

resource "aws_autoscaling_policy" "mem" {
  name                   = format("%s-%s-mem-scaling", local.environment, local.name)
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.asg.autoscaling_group_name
}

resource "aws_autoscaling_policy" "disk" {
  name                   = format("%s-%s-disk-scaling", local.environment, local.name)
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "1"
  autoscaling_group_name = module.asg.autoscaling_group_name
}
