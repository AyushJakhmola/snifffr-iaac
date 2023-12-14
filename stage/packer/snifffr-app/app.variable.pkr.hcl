variable "Server_cofig" {
  type    = map(string)
  default = {
    source_ami = "ami-06aa3f7caf3a30282"
    instance_type = "t3.medium"
  }
}

variable "region" {
    type = string
    default = "us-east-1"
}