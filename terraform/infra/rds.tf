# module "db_rds" {
#   name                   = format("%s-%s-db", local.environment, local.name)
#   source                 = "terraform-aws-modules/rds-aurora/aws"
#   engine                 = var.database_configuration.engine
#   vpc_id                 = module.vpc.vpc_id
#   subnets                = module.vpc.private_subnets
#   engine_version         = var.database_configuration.engine_version
#   instance_class         = var.database_configuration.instance_class
#   storage_encrypted      = true
#   apply_immediately      = true
#   monitoring_interval    = 10
#   skip_final_snapshot    = true
#   snapshot_identifier    = var.database_configuration.snapshot_identifier
#   db_subnet_group_name   = format("%s-%s-db-subnet-group", local.environment, local.name)
#   create_db_subnet_group = true
#   db_cluster_parameter_group_name        = format("%s-%s-cluster-group", local.environment, local.name)
#   db_cluster_parameter_group_family      = var.database_configuration.db_cluster_parameter_group_family
#   create_db_cluster_parameter_group      = true
#   db_cluster_parameter_group_parameters = [
#      {
#       name         = "aurora_parallel_query"
#       value        = "ON"
#       apply_method = "immediate"
#       }, {
#       name         = "long_query_time "
#       value        = 5
#       apply_method = "immediate"
#       }, {
#       name         = "slow_query_log "
#       value        = 1
#       apply_method = "immediate"
#       }
#   ]

#   db_parameter_group_name        = format("%s-%s-db-group", local.environment, local.name)
#   create_db_parameter_group      = true
#   db_parameter_group_family      = var.database_configuration.db_cluster_parameter_group_family
#   security_group_rules = {
#     ex1_ingress = {
#       cidr_blocks = [module.vpc.vpc_cidr_block]
#     }
#     ex1_ingress = {
#       source_security_group_id = module.app_sg.security_group_id
#     }
#   }
#   instances = {
#     one = {
#       instance_class      = var.database_configuration.instance_class
#     }
#     two = {
#       instance_class      = var.database_configuration.instance_class
#     }
#     three = {
#       instance_class      = var.database_configuration.instance_class
#     }
#   }
# }