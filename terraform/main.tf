provider "aws" {
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#resource "aws_instance" "api_vm" {
#  ami           = "${data.aws_ami.ubuntu.id}"
#  instance_type = "t2.micro"
#  security_groups = ["${aws_security_group.allow_all.name}"]
#  key_name = "api"
#  tags {
#    Name = "api_vm"
#  }
#
#
#  provisioner "remote-exec" {
#    inline = [
#      "curl -fsSL https://get.docker.com -o get-docker.sh",
#      "sudo sh get-docker.sh"
#    ]
#    connection {
#      type     = "ssh"
#      user     = "ubuntu"
#      private_key = "${file("api.pem")}"
#    }
#  }
#}

#resource "aws_ecr_repository" "api_repo" {
#  name = "api"
#}

