
# module "redis" {
#   source                     = "squareops/elasticache-redis/aws"
#   name                       = format("%s-%s-db", local.environment, local.name)
#   family                     = "redis4.0"
#   vpc_id                     = module.vpc.vpc_id
#   subnets                    = module.vpc.private_subnets
#   node_type                  = "cache.t3.small"
#   environment                = "production"
#   engine_version             = "4.0.10"
#   snapshot_window            = "07:00-08:00"
#   num_cache_nodes            = 1
#   multi_az_enabled           = false
#   maintenance_window         = "sun:09:00-sun:10:00"
#   availability_zones         = ["us-east-1a"]
#   automatic_failover_enabled = false
#   snapshot_retention_limit   = 7
#   allowed_security_groups    = [module.app_sg.security_group_id]
#   #   cloudwatch_metric_alarms_enabled = true  # For enabling basic alerting
#   #   alarm_cpu_threshold_percent      = 70
#   #   alarm_memory_threshold_bytes     = "10000000" # in bytes
# }
