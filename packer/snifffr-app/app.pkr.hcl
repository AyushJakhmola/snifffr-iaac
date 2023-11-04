packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "basic-ami" {
  ami_name             = "snifffr-app"
  instance_type        = "t3.medium"
  ssh_interface         = "public_ip"
  ssh_username         = "root"
  source_ami           = "ami-0002553a0d49fa20f"
  region               = "us-west-2"
}

build {
  sources = ["source.amazon-ebs.basic-ami"]

  provisioner "shell" {
    script       = "install.sh"
    pause_before = "10s"
    timeout      = "10s"
  }
}