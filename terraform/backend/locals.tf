locals {
  name = "snifffr"
  region      = "us-east-2"
  environment = "dev"
  additional_tags = {
    Owner      = "snifffr"
    Expires    = "Never"
    Department = "Engineering"
  }
   vpc_cidr = "10.10.0.0/16"
}