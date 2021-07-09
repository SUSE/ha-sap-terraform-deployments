# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# Hana nodes

output "cluster_nodes_ip" {
  value = module.hana_node.cluster_nodes_ip
}

output "cluster_nodes_public_ip" {
  value = module.hana_node.cluster_nodes_public_ip
}

#output "cluster_nodes_name" {
#  value = module.hana_node.cluster_nodes_name
#}


#output "cluster_nodes_public_name" {
#  value = module.hana_node.cluster_nodes_public_name
#}

# bastion

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

# debug - can contain temporary outputs of values from root or other modules for debugging purposes

#output "hana_provisioning_addresses" {
#  value = module.hana_node.provisioning_addresses
#}
