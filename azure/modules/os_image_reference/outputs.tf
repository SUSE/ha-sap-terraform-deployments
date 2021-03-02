# Terraform module to wrap up a method to split the os_image information used in all of the
# other modules

# Usage example
####################
#
#module "os_image" {
#  source   = "../../modules/os_image_reference"
#  os_image = var.os_image
#}
#
#storage_image_reference {
#  publisher = module.os_image.publisher
#  offer     = module.os_image.offer
#  sku       = module.os_image.sku
#  version   = module.os_image.version
#}

locals {
  data      = split(":", var.os_image)
  publisher = local.data[0]
  offer     = local.data[1]
  sku       = local.data[2]
  version   = local.data[3]
}

output "publisher" {
  value = local.publisher
}

output "offer" {
  value = local.offer
}

output "sku" {
  value = local.sku
}

output "version" {
  value = local.version
}
