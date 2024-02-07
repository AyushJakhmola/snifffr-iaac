packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "basic-ami" {
  ami_name             = "dev-snifffr-app-{{timestamp}}"
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

# apache configuration file
  provisioner "file" {
    source      = "apache.conf"
    destination = "/tmp/apache.conf"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/apache.conf /etc/apache2/apache2.conf"]
  }

# php configuration file
  provisioner "file" {
    source      = "www.conf"
    destination = "/tmp/www.conf"
  }
    provisioner "shell" {
    inline = ["sudo mv /tmp/www.conf /etc/php/7.4/fpm/pool.d/www.conf"]
  }

# ssl certificates  

  provisioner "file" {
    source      = "cert.pem"
    destination = "/tmp/cert.pem"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/cert.pem /etc/letsencrypt/live/dev.snifffr.com/cert.pem"]
  }

  provisioner "file" {
    source      = "chain.pem"
    destination = "/tmp/chain.pem"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/chain.pem /etc/letsencrypt/live/dev.snifffr.com/chain.pem"]
  }

  provisioner "file" {
    source      = "fullchain.pem"
    destination = "/tmp/fullchain.pem"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/fullchain.pem /etc/letsencrypt/live/dev.snifffr.com/fullchain.pem"]
  }

    provisioner "file" {
    source      = "privkey.pem"
    destination = "/tmp/privkey.pem"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/privkey.pem /etc/letsencrypt/live/dev.snifffr.com/privkey.pem"]
  }

# proxysql configuration 
  provisioner "file" {
    source      = "proxysql.cnf"
    destination = "/tmp/proxysql.cnf"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/proxysql.cnf /etc/proxysql.cnf"]
  }

  provisioner "file" {
    source      = "proxysql"
    destination = "/tmp/proxysql"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/proxysql /etc/logrotate.d/proxysql"]
  }

  provisioner "file" {
    source      = "fcgid.conf"
    destination = "/tmp/fcgid.conf"
  }
  
  provisioner "shell" {
    inline = ["sudo mv /tmp/fcgid.conf /etc/apache2/mods-enabled/fcgid.conf"]
  }

}


