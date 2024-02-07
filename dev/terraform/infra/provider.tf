terraform {
  backend "s3" {
    key            = "dev/terraform.tfstate"
    bucket         = "stg-snifffr-iaac-state-678109907733"
    region         = "us-east-1"
    dynamodb_table = "stg-snifffr-iaac-state-lock-dynamodb-678109907733"
  }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = local.additional_tags
  }
}