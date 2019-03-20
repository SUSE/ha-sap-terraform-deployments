resource "aws_key_pair" "mykey" {
  key_name   = "${terraform.workspace} - mykey"
  public_key = "${var.public_key}"
}
