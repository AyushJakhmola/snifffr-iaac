packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "basic-ami" {
  ami_name             = "snifffr-app-packer-{{timestamp}}"
  instance_type        = var.Server_cofig.instance_type
  ssh_interface         = "public_ip"
  ssh_username         = "ubuntu"
  source_ami           = var.Server_cofig.source_ami
  region               = var.region
  # ssh_agent_auth       = true
  # ssh_keypair_name     = "sniff-2022.pem"
  # ssh_private_key_file = "/home/ubuntu/sniff-2022.pem"
}

build {
  sources = ["source.amazon-ebs.basic-ami"]

  provisioner "shell" {
    script       = "install.sh"
    pause_before = "10s"
    timeout      = "10s"
  }

  provisioner "file" {
    source      = "www.conf"
    destination = "/tmp/www.conf"
  }
    provisioner "shell" {
    inline = ["sudo mv /tmp/www.conf /etc/php/7.4/fpm/pool.d/www.conf"]
  }
}

# apache configuration 


