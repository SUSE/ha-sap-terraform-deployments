resource "null_resource" "pre_execution" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    working_dir = "${path.module}/../.."
    command     = <<EOT
      cp pillar_examples/automatic/hana/* pillar/hana;
      cp pillar_examples/automatic/drbd/* pillar/drbd;
      cp pillar_examples/automatic/netweaver/* pillar/netweaver;
    EOT
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/../.."
    command     = <<EOT
      if [ -e salt/sshkeys/cluster.id_rsa ]; then exit 0; fi
      mkdir -p salt/sshkeys/;
      rm -rf salt/sshkeys/*;
      ssh-keygen -f salt/sshkeys/cluster.id_rsa -q -P "";
    EOT
  }
}
