#terraform {
  #backend "s3" {
   #key            = "terraform.tfstate"
    #bucket         = "test-snifffr-iaac-state-678109907733"
    #region         = "us-east-2"
    #dynamodb_table = "test-snifffr-iaac-state-lock-dynamodb-678109907733"
  #}
#}

provider "aws" {
  region = local.region
  default_tags {
    tags = local.additional_tags
  }
}