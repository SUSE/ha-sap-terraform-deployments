# Launch SLES-HAE of SLES4SAP cluster nodes

# Variables for type of instances to use and number of cluster nodes
# Use with: terraform apply -var instancetype=Small -var ninstances=2

variable "instancetype" {
  type    = "string"
  default = "Standard_E4s_v3"
}

# For reference:
# Standard_B1ms has 1 VCPU, 2GiB RAM, 1 NIC, 2 data disks and 4GiB SSD
# Standard_D2s_v3 has 2 VCPU, 8GiB RAM, 2 NICs, 4 data disks and 16GiB SSD disk
# Standard_D8s_v3 has 8 VCPU, 32GiB RAM, 2 NICs, 16 data disks and 64GiB SSD disk
# Standard_E4s_v3 has 4 VCPU, 32GiB RAM, 2 NICs, 64GiB SSD disk
# Standard_M32ts has 32 VCPU, 192GiB RAM, 1000 GiB SSD

variable "ninstances" {
  type    = "string"
  default = "2"
}

# Variable for default region where to deploy resources

variable "az_region" {
  type    = "string"
  default = "westeurope"
}

# Variable for init-nodes.sh script

variable "init-type" {
  type    = "string"
  default = "all"
}
