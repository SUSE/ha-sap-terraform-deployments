#!/bin/bash
#
# This script merges these 2 scripts from Google:
# https://storage.googleapis.com/sapdeploy/dm-templates/sap_hana_ha/startup.sh
# https://storage.googleapis.com/sapdeploy/dm-templates/sap_hana_ha/startup_secondary.sh

# ------------------------------------------------------------------------
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:  Google Cloud Platform - SAP Deployment Functions
# Build Date:   Fri Oct 26 16:49:54 BST 2018
# ------------------------------------------------------------------------

## Check to see if a custom script path was provieded by the template
if [[ "${1}" ]]; then
  readonly DEPLOY_URL="${1}"
else
  readonly DEPLOY_URL="https://storage.googleapis.com/sapdeploy/dm-templates"
fi

## Import includes
source /dev/stdin <<< "$(curl -s ${DEPLOY_URL}/lib/sap_lib_main.sh)"
source /dev/stdin <<< "$(curl -s ${DEPLOY_URL}/lib/sap_lib_hdb.sh)"
source /dev/stdin <<< "$(curl -s ${DEPLOY_URL}/lib/sap_lib_ha.sh | sed -r 's/(AUTOMATED_REGISTER)=true/\1=false/')"

### Base GCP and OS Configuration
main::get_os_version
main::get_settings

if [[ -n ${VM_METADATA[suse_regcode]} ]] ; then
	SUSEConnect -r "${VM_METADATA[suse_regcode]}"
	( . /etc/os-release
        if [[ $VERSION_ID =~ ^12 ]] ; then
                SUSEConnect -p sle-module-public-cloud/${VERSION_ID%.*}/x86_64
        else
                SUSEConnect -p sle-module-public-cloud/$VERSION_ID/x86_64
        fi
        )
fi

if [[ ${VM_METADATA[init_type]} == "skip-all" ]] ; then
￼ 	exit 0
fi

main::install_gsdk /usr/local
if [[ ${VM_METADATA[init_type]} == all ]] ; then
main::set_boot_parameters
fi
main::install_packages
main::config_ssh
main::create_static_ip

if [[ ${VM_METADATA[init_type]} == all ]] ; then
##prepare for SAP HANA
hdb::check_settings
hdb::set_kernel_parameters
hdb::calculate_volume_sizes
hdb::create_shared_volume
hdb::create_sap_data_log_volumes
hdb::create_backup_volume

## Install SAP HANA
hdb::create_install_cfg
hdb::download_media
hdb::extract_media
hdb::install
hdb::upgrade
hdb::config_backup
fi

## Setup HA
ha::check_settings
if [[ $HOSTNAME =~ node-0$ ]] ; then
	ha::install_secondary_sshkeys
else
	ha::install_primary_sshkeys
fi
ha::download_scripts
if [[ ${VM_METADATA[init_type]} == all ]] ; then
ha::create_hdb_user
ha::hdbuserstore
hdb::backup /hanabackup/data/pre_ha_config
fi
if [[ $HOSTNAME =~ node-0$ ]] ; then
        if [[ ${VM_METADATA[init_type]} == all ]] ; then
	ha::enable_hsr
        fi
	ha::ready
	ha::config_pacemaker_primary
	ha::check_cluster
	ha::pacemaker_maintenance true
	ha::pacemaker_add_stonith
	ha::pacemaker_add_vip
        if [[ ${VM_METADATA[init_type]} == all ]] ; then
	ha::pacemaker_config_bootstrap_hdb
	ha::pacemaker_add_hana
	ha::check_hdb_replication
        fi
	ha::pacemaker_maintenance false
else
	ha::wait_for_primary
	ha::copy_hdb_ssfs_keys
        if [[ ${VM_METADATA[init_type]} == all ]] ; then
	hdb::stop
	ha::config_hsr
	hdb::start_nowait
        fi
	ha::config_pacemaker_secondary
fi

## Post deployment & installation cleanup
main::complete
