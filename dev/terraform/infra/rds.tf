module "db_rds" {
  name                   = format("%s-%s-db", local.environment, local.name)
  source                 = "terraform-aws-modules/rds-aurora/aws"
  engine                 = var.database_configuration.engine
  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnets
  engine_version         = var.database_configuration.engine_version
  instance_class         = var.database_configuration.instance_class
  storage_encrypted      = true
  apply_immediately      = true
  monitoring_interval    = 10
  skip_final_snapshot    = true
  snapshot_identifier    = var.database_configuration.snapshot_identifier
  db_subnet_group_name   = format("%s-%s-db-subnet-group", local.environment, local.name)
  create_db_subnet_group = true
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
    ex1_ingress = {
      source_security_group_id = module.app_sg.security_group_id
    }
  }
  instances = {
    one = {}
    two = {}
  }

}