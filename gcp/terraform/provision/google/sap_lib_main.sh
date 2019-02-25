#!/bin/bash
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
# Build Date:   Wed Feb 20 13:53:45 GMT 2019
# ------------------------------------------------------------------------

set +e

main::set_boot_parameters() {
	main::errhandle_log_info 'Checking boot paramaters'

	## disable selinux
	if [[ -e /etc/sysconfig/selinux ]]; then
	  main::errhandle_log_info "--- Disabling SELinux"
		sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
	fi

	if [[ -e /etc/selinux/config ]]; then
		main::errhandle_log_info "--- Disabling SELinux"
		sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi
	## work around for LVM boot where LVM volues are not started on certain SLES/RHEL versions
  if [[ -e /etc/sysconfig/lvm ]]; then
    sed -ie 's/LVM_ACTIVATED_ON_DISCOVERED="disable"/LVM_ACTIVATED_ON_DISCOVERED="enable"/g' /etc/sysconfig/lvm
  fi

	## Configure cstates and huge pages
	if ! grep -q cstate /etc/default/grub ; then
		main::errhandle_log_info "--- Update grub"
		cmdline=$(grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub | head -1 | sed 's/GRUB_CMDLINE_LINUX_DEFAULT=//g' | sed 's/\"//g')
		cp /etc/default/grub /etc/default/grub.bak
		grep -v GRUBLINE_LINUX_DEFAULT /etc/default/grub.bak >/etc/default/grub			
		echo "GRUB_CMDLINE_LINUX_DEFAULT=\"${cmdline} transparent_hugepage=never intel_idle.max_cstate=1 processor.max_cstate=1 intel_iommu=off\"" >>/etc/default/grub
		grub2-mkconfig -o /boot/grub2/grub.cfg
		echo "${HOSTNAME}" >/etc/hostname
		main::errhandle_log_info '--- Parameters updated. Rebooting'
		reboot
		exit 0
	fi
}


main::errhandle_log_info() {
  local log_entry=${1}

	echo "INFO - ${log_entry}"
  if [[ -n "${GCLOUD}" ]]; then
	   ${GCLOUD} --quiet logging write "${HOSTNAME}" "${HOSTNAME} Deployment \"${log_entry}\"" --severity=INFO
  fi
}


main::errhandle_log_warning() {
  local log_entry=${1}

	if [[ -z "${deployment_warnings}" ]]; then
		deployment_warnings=1
	else
		deployment_warnings=$((deployment_warnings +1))
	fi

	echo "WARNING - ${log_entry}"
  if [[ -n "${GCLOUD}" ]]; then
    ${GCLOUD} --quiet logging write "${HOSTNAME}" "${HOSTNAME} Deployment \"${log_entry}\"" --severity=WARNING
  fi
}


main::errhandle_log_error() {
  local log_entry=${1}

	echo "ERROR - Deployment Exited - ${log_entry}"
  if [[ -n "${GCLOUD}" ]]; then
    ${GCLOUD}	--quiet logging write "${HOSTNAME}" "${HOSTNAME} Deployment \"${log_entry}\"" --severity=ERROR
  fi
	main::complete error
}


main::get_os_version() {
	if grep SLES /etc/os-release; then
		readonly LINUX_DISTRO="SLES"
		readonly LINUX_VERSION=$(grep VERSION_ID /etc/os-release | awk -F '\"' '{ print $2 }')
	elif grep -q "Red Hat" /etc/os-release; then
		readonly LINUX_DISTRO="RHEL"
		readonly LINUX_VERSION=$(grep VERSION_ID /etc/os-release | awk -F '\"' '{ print $2 }')
	else
		main::errhandle_log_warning "Unsupported Linux distribution. Only SLES and RHEL are supported."
	fi
}


main::config_ssh() {
	ssh-keygen -q -N "" < /dev/zero
	sed -ie 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
	service sshd restart
	cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
	/usr/sbin/rcgoogle-accounts-daemon restart
}


main::install_ssh_key(){
  local host=${1}
	local host_zone

	host_zone=$(${GCLOUD} compute instances list --filter="name=('${host}')" --format "value(zone)")
	main::errhandle_log_info "Installing ${HOSTNAME} SSH key on ${host}"
  ${GCLOUD} --quiet compute instances add-metadata "${host}" --metadata "ssh-keys=root:$(cat ~/.ssh/id_rsa.pub)"  --zone "${host_zone}"
}


