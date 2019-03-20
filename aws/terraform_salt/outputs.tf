# Launch SLES-HAE of SLES4SAP cluster nodes

# Outputs: IP address and port where the service will be listening on

output "iscsisrv_ip" {
  value = "${aws_instance.iscsisrv.public_ip}"
}

output "iscsisrv_name" {
  value = "${aws_instance.iscsisrv.public_dns}"
}

output "cluster_nodes_ip" {
  value = ["${aws_instance.clusternodes.*.public_ip}"]
}

output "cluster_nodes_names" {
  value = ["${aws_instance.clusternodes.*.public_dns}"]
}
