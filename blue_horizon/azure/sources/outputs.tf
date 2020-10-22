output "admin_user" {
  value = var.os_admnistrator_name
}

output "bastion_ip" {
  value = module.bluehorizon.bastion_public_ip
}

output "hana_ips" {
  value = join(",", module.bluehorizon.cluster_nodes_ip)
}

output "monitoring_server" {
  value = "http://${module.bluehorizon.monitoring_public_ip}:3000"
}

data "azurerm_subscription" "current" {
}

output "resource_group_url" {
  value = "https://portal.azure.com/#@SUSERDBillingsuse.onmicrosoft.com/resource${data.azurerm_subscription.current.id}/resourceGroups/rg-ha-sap-${var.deployment_name}/overview"
}
