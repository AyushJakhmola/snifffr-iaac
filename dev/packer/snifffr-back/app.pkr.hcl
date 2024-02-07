packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "basic-ami" {
  ami_name             = "dev-snifffr-backapp-{{timestamp}}"
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

# addind script buddypress_cleanup

  provisioner "file" {
    source      = "buddypress_cleanup.sh"
    destination = "/tmp/buddypress_cleanup.sh"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/buddypress_cleanup.sh /usr/local/server-scripts/buddypress_cleanup.sh"]
  }
    
# adding script buddypress_coverimage_cleanup

  provisioner "file" {
    source      = "buddypress_coverimage_cleanup.sh"
    destination = "/tmp/buddypress_coverimage_cleanup.sh"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/buddypress_coverimage_cleanup.sh /usr/local/server-scripts/buddypress_coverimage_cleanup.sh"]
  }

# adding script cleanup

  provisioner "file" {
    source      = "cleanup.sh"
    destination = "/tmp/cleanup.sh"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/cleanup.sh /usr/local/server-scripts/cleanup.sh"]
  }

# adding script arrowchat_msg_cleanup.sh

  provisioner "file" {
    source      = "arrowchat_msg_cleanup.sh"
    destination = "/tmp/arrowchat_msg_cleanup.sh"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/arrowchat_msg_cleanup.sh /usr/local/server-scripts/arrowchat_msg_cleanup.sh"]
  }


# adding script bp-core-avatars.php

  provisioner "file" {
    source      = "bp-core-avatars.php"
    destination = "/tmp/bp-core-avatars.php"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/bp-core-avatars.php /usr/local/server-scripts/bp-core-avatars.php"]
  }

# adding script bp-core-avatars.php

  provisioner "file" {
    source      = "root"
    destination = "/tmp/root"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/root /usr/local/server-scripts/root"]
  }

  provisioner "shell" {
    inline = ["sudo chown -R root:crontab /usr/local/server-scripts/root"]
  }

}



