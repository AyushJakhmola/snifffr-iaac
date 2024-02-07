resource "aws_sns_topic" "sns_topic" {
  name = format("%s-%s-sns-topic", local.environment, local.name)
}

resource "aws_sns_topic_subscription" "subscription" {
  protocol   = "email"
  endpoint   = var.monitor_config.email
  topic_arn  = aws_sns_topic.sns_topic.arn
  depends_on = [aws_sns_topic.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  period                    = 30
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  threshold                 = var.monitor_config.cpu_threshold
  alarm_name                = format("%s-%s-cpu-alarm", local.environment, local.name)
  metric_name               = "CPUUtilization"
  alarm_actions             = [aws_sns_topic.sns_topic.arn, aws_autoscaling_policy.cpu.arn]
  alarm_description         = "This metric monitors ec2 cpu utilization"
  evaluation_periods        = 1
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "mem" {
  period                    = 30
  namespace                 = "CWAgent"
  statistic                 = "Average"
  threshold                 = var.monitor_config.mem_threshold
  alarm_name                = format("%s-%s-mem-alarm", local.environment, local.name)
  metric_name               = "mem_used_percent"
  alarm_actions             = [aws_sns_topic.sns_topic.arn, aws_autoscaling_policy.mem.arn]
  actions_enabled           = true
  alarm_description         = "This metric monitors memory of ec2"
  evaluation_periods        = 1
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  period                    = 30
  namespace                 = "CWAgent"
  statistic                 = "Average"
  threshold                 = var.monitor_config.disk_threshold
  alarm_name                = format("%s-%s-disk-alarm", local.environment, local.name)
  metric_name               = "disk_used_percent"
  alarm_actions             = [aws_sns_topic.sns_topic.arn, aws_autoscaling_policy.disk.arn]
  actions_enabled           = true
  alarm_description         = "This metric monitors disk of ec2"
  evaluation_periods        = 1
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_health" {
  period                    = 30
  namespace                 = "AWS/AutoScaling"
  statistic                 = "Average"
  threshold                 = 1
  alarm_name                = format("%s-%s-asg-ec2-health", local.environment, local.name)
  metric_name               = "GroupTotalInstances"
  alarm_actions             = [aws_sns_topic.sns_topic.arn]
  actions_enabled           = true
  alarm_description         = "This metric monitors healthy ec2"
  evaluation_periods        = 2
  comparison_operator       = "LessThanThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_down" {
  period                    = 60
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  threshold                 = 30
  alarm_name                = format("%s-%s-cpu-down-alarm", local.environment, local.name)
  metric_name               = "CPUUtilization"
  alarm_actions             = [aws_sns_topic.sns_topic.arn, aws_autoscaling_policy.cpu_down.arn]
  alarm_description         = "This metric monitors ec2 cpu utilization"
  evaluation_periods        = 2
  comparison_operator       = "LessThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

# resource "aws_cloudwatch_metric_alarm" "mem_down" {
#   period                    = 60
#   namespace                 = "CWAgent"
#   statistic                 = "Average"
#   threshold                 = 20
#   alarm_name                = format("%s-%s-mem-down-alarm", local.environment, local.name)
#   metric_name               = "mem_used_percent"
#   alarm_actions             = [aws_sns_topic.sns_topic.arn, aws_autoscaling_policy.mem_down.arn]
#   actions_enabled           = true
#   alarm_description         = "This metric monitors memory of ec2"
#   evaluation_periods        = 2
#   comparison_operator       = "LessThanOrEqualToThreshold"
#   insufficient_data_actions = []
#   dimensions = {
#     AutoScalingGroupName = module.asg.autoscaling_group_name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "disk_down" {
#   period                    = 60
#   namespace                 = "AWS/CWAgent"
#   statistic                 = "Average"
#   threshold                 = 40
#   alarm_name                = format("%s-%s-disk-down-alarm", local.environment, local.name)
#   metric_name               = "disk_used_percent"
#   alarm_actions             = [aws_sns_topic.sns_topic.arn, aws_autoscaling_policy.disk_down.arn]
#   actions_enabled           = true
#   alarm_description         = "This metric monitors disk of ec2"
#   evaluation_periods        = 1
#   comparison_operator       = "LessThanOrEqualToThreshold"
#   insufficient_data_actions = []
#   dimensions = {
#     AutoScalingGroupName = module.asg.autoscaling_group_name
#   }
# }


resource "aws_route53_health_check" "site_url" {
  fqdn              = "${local.environment}.snifffr.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  measure_latency = true
  request_interval  = "10"
  failure_threshold = "2"
}

resource "aws_cloudwatch_metric_alarm" "site_health_sns" {
  period                    = 30
  namespace                 = "AWS/Route53"
  statistic                 = "Average"
  threshold                 = 1
  alarm_name                = format("%s-%s-health-check-alarm", local.environment, local.name)
  metric_name               = "HealthCheckStatus"
  alarm_actions             = [aws_sns_topic.sns_topic.arn]
  alarm_description         = "This metric monitors Health check and notify if unhealthy"
  evaluation_periods        = 1
  comparison_operator       = "LessThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    HealthCheckId           = "${aws_route53_health_check.site_url.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "db_connection" {
  period                    = 30
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  threshold                 = var.monitor_config.db_connection_threshold
  alarm_name                = format("%s-%s-db-alarm", local.environment, local.name)
  metric_name               = "DatabaseConnections"
  alarm_actions             = [aws_sns_topic.sns_topic.arn]
  alarm_description         = "This metric monitors RDS DB connections"
  evaluation_periods        = 1
  comparison_operator       = "LessThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_4XX_target_error" {
  period                    = 30
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Average"
  threshold                 = 3
  alarm_name                = format("%s-%s-alb-4xx-target-alarm", local.environment, local.name)
  metric_name               = "HTTPCode_Target_4XX_Count"
  alarm_actions             = [aws_sns_topic.sns_topic.arn]
  alarm_description         = "This metric monitors ALB 4XX counts"
  evaluation_periods        = 3
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    LoadBalancer = module.alb.arn_suffix
}
}

resource "aws_cloudwatch_metric_alarm" "elb_5XX_target_error" {
  period                    = 30
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Average"
  threshold                 = 3
  alarm_name                = format("%s-%s-alb-5xx-alarm", local.environment, local.name)
  metric_name               = "HTTPCode_Target_5XX_Count"
  alarm_actions             = [aws_sns_topic.sns_topic.arn]
  alarm_description         = "This metric monitors ALB 5XX counts"
  evaluation_periods        = 3
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    LoadBalancer = module.alb.arn_suffix
}
}