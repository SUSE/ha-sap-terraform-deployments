resource "null_resource" "provision_background" {
  count = var.background ? var.node_count : 0
  triggers = {
    triggers = join(",", var.instance_ids)
  }

  connection {
    host        = element(var.public_ips, count.index)
    type        = "ssh"
    user        = var.user
    password    = var.password
    private_key = var.private_key != "" ? var.private_key : ""

    bastion_host        = var.bastion_host
    bastion_user        = var.user
    bastion_private_key = var.bastion_private_key != "" ? var.bastion_private_key : ""
  }

  provisioner "file" {
    source      = "${path.module}/../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.module}/../../pillar"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "nohup sudo bash /tmp/salt/provision.sh -l /var/log/salt-result.log > /dev/null 2>&1 &",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}

resource "null_resource" "provision" {
  count = ! var.background ? var.node_count : 0
  triggers = {
    triggers = join(",", var.instance_ids)
  }

  connection {
    host        = element(var.public_ips, count.index)
    type        = "ssh"
    user        = var.user
    password    = var.password
    private_key = var.private_key != "" ? var.private_key : ""

    bastion_host        = var.bastion_host
    bastion_user        = var.user
    bastion_private_key = var.bastion_private_key != "" ? var.bastion_private_key : ""
  }

  provisioner "file" {
    source      = "${path.module}/../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.module}/../../pillar"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/salt/provision.sh -sol /var/log/salt-result.log",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "${var.reboot} && [ -f /var/run/reboot-needed ] && echo \"Rebooting the machine...\" && (nohup sudo sh -c 'systemctl stop sshd;/sbin/reboot' &) && sleep 5",
    ]
    on_failure = continue
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /srv/salt/provision.sh -pdql /var/log/salt-result.log",
    ]
  }
}
