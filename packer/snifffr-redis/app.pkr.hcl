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
  instance_type        = "t3.medium"
  ssh_interface         = "public_ip"
  ssh_username         = "ubuntu"
  source_ami           = "ami-06aa3f7caf3a30282"
  region               = "us-east-1"
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
    source      = "apache.conf"
    destination = "/tmp/apache.conf"
  }
    provisioner "shell" {
    inline = ["sudo mv /tmp/apache.conf /etc/apache2/apache.conf"]
  }

}

# apache configuration 


