# Launch SLES-HAE of SLES4SAP cluster nodes

# Availability set for the VMs

resource "azurerm_availability_set" "myas" {
  name                        = "myas"
  location                    = "${var.az_region}"
  resource_group_name         = "${azurerm_resource_group.myrg.name}"
  platform_fault_domain_count = 2
  managed                     = "true"

  tags {
    workspace = "${terraform.workspace}"
  }
}

# iSCSI server VM

resource "azurerm_virtual_machine" "iscsisrv" {
  name                  = "${terraform.workspace}-iscsisrv"
  location              = "${var.az_region}"
  resource_group_name   = "${azurerm_resource_group.myrg.name}"
  network_interface_ids = ["${azurerm_network_interface.iscsisrv.id}"]
  availability_set_id   = "${azurerm_availability_set.myas.id}"
  vm_size               = "Standard_D2s_v3"

  storage_os_disk {
    name              = "iscsiOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "SUSE"
    offer     = "SLES-SAP-BYOS"
    sku       = "15"
    version   = "2018.08.20"
  }

  storage_data_disk {
    name              = "iscsiDevices"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "iscsisrv"
    admin_username = "${var.admin_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${file(var.public_key_location)}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mytfstorageacc.primary_blob_endpoint}"
  }

  connection {
    type        = "ssh"
    user        = "${var.admin_user}"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp/"
  }

  provisioner "file" {
    content     = "${data.template_file.init_server.rendered}"
    destination = "/tmp/init-server.sh"
  }

  provisioner "file" {
    content = <<EOF
provider: "azure"
role: "iscsi_srv"
iscsi_srv_ip: ${azurerm_network_interface.iscsisrv.private_ip_address}
iscsidev: ${var.iscsidev}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

partitions:
  1:
    start: 0
    end: 1024
  2:
    start: 1025
    end: 2048
  3:
    start: 2049
    end: 3072
  4:
    start: 3073
    end: 4096
  5:
    start: 4097
    end: 5120
 EOF

    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/salt /root",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/init-server.sh",
    ]
  }

  tags {
    workspace = "${terraform.workspace}"
  }
}

# Cluster Nodes

resource "azurerm_virtual_machine" "clusternodes" {
  count                 = "${var.ninstances}"
  name                  = "${terraform.workspace}-node-${count.index}"
  location              = "${var.az_region}"
  resource_group_name   = "${azurerm_resource_group.myrg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.clusternodes.*.id, count.index)}"]
  availability_set_id   = "${azurerm_availability_set.myas.id}"
  vm_size               = "${var.instancetype}"

  storage_os_disk {
    name              = "NodeOsDisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "SUSE"
    offer     = "SLES-SAP-BYOS"
    sku       = "12-sp4"
    version   = "2019.03.06"
  }

  storage_data_disk {
    name              = "node-data-disk-${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "60"
  }

  os_profile {
    computer_name  = "${var.name}${var.ninstances > 1 ? "0${count.index  + 1}" : ""}"
    admin_username = "${var.admin_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${file(var.public_key_location)}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mytfstorageacc.primary_blob_endpoint}"
  }

  connection {
    type        = "ssh"
    user        = "${var.admin_user}"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp/"
  }

  provisioner "file" {
    content     = "${data.template_file.init_server.rendered}"
    destination = "/tmp/init-server.sh"
  }

  provisioner "file" {
    content = <<EOF
provider: "azure"
role: "hana_node"
name_prefix: ${var.name}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hostname: ${var.name}${var.ninstances > 1 ? "0${count.index  + 1}" : ""}
domain: "tf.local"
sbd_disk_device: /dev/sdd
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_disk_device: ${var.hana_disk_device}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
iscsi_srv_ip: ${azurerm_network_interface.iscsisrv.private_ip_address}
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
EOF

    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/salt /root",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/init-server.sh",
    ]
  }

  tags {
    workspace = "${terraform.workspace}"
  }
}
