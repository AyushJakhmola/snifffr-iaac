locals {
  name        = "snifffr"
  region      = "us-east-1"
  environment = "stg"
  acc         = 678109907733
  additional_tags = {
    Owner           = "snifffr"
    Department      = "Engineering"
    ApplicationName = "snifffr"
    ManagedBy       = "Squareops"
    Terraform       = "true"
    Environment     = "stg"
  }
}