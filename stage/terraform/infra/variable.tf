variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "acm" {
  description = "AWS ACN certificate arn"
  type        = string
  default     = "arn:aws:acm:us-east-1:678109907733:certificate/d2c59a76-5a2f-436a-a754-2bd8015ae04d"
}

variable "health_check_parameters" {
  description = "Health check attributes for the application"
  type        = map(string)
  default = {
    port         = 443
    path         = "/"
    protocol     = "HTTPS"
    success_code = "200-499"
  }
}

variable "app_server_configuration" {
  description = "Specify the Server Configurations"
  type        = map(string)
  default = {
    image_id         = "ami-0a01631a8e9ee6205"
    min_size         = 1
    max_size         = 1
    volume_size      = 20
    volume_type      = "gp3"
    instance_type    = "t3.medium"
    desired_capacity = 1
  }
}

variable "bakend_server_configurations" {
  description = "Specify the Server Configurations"
  type        = map(string)
  default = {
    image_id         = "ami-051e3c7b758a94f24"
    min_size         = 1
    max_size         = 1
    volume_size      = 20
    volume_type      = "gp3"
    instance_type    = "t3.medium"
    desired_capacity = 1
  }
}

variable "cicd_configuration" {
  description = "Specify the cicd configuration"
  type        = map(string)
  default = {
    token        = "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"
    branch_name  = "develop"
    git_location = "https://github.com/snifffr-com/snifffr.com-website.git"
    repository   = "snifffr-com/snifffr.com-website"
  }
}

variable "database_configuration" {
  description = "Specify the paraeters for the database"
  type        = map(string)
  default = {
    engine              = "aurora-mysql"
    engine_version      = "5.7.mysql_aurora.2.11.2"
    instance_class      = "db.t3.medium"
    snapshot_identifier = "dev-rds-changed"
  }
}

variable "cache_config" { 
  description = "Specify the paraeters for the Caching"
  default = {
    origin_id = "alb"
    cache_enable_policy = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cache_disable_policy = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    viewer_protocol_policy = "https-only"
  }
}
# variable "path_pattern" {
#   description = "Lists the paths to be response"
#   type = list(string)
#   default = ["/members/*","/arrowchat/*","/wp-content/*"]
# }

# variable "path_pattern" {
#   description = "Lists the pahs to be hide in responce"
#   type = list(string)
#   default = ["/members/*","/arrowchat/*","/wp-content/*"]
# }
# create HA

 