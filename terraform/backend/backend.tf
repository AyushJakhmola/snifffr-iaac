module "backend" {
  source                       = "squareops/tfstate/aws"
  logging                      = false
  bucket_name                  = "test-snifffr-iaac-state" 
  environment                  = local.environment
  force_destroy                = true
  versioning_enabled           = false
  cloudwatch_logging_enabled   = false
  log_bucket_lifecycle_enabled = true
  s3_ia_retention_in_days      = 30
  s3_galcier_retention_in_days = 90
}