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
    private_key = var.private_key_location != "" ? file(var.private_key_location) : ""
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "nohup sudo sh /tmp/salt/provision.sh > /var/log/provisioning.log &",
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
    private_key = var.private_key_location != "" ? file(var.private_key_location) : ""
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/salt/provision.sh -so > /var/log/provisioning.log",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "[ -f /var/run/reboot-needed ] && echo \"Rebooting the machine...\" && (nohup sudo sh -c 'systemctl stop sshd;/sbin/reboot' &) && sleep 5",
    ]
    on_failure = continue
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /root/salt/provision.sh -pdq >> /var/log/provisioning.log",
    ]
  }
}
