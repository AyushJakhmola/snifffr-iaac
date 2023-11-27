locals {
  name = "snifffr"
  region      = "us-east-1"
  environment = "stg"
  additional_tags = {
    Owner      = "snifffr"
    Expires    = "Never"
    Department = "Engineering"
  }
   vpc_cidr = "10.0.0.0/16"
}