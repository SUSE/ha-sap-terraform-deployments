output "fortigate_url" {
  value = var.fortinet_enabled ? format("https://%s", module.fortigate[0].fortigate_virtual_public_ip) : ""
}

output "fortigate_a_url" {
  value = var.fortinet_enabled ? format("https://%s", module.fortigate[0].fortigate_a_management_public_ip) : ""
}

output "fortigate_b_url" {
  value = var.fortinet_enabled ? format("https://%s", module.fortigate[0].fortigate_b_management_public_ip) : ""
}

output "fortiadc_a_url" {
  value = var.fortinet_enabled ? format("https://%s:41443", module.fortigate[0].fortigate_virtual_public_ip) : ""
}

output "fortiadc_b_url" {
  value = var.fortinet_enabled ? format("https://%s:51443", module.fortigate[0].fortigate_virtual_public_ip) : ""
}
