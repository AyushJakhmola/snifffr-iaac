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
        "height" : 6,
        "width" : 6,
        "y" : 6,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "legend" : {
            "position" : "bottom"
          },
          "liveData" : false,
          "metrics" : [
            [{ "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} MetricName=\"HTTPCode_ELB_5XX_Count\" ', 'Sum', 300)" }]
          ],
          "region" : "${local.region}",
          "stacked" : false,
          "timezone" : "UTC",
          "title" : "HTTPCode_ELB_5XX_Count: Sum",
          "view" : "timeSeries"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${module.asg.autoscaling_group_name}"]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 12,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${module.alb.arn_suffix}"]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 18,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "singleValue",
          "stacked" : false,
          "metrics" : [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${aws_lb_target_group.app_tg.arn_suffix}", "LoadBalancer", "${module.alb.arn_suffix}", { "region" : "${local.region}" }]
          ],
          "region" : "${local.region}",
          "period" : 300
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", "${format("%s-%s-db", local.environment, local.name)}", { "period" : 60 }]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "ReadLatency", "DBClusterIdentifier", "${format("%s-%s-db", local.environment, local.name)}", { "period" : 60, "region" : "${local.region}" }],
            [".", "WriteLatency", ".", ".", { "period" : 60 }]
          ],
          "region" : "${local.region}",
          "period" : 300
        }
      },
      {
        "type" : "metric",
        "x" : 18,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "DiskQueueDepth", "DBClusterIdentifier", "${format("%s-%s-db", local.environment, local.name)}", { "period" : 60 }]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 18,
        "y" : 18,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/CloudFront", "Requests", "Region", "Global", "DistributionId", "${aws_cloudfront_distribution.alb_cache.id}", { "region" : "${local.region}", "visible" : false }],
            [".", "5xxErrorRate", ".", ".", ".", ".", { "region" : "${local.region}" }],
            [".", "4xxErrorRate", ".", ".", ".", ".", { "region" : "${local.region}" }],
            [".", "TotalErrorRate", ".", ".", ".", ".", { "region" : "${local.region}" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "${local.region}",
          "period" : 300,
          "stat" : "Average"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 18,
        "width" : 6,
        "height" : 5,
        "properties" : {
          "view" : "singleValue",
          "stacked" : false,
          "metrics" : [
            ["AWS/EFS", "StorageBytes", "StorageClass", "Total", "FileSystemId", "${module.efs.id}"]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 18,
        "width" : 6,
        "height" : 4,
        "properties" : {
          "view" : "singleValue",
          "stacked" : false,
          "metrics" : [
            ["AWS/EFS", "ClientConnections", "FileSystemId", "${module.efs.id}"]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 12,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/EFS", "PermittedThroughput", "FileSystemId", "${module.efs.id}"],
            [".", "PercentIOLimit", ".", "."],
            [".", "TotalIOBytes", ".", "."]
          ],
          "region" : "${local.region}"
        }
      },
      {
        "type" : "log",
        "x" : 0,
        "y" : 23,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "query" : "SOURCE '/aws/${local.environment}/apache/error.log' | fields @timestamp, @message, @logStream, @log\n| sort @timestamp desc\n| limit 20",
          "region" : "${local.region}",
          "title" : "Log group: /aws/${local.environment}/apache/error.log",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "x" : 0,
        "y" : 29,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "query" : "SOURCE '/aws/${local.environment}/apache/access.log' | fields @timestamp, @message, @logStream, @log\n| sort @timestamp desc\n| limit 20",
          "region" : "${local.region}",
          "stacked" : false,
          "view" : "table"
        }
      }
    ]
  })
}