main::install_packages() {
	main::errhandle_log_info 'Installing required operating system packages'

  ## SuSE work around to avoid a startup race condition
  if [[ ${LINUX_DISTRO} = "SLES" ]]; then
    local count=0

    ## check if SuSE repos are registered
		while [[ $(find /etc/zypp/repos.d/ -maxdepth 1 | wc -l) -lt 2 ]]; do
			main::errhandle_log_info "--- SuSE repositories are not registered. Waiting 10 seconds before trying again"
			sleep 10s
			count=$((count +1))
			if [ ${count} -gt 60 ]; then
				main::errhandle_log_error "SuSE repositories didn't register within an acceptable time."
			fi
		done
		sleep 10s

    ## check if zypper is still running
  	while pgrep zypper; do
  		errhandle_log_info "--- zypper is still running. Waiting 10 seconds before continuing"
  		sleep 10s
  	done

		## Temporary fix fro SLES15 incompatible boto version
		if [[ "${LINUX_VERSION}" = "15" ]]; then 
    	cat <<EOF > /etc/default/instance_configs.cfg.template
InstanceSetup]
set_boto_config = false
EOF
			rm -f /etc/boto.cfg
		fi
	fi

  ## packages to install
	## TODO - Add above API packages to RHEL
	local sles_packages="libopenssl0_9_8 libopenssl1_0_0 joe tuned krb5-32bit unrar SAPHanaSR SAPHanaSR-doc pacemaker numactl csh python-pip python-pyasn1-modules ndctl" #python-oauth2client python-oauth2client-gce python-httplib2 python-requests python-google-api-python-client"
	local rhel_packages="unar.x86_64 tuned-profiles-sap-hana tuned-profiles-sap-hana-2.7.1-3.el7_3.3 joe resource-agents-sap-hana.x86_64 compat-sap-c++-6 numactl-libs.x86_64 libtool-ltdl.x86_64 nfs-utils.x86_64 pacemaker pcs lvm2.x86_64 compat-sap-c++-5.x86_64 csh autofs ndctl"

	## install packages
	if [[ ${LINUX_DISTRO} = "SLES" ]]; then
		for package in ${sles_packages}; do
		    zypper in -y "${package}"
		done
		zypper in -y sapconf saptune
	elif [[ ${LINUX_DISTRO} = "RHEL" ]]; then
		for package in $rhel_packages; do
		    yum -y install "${package}"
		done
	fi
	
	main::errhandle_log_info "Installing python Google Cloud API client"
	pip install --upgrade google-api-python-client
	pip install oauth2client --upgrade
}


main::create_vg() {
	local device=${1}
	local volume_group=${2}

	if [[ -b "$device" ]]; then
		main::errhandle_log_info "--- Creating physical volume group ${device}"
		pvcreate "${device}"
		main::errhandle_log_info "--- Creating volume group ${volume_group} on ${device}"
		vgcreate "${volume_group}" "${device}"
		/sbin/vgchange -ay
	else
			main::errhandle_log_error "Unable to access ${device}"
	fi 
}



main::create_vg() {
	local device=${1}
	local volume_group=${2}

	if [[ -b "$device" ]]; then
		main::errhandle_log_info "--- Creating physical volume group ${device}"
		pvcreate "${device}"
		main::errhandle_log_info "--- Creating volume group ${volume_group} on ${device}"
		vgcreate "${volume_group}" "${device}"
		/sbin/vgchange -ay
	else
			main::errhandle_log_error "Unable to access ${device}"
	fi 
}


main::create_filesystem() {
  local mount_point=${1}
  local device=${2}
  local filesystem=$3

	if [[ -h /dev/disk/by-id/google-"${HOSTNAME}"-"${device}" ]]; then
		main::errhandle_log_info "--- ${mount_point}"
	  pvcreate /dev/disk/by-id/google-"${HOSTNAME}"-"${device}"
		vgcreate vg_"${device}" /dev/disk/by-id/google-"${HOSTNAME}"-"${device}"
		lvcreate -l 100%FREE -n vol vg_"${device}"
    main::format_mount "${mount_point}" /dev/vg_"${device}"/vol "${filesystem}"
		main::check_mount "${mount_point}"
	else
		main::errhandle_log_error "Unable to access ${device}"
	fi

}


main::check_mount() {
  local mount_point=${1}
  local on_error=${2}

  ## check /etc/mtab to see if the filesystem is mounted
	if ! grep -q "${mount_point}" /etc/mtab; then
		case "${on_error}" in
	    error)
				main::errhandle_log_error "Unable to mount ${mount_point}"
	      ;;

	    info)
				main::errhandle_log_info "Unable to mount ${mount_point}"
				;;

	    warning)
				main::errhandle_log_warn "Unable to mount ${mount_point}"
				;;

	    *)
				main::errhandle_log_error "Unable to mount ${mount_point}"
		esac
	fi

}


