resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = format("%s-%s-dashboard", local.environment, local.name)
  dashboard_body = jsonencode({
    "widgets" : [
      {
        "height" : 6,
        "width" : 6,
        "y" : 0,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "legend" : {
            "position" : "bottom"
          },
          "liveData" : false,
          "metrics" : [
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "${module.asg.autoscaling_group_name}", { "period" : 300, "stat" : "Average" }]
          ],
          "region" : "${local.region}",
          "stacked" : false,
          "timezone" : "UTC",
          "title" : "GroupInServiceInstances: Average",
          "view" : "timeSeries"
        }
      },
      {
        "height" : 6,
        "width" : 6,
        "y" : 0,
        "x" : 6,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["CWAgent", "disk_used_percent", "AutoScalingGroupName", "${module.asg.autoscaling_group_name}"]
          ],
          "region" : "${local.region}",
          "stacked" : false,
          "view" : "timeSeries"
        }
      },
      {
        "height" : 6,
        "width" : 6,
        "y" : 0,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["CWAgent", "mem_used_percent", "AutoScalingGroupName", "${module.asg.autoscaling_group_name}"]
          ],
          "region" : "${local.region}",
          "stacked" : false,
          "view" : "timeSeries"
        }
      },
      {
        "height" : 6,
        "width" : 6,
        "y" : 0,
        "x" : 18,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["CWAgent", "disk_inodes_used", "AutoScalingGroupName", "${module.asg.autoscaling_group_name}"]
          ],
          "region" : "${local.region}",
          "stacked" : false,
          "view" : "timeSeries"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [{ "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} MetricName=\"HTTPCode_ELB_5XX_Count\" ', 'Sum', 300)" }]
          ],
          "legend" : {
            "position" : "bottom"
          },
          "title" : "HTTPCode_ELB_5XX_Count: Sum",
          "region" : "${local.region}",
          "liveData" : false,
          "timezone" : "UTC",
          "view" : "timeSeries",
          "stacked" : false
        }
      }
    ]
  })
}


# CPU 
# Network 
# 