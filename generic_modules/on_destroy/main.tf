resource "null_resource" "on_destroy" {
  count = var.node_count

  triggers = {
    instance_ids = join(",", var.instance_ids)
    user         = var.user
    password     = var.password
    private_key  = var.private_key_location
    public_ips   = join(",", var.public_ips)
  }

  provisioner "remote-exec" {
    connection {
      host        = element(split(",", self.triggers.public_ips), count.index)
      type        = "ssh"
      user        = self.triggers.user
      password    = self.triggers.password
      private_key = self.triggers.private_key != "" ? file(self.triggers.private_key) : ""
    }
    when       = destroy
    inline     = ["sudo sh /root/salt/on_destroy.sh"]
    on_failure = continue
  }

  depends_on = [var.dependencies]
}
