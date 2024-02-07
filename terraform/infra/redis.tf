# security group for the redis server
module "redis_sg" {
  name       = format("%s-%s-redis-sg", local.environment, local.name)
  source     = "terraform-aws-modules/security-group/aws"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
  ingress_with_source_security_group_id = [
    {
      to_port                  = 6379
      from_port                = 6379
      protocol                 = "-1"
      source_security_group_id = module.app_sg.security_group_id
    },
    {
      to_port                  = 0
      from_port                = 0
      protocol                 = "tcp"
      source_security_group_id = module.vpc.vpn_security_group
    },
  ]

  egress_with_cidr_blocks = [
    {
      to_port     = 0
      from_port   = 0
      protocol    = "-1"
      description = "outbound rule"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_instance" "redis" {
  depends_on = [module.redis_sg]
  ami                     = "ami-0ade893e1fd5aae29"
  # name                    = "" 
  key_name                = module.key_pair.key_pair_name
  subnet_id               = module.vpc.public_subnets[0]
  instance_type           = "t2.micro"
  vpc_security_group_ids         = [module.redis_sg.security_group_id]
  disable_api_termination = true
  associate_public_ip_address = true
  root_block_device {
    volume_size             = 8
    volume_type             = "gp3"
  }
}