main::format_mount() {
  local mount_point=${1}
  local device=${2}
  local filesystem=${3}
	local options=${4}

	if [[ -b "$device" ]]; then
		if [[ "${filesystem}" = "swap" ]]; then
			echo "${device} none ${filesystem} defaults,nofail 0 0" >>/etc/fstab
			mkswap "${device}"
			swapon "${device}"
		else
			main::errhandle_log_info "--- Creating ${mount_point}"
			mkfs -t "${filesystem}" "${device}"
			mkdir -p "${mount_point}"
			if [[ ! "${options}" = "tmp" ]]; then 
				echo "${device} ${mount_point} ${filesystem} defaults,nofail 0 2" >>/etc/fstab
				mount -a
			else
				mount -t "${filesystem}" "${device}" "${mount_point}"
			fi
			main::check_mount "${mount_point}"
		fi
	else
		main::errhandle_log_error "Unable to access ${device}"	
	fi 
}


main::get_settings() {
	main::errhandle_log_info "Fetching GCE Instance Settings"

	## set current zone as the default zone
	readonly CLOUDSDK_COMPUTE_ZONE=$(main::get_metadata "http://169.254.169.254/computeMetadata/v1/instance/zone" | cut -d'/' -f4)
	export CLOUDSDK_COMPUTE_ZONE
	main::errhandle_log_info "--- Instance determined to be running in ${CLOUDSDK_COMPUTE_ZONE}. Setting this as the default zone"

	readonly VM_REGION=${CLOUDSDK_COMPUTE_ZONE::-2}

	## get instance type & details
	readonly VM_INSTTYPE=$(main::get_metadata http://169.254.169.254/computeMetadata/v1/instance/machine-type | cut -d'/' -f4)
	main::errhandle_log_info "--- Instance type determined to be ${VM_INSTTYPE}"

	readonly VM_CPUPLAT=$(main::get_metadata "http://169.254.169.254/computeMetadata/v1/instance/cpu-platform")
	main::errhandle_log_info "--- Instance is determined to be part on CPU Platform ${VM_CPUPLAT}"

	readonly VM_CPUCOUNT=$(grep -c processor /proc/cpuinfo)
	main::errhandle_log_info "--- Instance determined to have ${VM_CPUCOUNT} cores"

  readonly VM_MEMSIZE=$(free -g | grep Mem | awk '{ print $2 }')
	main::errhandle_log_info "--- Instance determined to have ${VM_MEMSIZE}GB of memory"

	## get network settings
	readonly VM_NETWORK=$(main::get_metadata http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/network | cut -d'/' -f4)
	main::errhandle_log_info "--- Instance is determined to be part of network ${VM_NETWORK}"

	readonly VM_NETWORK_FULL=$(gcloud compute instances describe "${HOSTNAME}" | grep "subnetwork:" | head -1 | grep -o 'projects.*')

	readonly VM_SUBNET=$(grep -o 'subnetworks.*' <<< "${VM_NETWORK_FULL}" | cut -f2- -d"/")
	main::errhandle_log_info "--- Instance is determined to be part of subnetwork ${VM_SUBNET}"

	readonly VM_NETWORK_PROJECT=$(cut -d'/' -f2 <<< "${VM_NETWORK_FULL}")
	main::errhandle_log_info "--- Networking is hosted in project ${VM_NETWORK_PROJECT}"

	readonly VM_IP=$(main::get_metadata http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip)
	main::errhandle_log_info "--- Instance IP is determined to be ${VM_IP}"

	# fetch all custom metadata associated with the instance
	main::errhandle_log_info "Fetching GCE Instance Metadata"
	local value
	local key
	declare -g -A VM_METADATA

	for key in $(curl --fail -sH'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/attributes/ | grep -v ssh-keys); do
		value=$(main::get_metadata "${key}")
		VM_METADATA[$key]="${value}"

		if [[ "${key}" = *"password"* ]]; then
			main::errhandle_log_info "${key} determined to be *********"
		else
			main::errhandle_log_info "${key} determined to be '${value}'"
		fi
	done

	# remove startup script
	if [[ -n "${VM_METADATA[startup-script]}" ]]; then
		main::remove_metadata startup-script
	fi
}


main::create_static_ip() {
	main::errhandle_log_info "Creating static IP address ${VM_IP} in subnetwork ${VM_SUBNET}"
	${GCLOUD} --quiet compute --project "${VM_NETWORK_PROJECT}" addresses create "${HOSTNAME}" --addresses "${VM_IP}" --region "${VM_REGION}" --subnet "${VM_SUBNET}"
}


main::remove_metadata() {
	local key=${1}

	${GCLOUD} --quiet compute instances remove-metadata "${HOSTNAME}" --keys "${key}"
}


main::install_gsdk() {
	local install_location=${1}

	if [[ ! -d "${install_location}/google-cloud-sdk" ]]; then
		bash <(curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/install_google_cloud_sdk.bash) --disable-prompts --install-dir="${install_location}" >/dev/null
		## run an instances list just to ensure the software is up to date
		"${install_location}"/google-cloud-sdk/bin/gcloud --quiet beta compute instances list >/dev/null
		if [[ "$LINUX_DISTRO" = "SLES" ]]; then
			update-alternatives --install /usr/bin/gsutil gsutil /usr/local/google-cloud-sdk/bin/gsutil 1 --force
			update-alternatives --install /usr/bin/gcloud gcloud /usr/local/google-cloud-sdk/bin/gcloud 1 --force
		fi
	fi

	if [[ -f /usr/local/google-cloud-sdk/bin/gcloud ]]; then
		readonly GCLOUD="/usr/local/google-cloud-sdk/bin/gcloud"
		readonly GSUTIL="/usr/local/google-cloud-sdk/bin/gsutil"
		readonly BQ="/usr/local/google-cloud-sdk/bin/bq"
	elif [[ -f /usr/bin/gcloud ]]; then
		readonly GCLOUD="/usr/bin/gloud"
		readonly GSUTIL="/usr/bin/gsutil"
	fi
  main::errhandle_log_info "Installed Google SDK in ${install_location}"
}


main::check_default() {
	local default=${1}
	local current=${2}

	if [[ -z ${current} ]]; then
		echo "${default}"
	else
		echo "${current}"
	fi
}


main::get_metadata() {
	local key=${1}

	local value

	if [[ ${key} = *"169.254.169.254/computeMetadata"* ]]; then
  	value=$(curl --fail -sH'Metadata-Flavor: Google' "${key}")
	else
		value=$(curl --fail -sH'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/attributes/"${key}")
	fi
	echo "${value}"
}


main::complete() {
  local on_error=${1}

  if [[ -z "${on_error}" ]]; then
  	main::errhandle_log_info "INSTANCE DEPLOYMENT COMPLETE"
  fi

  ## prepare advanced logs
  if [[ "${VM_METADATA[sap_deployment_debug]}" = "True" ]]; then
    mkdir -p /root/.deploy
    main::errhandle_log_info "--- Debug mode is turned on. Preparing additional logs"
    env > /root/.deploy/"${HOSTNAME}"_debug_env.log
    grep startup /var/log/messages > /root/.deploy/"${HOSTNAME}"_debug_startup_script_output.log
    tar -czvf /root/.deploy/"${HOSTNAME}"_deployment_debug.tar.gz -C /root/.deploy/ .
    main::errhandle_log_info "--- Debug logs stored in /root/.deploy/"
		## Upload logs to GCS bucket & display complete message
    if [ -n "${VM_METADATA[sap_hana_deployment_bucket]}" ]; then
      main::errhandle_log_info "--- Uploading logs to Google Cloud Storage bucket"
      ${GSUTIL} cp /root/.deploy/"${HOSTNAME}"_deployment_debug.tar.gz  gs://"${VM_METADATA[sap_hana_deployment_bucket]}"/logs/
    fi
  fi

	## Run custom post deployment script
	if [[ -n "${VM_METADATA[post_deployment_script]}" ]]; then
    main::errhandle_log_info "--- Running custom post deployment script - ${VM_METADATA[post_deployment_script]}"
		if [[ "${VM_METADATA[post_deployment_script]:0:8}" = "https://" ]] || [[ "${VM_METADATA[post_deployment_script]:0:7}" = "http://" ]]; then
			source /dev/stdin <<< "$(curl -s "${VM_METADATA[post_deployment_script]}")"
		elif [[ "${VM_METADATA[post_deployment_script]:0:5}" = "gs://" ]]; then
			source /dev/stdin <<< "$("${GSUTIL}" cat "${VM_METADATA[post_deployment_script]}")"
		else
			main::errhandle_log_warning "--- Unknown post deployment script. URL must begin with https:// http:// or gs://"
		fi
	fi

	if [[ -z "${deployment_warnings}" ]]; then
		main::errhandle_log_info "--- Finished"
	else
		main::errhandle_log_warning "--- Finished (${deployment_warnings} warnings)"
	fi

	## exit sending right error code
	if [[ -z "${on_error}" ]]; then
  	exit 0
  else
		exit 1
	fi

}
