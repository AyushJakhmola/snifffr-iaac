module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = format("%s-%s-efs", local.environment, local.name)

#   encrypted      = true
#   kms_key_arn    = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  performance_mode                = "generalPurpose"
  throughput_mode                 = "bursting"
#   provisioned_throughput_in_mibps = 256

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # File system policy
  attach_policy                      = false
#   bypass_policy_lockout_safety_check = false
#   policy_statements = [
#     {
#       sid     = "Example"
#       actions = ["elasticfilesystem:ClientMount"]
#       principals = [
#         {
#           type        = "AWS"
#           identifiers = ["arn:aws:iam::111122223333:role/EfsReadOnly"]
#         }
#       ]
#     }
#   ]

  # Mount targets / security group
  mount_targets = {
    "us-east-1a" = {
      subnet_id = "subnet-0ee640c6799c2e0a7"
    }
    "us-east-1b" = {
      subnet_id = "subnet-082d51f43dc79a6da"
    }
  }
  security_group_description = "Example EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
    }
  }

  # Backup policy
  enable_backup_policy = false

  # Replication configuration
  create_replication_configuration = false
#   replication_configuration_destination = {
#     region = "eu-west-2"
#   }
#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
}