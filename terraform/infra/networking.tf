module "vpc" {
  source                   = "squareops/vpc/aws"
  name                     = local.name
  vpc_cidr                 = var.vpc_cidr
  environment              = local.environment
  vpn_key_pair_name        = module.key_pair.key_pair_name
  vpn_server_enabled       = true
  availability_zones       = ["${local.region}a", "${local.region}b"]
  public_subnet_enabled    = true
  auto_assign_public_ip    = true
  private_subnet_enabled   = true
  vpn_server_instance_type = "t3a.small"
}

# test VPN server