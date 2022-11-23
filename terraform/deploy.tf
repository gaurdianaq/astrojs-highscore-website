terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "web_ami" {
  owners           = ["self"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["gaurdianaq-web-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_key
}

resource "aws_security_group" "web" {
  name        = "web security group"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Ports"
  }
}

variable "ssh_key" {
    type = string
    description = "The public key to be put on the EC2 instance so you can SSH in."
}

resource "aws_instance" "web_server" {
  ami               = data.aws_ami.web_ami.id
  instance_type     = "t2.small"
  availability_zone = "us-east-2a"
  key_name = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 20
  }

  security_groups = [ aws_security_group.web.name ]

  tags = {
    Name = "Highscore Web Server"
  }
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = "${aws_instance.web_server.public_ip}"
}