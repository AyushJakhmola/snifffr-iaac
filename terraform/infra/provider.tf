terraform {
  backend "s3" {
    key            = "terraform.tfstate"
    bucket         = "snifffr-iaac-state-678109907733"
    region         = "us-west-2"
    dynamodb_table = "snifffr-iaac-state-lock-dynamodb-678109907733"
  }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = local.additional_tags
  }
}