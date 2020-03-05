resource "aws_key_pair" "hana-key-pair" {
  key_name   = "${terraform.workspace} - terraform"
  public_key = file(var.public_key_location)
}
