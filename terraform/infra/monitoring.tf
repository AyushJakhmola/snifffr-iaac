resource "aws_sns_topic" "sns_topic" {
  name = format("%s-%s-sns-topic", local.environment, local.name)
}

resource "aws_sns_topic_subscription" "subscription" {
  protocol   = "email"
  endpoint   = "rachit.maheshwari@squareops.com"
  topic_arn  = aws_sns_topic.sns_topic.arn
  depends_on = [aws_sns_topic.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  period                    = 120
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  threshold                 = 80
  alarm_name                = format("%s-%s-cpu-alarm", local.environment, local.name)
  metric_name               = "CPUUtilization"
  alarm_actions             = ["${aws_sns_topic.sns_topic.arn}"]
  alarm_description         = "This metric monitors ec2 cpu utilization"
  evaluation_periods        = 2
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "mem" {
  period                    = 120
  namespace                 = "AWS/CWAgent"
  statistic                 = "Average"
  threshold                 = 70
  alarm_name                = format("%s-%s-asg-ec2-mem", local.environment, local.name)
  metric_name               = "mem_used_percent"
  alarm_actions             = ["${aws_sns_topic.sns_topic.arn}", aws_autoscaling_policy.mem.arn]
  actions_enabled           = true
  alarm_description         = "This metric monitors memory of ec2"
  evaluation_periods        = 2
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  period                    = 120
  namespace                 = "AWS/CWAgent"
  statistic                 = "Average"
  threshold                 = 50
  alarm_name                = format("%s-%s-asg-ec2-disk", local.environment, local.name)
  metric_name               = "disk_used_percent"
  alarm_actions             = ["${aws_sns_topic.sns_topic.arn}", aws_autoscaling_policy.mem.arn]
  actions_enabled           = true
  alarm_description         = "This metric monitors disk of ec2"
  evaluation_periods        = 2
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_health" {
  period                    = 120
  namespace                 = "AWS/AutoScaling"
  statistic                 = "Average"
  threshold                 = 1
  alarm_name                = format("%s-%s-asg-ec2-health", local.environment, local.name)
  metric_name               = "GroupTotalInstances"
  alarm_actions             = ["${aws_sns_topic.sns_topic.arn}", aws_autoscaling_policy.mem.arn]
  actions_enabled           = true
  alarm_description         = "This metric monitors healthy ec2"
  evaluation_periods        = 2
  comparison_operator       = "LessThanOrEqualToThreshold"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = module.asg.autoscaling_group_name
  }
}







