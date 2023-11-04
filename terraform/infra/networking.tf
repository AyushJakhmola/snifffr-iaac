module "vpc" {
  source                 = "squareops/vpc/aws"
  name                   = local.name
  vpc_cidr               = var.vpc_cidr
  environment            = local.environment
  availability_zones     = ["us-west-1a", "us-west-1b"]
  public_subnet_enabled  = true
  auto_assign_public_ip  = true
  private_subnet_enabled = true
}

