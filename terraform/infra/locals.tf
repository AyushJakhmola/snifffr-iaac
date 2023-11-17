locals {
  name        = "snifffr"
  region      = "us-east-1"
  environment = "dev"
  additional_tags = {
    Owner           = "snifffr"
    Department      = "Engineering"
    ApplicationName = "snifffr"
    ManagedBy       = "Squareops"
    Terraform       = "true"
    Environment     = "dev"
  }
}