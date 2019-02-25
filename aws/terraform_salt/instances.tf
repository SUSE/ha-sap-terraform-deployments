# Launch SLES-HAE of SLES4SAP cluster nodes

# EC2 Instances

resource "aws_instance" "iscsisrv" {
  ami                         = "${lookup(var.iscsi_srv, var.aws_region)}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.mykey.key_name}"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.local.id}"
  private_ip                  = "10.0.0.254"
  security_groups             = ["${aws_security_group.secgroup.id}"]
  user_data                   = "${data.template_file.init_server.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = "10"
    device_name = "/dev/xvdd"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp/"
  }

  provisioner "file" {
    content = <<EOF
provider: "aws"
iscsi_srv_ip: ${aws_instance.iscsisrv.private_ip}
iscsidev: ${var.iscsidev}
role: "iscsi_srv"
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]

partitions:
  1:
    start: 0
    end: 1024
  2:
    start: 1025
    end: 2048
  3:
    start: 2049
    end: 3072
  4:
    start: 3073
    end: 4096
  5:
    start: 4097
    end: 5120
 EOF

    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/salt /root",
    ]
  }

  tags {
    Name      = "${terraform.workspace} - iSCSI Server"
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_instance" "clusternodes" {
  count                       = "${var.ninstances}"
  ami                         = "${lookup(var.sles4sap, var.aws_region)}"
  instance_type               = "${var.instancetype}"
  key_name                    = "${aws_key_pair.mykey.key_name}"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.local.id}"
  private_ip                  = "10.0.1.${count.index}"
  security_groups             = ["${aws_security_group.secgroup.id}"]
  user_data                   = "${data.template_file.init_server.rendered}"

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
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "${var.aws_credentials}"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp/"
  }

  provisioner "file" {
    content = <<EOF
provider: "aws"
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_disk_device: ${var.hana_disk_device}
iscsi_srv_ip: ${aws_instance.iscsisrv.private_ip}
role: "hana_node"
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
EOF

    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/salt /root",
    ]
  }

  tags {
    Name = "${terraform.workspace} - Node-${count.index}"
  }
}
