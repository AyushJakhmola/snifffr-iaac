variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "health_check_parameters" {
  description = "Health check attributes for the application"
  type        = map(string)
  default = {
    port     = 443
    path     = "/healthlocal"
    protocol = "HTTPS"
  }
}

variable "server_configurations" {
  description = "Specify the Server Configurations"
  type        = map(string)
  default = {
    image_id         = "ami-09f39405c582e8e7a"
    min_size         = 1
    max_size         = 1
    instance_type    = "t3.large"
    desired_capacity = 1
  }
}

variable "cicd_configuration" {
  description = "Specify the cicd configuration"
  type        = map(string)
  default = {
    token        = ""
    branch_name  = "cicd-develop"
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
    snapshot_identifier = "rds:dev-rds-temp-sniff-cluster-2023-10-30-08-12"
  }
}