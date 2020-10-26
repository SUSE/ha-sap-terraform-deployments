locals {
  hana_sizes = {
    demo_sap_hana = {
      vm_size                       = "Standard_E8s_v3"
      enable_accelerated_networking = false
      data_disks_configuration = {
        disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
        disks_size       = "128,128,128,128,128,128,128"
        caching          = "ReadOnly,ReadOnly,None,None,ReadOnly,ReadOnly,ReadOnly"
        writeaccelerator = "false,false,false,false,false,false,false"
        luns             = "0,1#2,3#4#5#6#7"
        names            = "data#log#shared#usrsap#backup"
        lv_sizes         = "100#100#100#100#100"
        paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
      }
    }
    small_sap_hana = {
      vm_size                       = "Standard_E32s_v3"
      enable_accelerated_networking = true
      data_disks_configuration = {
        disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
        disks_size       = "512,512,512,512,64,512"
        caching          = "ReadOnly,ReadOnly,ReadOnly,ReadOnly,ReadOnly,None"
        writeaccelerator = "false,false,false,false,false,false"
        luns             = "0,1,2#3#4#5"
        names            = "datalog#shared#usrsap#backup"
        lv_sizes         = "70,100#100#100#100#100"
        paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
      }
    }
    medium_sap_hana = {
      vm_size                       = "Standard_E64s_v3"
      enable_accelerated_networking = true
      data_disks_configuration = {
        disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
        disks_size       = "512,512,512,512,64,1024"
        caching          = "ReadOnly,ReadOnly,ReadOnly,ReadOnly,ReadOnly,None"
        writeaccelerator = "false,false,false,false,false,false"
        luns             = "0,1,2#3#4#5"
        names            = "data#log#shared#usrsap#backup"
        lv_sizes         = "70,100#100#100#100#100"
        paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
      }
    }
    large_sap_hana = {
      vm_size                       = "Standard_M64s"
      enable_accelerated_networking = false
      data_disks_configuration = {
        disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
        disks_size       = "512,512,512,512,512,512,1024,64,1024,1024"
        caching          = "ReadOnly,ReadOnly,ReadOnly,ReadOnly,None,None,ReadOnly,ReadOnly,ReadOnly,ReadOnly"
        writeaccelerator = "false,false,false,false,true,true,false,false,false,false"
        luns             = "0,1,2,3#4,5#6#7#8,9"
        names            = "data#log#shared#usrsap#backup"
        lv_sizes         = "100#100#100#100#100"
        paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
      }
    }
  }
  netweaver_sizes = {
    demo = {
      xscs_vm_size                = "Standard_D2s_v3"
      app_vm_size                 = "Standard_D2s_v3"
      data_disk_type              = "Premium_LRS"
      data_disk_size              = 128
      data_disk_caching           = "ReadWrite"
      xscs_accelerated_networking = false
      app_accelerated_networking  = false
      app_server_count            = 1
    }
    small = {
      xscs_vm_size                = "Standard_E2s_v3"
      app_vm_size                 = "Standard_E8s_v3"
      data_disk_type              = "Premium_LRS"
      data_disk_size              = 128
      data_disk_caching           = "ReadWrite"
      xscs_accelerated_networking = false
      app_accelerated_networking  = true
      app_server_count            = 1
    }
    medium = {
      xscs_vm_size                = "Standard_E2s_v3"
      app_vm_size                 = "Standard_E8s_v3"
      data_disk_type              = "Premium_LRS"
      data_disk_size              = 128
      data_disk_caching           = "ReadWrite"
      xscs_accelerated_networking = false
      app_accelerated_networking  = true
      app_server_count            = 4
    }
    large = {
      xscs_vm_size                = "Standard_E2s_v3"
      app_vm_size                 = "Standard_E16s_v3"
      data_disk_type              = "Premium_LRS"
      data_disk_size              = 128
      data_disk_caching           = "ReadWrite"
      xscs_accelerated_networking = false
      app_accelerated_networking  = true
      app_server_count            = 6
    }
  }
  sles4sap_version = "SLES15SP2"
  scc_registration_code = ""
  sles_version = {
    SLES15 = {
      publisher = "SUSE"
      offer     = local.scc_registration_code == "" ? "SLES-SAP" : "SLES-SAP-BYOS"
      sku       = "gen2-15"
      version   = "latest"
    }
    SLES15SP1 = {
      publisher = "SUSE"
      offer     = local.scc_registration_code == "" ? "sles-sap-15-sp1" : "sles-sap-15-sp1-byos"
      sku       = "gen2"
      version   = "latest"
    }
    SLES15SP2 = {
      publisher = "SUSE"
      offer     = local.scc_registration_code == "" ? "sles-sap-15-sp2" : "sles-sap-15-sp2-byos"
      sku       = "gen2"
      version   = "latest"
    }
  }
  os_image = join(":", [
    local.sles_version[local.sles4sap_version]["publisher"],
    local.sles_version[local.sles4sap_version]["offer"],
    local.sles_version[local.sles4sap_version]["sku"],
    local.sles_version[local.sles4sap_version]["version"]])

  storage_account_path = "//${var.storage_account_name}.file.core.windows.net/"

  hana_inst_master  = length(regexall(".*\\..*", basename(var.hana_installation_software_path))) > 0 ? dirname(var.hana_installation_software_path) : var.hana_installation_software_path
  hana_archive_file = length(regexall(".*\\..*", basename(var.hana_installation_software_path))) > 0 ? basename(var.hana_installation_software_path) : ""
}

resource "tls_private_key" "salt_execution_ssh_keys" {
  algorithm   = "RSA"
}

module "bluehorizon" {
  source                             = "git::https://github.com/SUSE/ha-sap-terraform-deployments.git///azure?ref=develop"
  az_region                          = var.azure_region
  admin_user                         = var.os_admnistrator_name
  deployment_name                    = var.deployment_name
  public_key                         = tls_private_key.salt_execution_ssh_keys.public_key_openssh
  private_key                        = tls_private_key.salt_execution_ssh_keys.private_key_pem
  authorized_keys                    = ["${var.ssh_authorized_key}"]
  cluster_ssh_pub                    = "salt://sshkeys/cluster.id_rsa.pub"
  cluster_ssh_key                    = "salt://sshkeys/cluster.id_rsa"
  hana_count                         = var.deployment_type == "HA" ? 2 : 1
  os_image                           = local.os_image
  hana_vm_size                       = local.hana_sizes[var.instance_type]["vm_size"]
  hana_data_disks_configuration      = local.hana_sizes[var.instance_type]["data_disks_configuration"]
  hana_enable_accelerated_networking = local.hana_sizes[var.instance_type]["enable_accelerated_networking"]
  hana_sid                           = var.system_identifier
  hana_instance_number               = var.instance_number
  hana_master_password               = var.sap_admin_password
  hana_primary_site                  = "${var.deployment_name}-siteA"
  hana_secondary_site                = "${var.deployment_name}-siteB"
  hana_cluster_fencing_mechanism     = "sbd"
  hana_ha_enabled                    = var.deployment_type == "HA" ? true : false
  hana_inst_master                   = "${local.storage_account_path}${local.hana_inst_master}"
  hana_archive_file                  = local.hana_archive_file
  storage_account_name               = var.storage_account_name
  storage_account_key                = var.storage_account_key
  monitoring_enabled                 = true
  pre_deployment                     = true
  provisioning_log_level             = "info"
  #ha_sap_deployment_repo             = "https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:devel"
  netweaver_master_password          = "not used"
}
