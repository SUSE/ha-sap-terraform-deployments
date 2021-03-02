# Data used to get the correct AMI image
data "aws_ami" "image" {
  most_recent = true
  owners      = [var.os_owner]

  filter {
    name   = "name"
    values = substr(var.os_image, 0, 4) == "ami-" ? ["*"] : ["${var.os_image}-*"]
  }

  filter {
    name   = "image-id"
    values = substr(var.os_image, 0, 4) == "ami-" ? [var.os_image] : ["*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
