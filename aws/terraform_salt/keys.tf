resource "aws_key_pair" "mykey" {
  key_name   = "${terraform.workspace} - mykey"
  public_key = "${file("${var.public_key_location}")}"
}
