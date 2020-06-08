resource "null_resource" "on_destroy" {
  count = var.node_count

  triggers = {
    instance_ids = join(",", var.instance_ids)
    user         = var.user
    password     = var.password
    private_key  = var.private_key_location
    public_ips   = join(",", var.public_ips)
    bastion_host = var.bastion_host
  }

  connection {
    host        = element(split(",", self.triggers.public_ips), count.index)
    type        = "ssh"
    user        = self.triggers.user
    password    = self.triggers.password
    private_key = self.triggers.private_key != "" ? file(self.triggers.private_key) : ""

    bastion_host        = self.triggers.bastion_host
    bastion_user        = self.triggers.user
    bastion_private_key = self.triggers.private_key != "" ? file(self.triggers.private_key) : ""

  }

  provisioner "file" {
    when        = destroy
    source      = "${path.module}/on_destroy.sh"
    destination = "/tmp/on_destroy.sh"
    on_failure  = continue
  }

  provisioner "remote-exec" {
    when       = destroy
    inline     = ["sudo timeout 300 sh /tmp/on_destroy.sh"]
    on_failure = continue
  }

  depends_on = [var.dependencies]
}
