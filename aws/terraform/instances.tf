# Launch SLES-HAE of SLES4SAP cluster nodes

# EC2 Instances

resource "aws_instance" "iscsisrv" {
  ami                         = "${lookup(var.sles4sap, var.aws_region)}"
  instance_type               = "t2.micro"
  key_name                    = "mykey"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.local.id}"
  private_ip                  = "10.0.0.254"
  security_groups             = ["${aws_security_group.secgroup.id}"]
  user_data                   = "${data.template_file.init_iscsi.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = "10"
    device_name = "/dev/xvdd"
  }

  tags {
    Name        = "iSCSI Server"
  }
}

resource "aws_instance" "clusternodes" {
  count                       = "${var.ninstances}"
  ami                         = "${lookup(var.sles4sap, var.aws_region)}"
  instance_type               = "${var.instancetype}"
  key_name                    = "mykey"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.local.id}"
  private_ip                  = "10.0.1.${count.index}"
  security_groups             = ["${aws_security_group.secgroup.id}"]
  user_data                   = "${data.template_file.init_nodes.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = "60"
    device_name = "/dev/xvdd"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "${var.aws_credentials}"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    source      = "./provision/"
    destination = "/tmp/"
  }

  tags {
    Name        = "Node-${count.index}"
  }
}
