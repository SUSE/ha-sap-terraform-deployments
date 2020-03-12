resource "null_resource" "pre_execution" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    working_dir = "${path.module}/../.."
    command = <<EOT
      cp pillar_examples/automatic/hana/* salt/hana_node/files/pillar;
      cp pillar_examples/automatic/drbd/* salt/drbd_node/files/pillar;
    EOT
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/../.."
    command = <<EOT
      mkdir -p salt/hana_node/files/sshkeys/;
      rm -rf salt/hana_node/files/sshkeys/*;
      ssh-keygen -f salt/hana_node/files/sshkeys/cluster.id_rsa -q -P "";
    EOT
  }
}
