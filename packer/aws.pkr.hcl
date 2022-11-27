packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "gaurdianaq-web-server"
}

variable "build_location" {
  type = string
  default = "../dist"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "fedora" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "Fedora-Cloud-Base-36-1.5.x86_64-hvm-us-east-2-standard-0"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["125523088429"]
  }
  ssh_username = "fedora"
}

build {
  name = "web-server"
  sources = [
    "source.amazon-ebs.fedora"
  ]

  provisioner "shell" {
    inline = [
      "sudo dnf -y install nginx",
      "sudo dnf -y install nodejs", //This isn't currently needed, will be needed if I decide I need some sort of server side stuff
      "sudo mkdir /data",
      "sudo mkdir /data/www",
      "mkdir ~/nginx",
      "mkdir ~/www"
    ]
  }

  provisioner "file" { //putting in a config so that it should start in permissive mode
    source = "selinuxconfig"
    destination = "~/config"
  }

  provisioner "file" {
    source = "nginx.conf"
    destination = "~/nginx/nginx.conf"
  }

  provisioner "file" {
    source = "${var.build_location}"
    destination = "~/www/"
  }

  provisioner "shell" {
    inline = [
      "sudo rm /etc/selinux/config",
      "sudo mv ~/config /etc/selinux/config",
      "sudo mv ~/nginx/nginx.conf /etc/nginx/conf.d/nginx.conf",
      "sudo rm -r /usr/share/nginx/html/*",
      "sudo mv ~/www/* /data/www/",
      "rm -r ~/nginx",
      "rm -r ~/www",
      "sudo setenforce 0",
      "sudo systemctl enable nginx"
    ]
  }
}

