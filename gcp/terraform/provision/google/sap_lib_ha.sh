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

ha::check_settings() {

  # Set additional global constants
  readonly PRIMARY_NODE_IP=$(ping "${VM_METADATA[sap_primary_instance]}" -c 1 | head -1 | awk  '{ print $3 }' | sed 's/(//' | sed 's/)//')
  readonly SECONDARY_NODE_IP=$(ping "${VM_METADATA[sap_secondary_instance]}" -c 1 | head -1 | awk  '{ print $3 }' | sed 's/(//' | sed 's/)//')

  ## check required parameters are present
  if [ -z "${VM_METADATA[sap_vip]}" ] || [ -z "${VM_METADATA[sap_primary_instance]}" ] || [ -z "${PRIMARY_NODE_IP}" ] || [ -z "${VM_METADATA[sap_primary_zone]}" ] || [ -z "${VM_METADATA[sap_secondary_instance]}" ] || [ -z "${SECONDARY_NODE_IP}" ]; then
    main::errhandle_log_warning "High Availability variables were missing or incomplete. Both SAP HANA VM's will be installed and configured but HA will need to be manually setup "
    main::complete
  fi

  mkdir -p /root/.deploy
}


ha::download_scripts() {
  main::errhandle_log_info "Downloading pacemaker-gcp"
  mkdir -p /usr/lib/ocf/resource.d/gcp
  mkdir -p /usr/lib64/stonith/plugins/external
  cp /root/provision/alias /usr/lib/ocf/resource.d/gcp/alias
  cp /root/provision/route /usr/lib/ocf/resource.d/gcp/route
  cp /root/provision/gcpstonith /usr/lib64/stonith/plugins/external/gcpstonith
  chmod +x /usr/lib/ocf/resource.d/gcp/alias
  chmod +x /usr/lib/ocf/resource.d/gcp/route
  chmod +x /usr/lib64/stonith/plugins/external/gcpstonith
}


ha::create_hdb_user() {
  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    hana_monitoring_user="slehasync"
  elif [ "${LINUX_DISTRO}" = "RHEL" ]; then
    hana_monitoring_user="rhelhasync"
  fi

  main::errhandle_log_info "Adding user ${hana_monitoring_user} to ${VM_METADATA[sap_hana_sid]}"

  ## create .sql file
  echo "CREATE USER ${hana_monitoring_user} PASSWORD \"${VM_METADATA[sap_hana_system_password]}\";" > /root/.deploy/"${HOSTNAME}"_hdbadduser.sql
  echo "GRANT DATA ADMIN TO ${hana_monitoring_user};" >> /root/.deploy/"${HOSTNAME}"_hdbadduser.sql
  echo "ALTER USER ${hana_monitoring_user} DISABLE PASSWORD LIFETIME;" >> /root/.deploy/"${HOSTNAME}"_hdbadduser.sql

  ## run .sql file
  PATH="$PATH:/usr/sap/${VM_METADATA[sap_hana_sid]}/HDB${VM_METADATA[sap_hana_instance_number]}/exe"
  bash -c "source /usr/sap/*/home/.sapenv.sh && hdbsql -u system -p '${VM_METADATA[sap_hana_system_password]}' -i ${VM_METADATA[sap_hana_instance_number]} -I /root/.deploy/${HOSTNAME}_hdbadduser.sql"
}


ha::hdbuserstore() {

  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    hana_user_store_key="SLEHALOC"
  elif [ "${LINUX_DISTRO}" = "RHEL" ]; then
    hana_user_store_key="SAPHANARH2SR"
  fi

  main::errhandle_log_info "Adding hdbuserstore entry '${hana_user_store_key}' ponting to localhost:3${VM_METADATA[sap_hana_instance_number]}15"

  #add user store
  PATH="$PATH:/usr/sap/${VM_METADATA[sap_hana_sid]}/HDB${VM_METADATA[sap_hana_instance_number]}/exe"
  bash -c "source /usr/sap/*/home/.sapenv.sh && hdbuserstore SET ${hana_user_store_key} localhost:3${VM_METADATA[sap_hana_instance_number]}15 ${hana_monitoring_user} '${VM_METADATA[sap_hana_system_password]}'"

  #check userstore
  bash -c "source /usr/sap/*/home/.sapenv.sh && hdbsql -U ${hana_user_store_key} -o /root/.deploy/hdbsql.out -a 'select * from dummy'"

  if  ! grep -q \"X\" /root/.deploy/hdbsql.out; then
    main::errhandle_log_warning "Unable to connect to HANA after adding hdbuserstore entry. Both SAP HANA systems have been installed and configured but the remainder of the HA setup will need to be manually performed"
    main::complete
  fi

  main::errhandle_log_info "--- hdbuserstore connection test successful"
}


ha::install_secondary_sshkeys() {
  main::errhandle_log_info "Adding ${VM_METADATA[sap_primary_instance]} ssh keys to ${VM_METADATA[sap_secondary_instance]}"
  gcloud compute instances add-metadata "${VM_METADATA[sap_secondary_instance]}" --metadata "ssh-keys=root:$(cat ~/.ssh/id_rsa.pub)" --zone "${VM_METADATA[sap_secondary_zone]}"
  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
}


ha::install_primary_sshkeys() {
  main::errhandle_log_info "Adding ${VM_METADATA[sap_secondary_instance]} ssh keys to ${VM_METADATA[sap_primary_instance]}"
  gcloud compute instances add-metadata "${VM_METADATA[sap_primary_instance]}" --metadata "ssh-keys=root:$(cat /root/.ssh/id_rsa.pub)" --zone "${VM_METADATA[sap_primary_zone]}"
  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
}


ha::wait_for_secondary() {
  local count=0

  main::errhandle_log_info "Waiting for ready signal from ${VM_METADATA[sap_secondary_instance]} before continuing"

  while [[ ! -f /root/.deploy/.${VM_METADATA[sap_secondary_instance]}.ready ]]; do
		count=$((count +1))
    scp -o StrictHostKeyChecking=no "${VM_METADATA[sap_secondary_instance]}":/root/.deploy/."${VM_METADATA[sap_secondary_instance]}".ready /root/.deploy
    main::errhandle_log_info "--- ${VM_METADATA[sap_secondary_instance]} is not ready - sleeping for 60 seconds then trying again"
    sleep 60s
    if [ ${count} -gt 15 ]; then
      main::errhandle_log_warning "${VM_METADATA[sap_secondary_instance]} wasn't ready in time. Both SAP HANA systems have been installed and configured but the remainder of the HA setup will need to be manually performed"
      main::complete
    fi
  done

  main::errhandle_log_info "--- ${VM_METADATA[sap_secondary_instance]} is now ready - continuing HA setup"
}


ha::wait_for_primary() {
  local count=0

  main::errhandle_log_info "Waiting for ready signal from ${VM_METADATA[sap_primary_instance]} before continuing"
  scp -o StrictHostKeyChecking=no "${VM_METADATA[sap_primary_instance]}":/root/.deploy/."${VM_METADATA[sap_primary_instance]}".ready /root/.deploy

  while [[ ! -f /root/.deploy/."${VM_METADATA[sap_primary_instance]}".ready ]]; do
		count=$((count +1))
    scp -o StrictHostKeyChecking=no "${VM_METADATA[sap_primary_instance]}":/root/.deploy/."${VM_METADATA[sap_primary_instance]}".ready /root/.deploy
    main::errhandle_log_info "--- ${VM_METADATA[sap_primary_instance]} is not not ready - sleeping for 60 seconds then trying again"
    sleep 60s
    if [ ${count} -gt 10 ]; then
      main::errhandle_log_warning "${VM_METADATA[sap_primary_instance]} wasn't ready in time. Both SAP HANA systems have been installed and configured but the remainder of the HA setup will need to be manually performed"
      main::complete
    fi
  done

  main::errhandle_log_info "--- ${VM_METADATA[sap_primary_instance]} is now ready - continuing HA setup"
}


ha::ready(){
  echo "ready" > /root/.deploy/."${HOSTNAME}".ready
}


ha::config_cluster(){
  main::errhandle_log_info "Configuring cluster primivatives"
}


ha::copy_hdb_ssfs_keys(){
  main::errhandle_log_info "Transfering SSFS keys from ${VM_METADATA[sap_primary_instance]}"
  rm /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/data/SSFS_"${VM_METADATA[sap_hana_sid]}".DAT
  rm /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/key/SSFS_"${VM_METADATA[sap_hana_sid]}".KEY
  scp -o StrictHostKeyChecking=no "${VM_METADATA[sap_primary_instance]}":/usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/data/SSFS_"${VM_METADATA[sap_hana_sid]}".DAT /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/data/SSFS_"${VM_METADATA[sap_hana_sid]}".DAT
  scp -o StrictHostKeyChecking=no "${VM_METADATA[sap_primary_instance]}":/usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/key/SSFS_"${VM_METADATA[sap_hana_sid]}".KEY /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/key/SSFS_"${VM_METADATA[sap_hana_sid]}".KEY
  chown "${VM_METADATA[sap_hana_sid],,}"adm:sapsys /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/data/SSFS_"${VM_METADATA[sap_hana_sid]}".DAT
  chown "${VM_METADATA[sap_hana_sid],,}"adm:sapsys /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/key/SSFS_"${VM_METADATA[sap_hana_sid]}".KEY
  chmod g+wrx,u+wrx /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/data/SSFS_"${VM_METADATA[sap_hana_sid]}".DAT
  chmod g+wrx,u+wrx  /usr/sap/"${VM_METADATA[sap_hana_sid]}"/SYS/global/security/rsecssfs/key/SSFS_"${VM_METADATA[sap_hana_sid]}".KEY
}


ha::enable_hsr() {
  main::errhandle_log_info "Enabling HANA System Replication support "
  runuser -l "${VM_METADATA[sap_hana_sid],,}adm" -c "hdbnsutil -sr_enable --name=${HOSTNAME}"
}


ha::config_hsr() {
  main::errhandle_log_info "Configuring SAP HANA system replication primary -> secondary"
  runuser -l "${VM_METADATA[sap_hana_sid],,}adm" -c "hdbnsutil -sr_register --remoteHost=${VM_METADATA[sap_primary_instance]} --remoteInstance=${VM_METADATA[sap_hana_instance_number]} --replicationMode=syncmem --operationMode=logreplay --name=${VM_METADATA[sap_secondary_instance]}"
}


ha::check_hdb_replication(){
  main::errhandle_log_info "Checking SAP HANA replication status"
  # check status
  bash -c "source /usr/sap/*/home/.sapenv.sh && /usr/sap/${VM_METADATA[sap_hana_sid]}/HDB${VM_METADATA[sap_hana_instance_number]}/exe/hdbsql -o /root/.deploy/hdbsql.out -a -U ${hana_user_store_key} 'select distinct REPLICATION_STATUS from SYS.M_SERVICE_REPLICATION'"
  
  local count=0
    
  while ! grep -q \"ACTIVE\" /root/.deploy/hdbsql.out; do
    main::errhandle_log_info "--- Replication is still in progressing. Waiting 60 seconds then trying again"
    bash -c "source /usr/sap/*/home/.sapenv.sh && /usr/sap/${VM_METADATA[sap_hana_sid]}/HDB${VM_METADATA[sap_hana_instance_number]}/exe/hdbsql -o /root/.deploy/hdbsql.out -a -U ${hana_user_store_key} 'select distinct REPLICATION_STATUS from SYS.M_SERVICE_REPLICATION'"
    sleep 60s
    if [ ${count} -gt 20 ]; then
      main::errhandle_log_error "SAP HANA System Replication didn't complete. Please check network connectivity and firewall rules"
    fi
  done
  main::errhandle_log_info "--- Replication in sync. Continuing with HA configuration"
}


ha::check_cluster(){
  main::errhandle_log_info "Checking cluster status"
  
  local count=0

  while ! crm_mon -s | grep -q "2 nodes online"; do
    main::errhandle_log_info "--- Cluster is not yet online. Waiting 60 seconds then trying again"
    sleep 60s
    if [ ${count} -gt 20 ]; then
      main::errhandle_log_error "Pacemaker cluster failed to come online. Please check network connectivity and firewall rules"
    fi
  done
  main::errhandle_log_info "--- Two cluster nodes are online and ready. Continuing with HA configuration"
}


ha::config_corosync(){
  main::errhandle_log_info "--- Creating /etc/corosync/corosync.conf"
  cat <<EOF > /etc/corosync/corosync.conf
    totem {
      version: 2
      secauth: off
      crypto_hash: sha1
      crypto_cipher: aes256
      cluster_name:	hacluster
      clear_node_high_bit: yes
      token: 5000
      token_retransmits_before_loss_const: 6
      join: 60
      consensus: 7500
      max_messages:	20
      transport: udpu
      interface {
        ringnumber:	0
        bindnetaddr: ${1}
        mcastport: 5405
        ttl: 1
      }
    }
    logging {
      fileline:	off
      to_stderr: no
      to_logfile: no
      logfile: /var/log/cluster/corosync.log
      to_syslog: yes
      debug: off
      timestamp: on
      logger_subsys {
        subsys: QUORUM
        debug: off
      }
    }
    nodelist {
      node {
        ring0_addr: ${VM_METADATA[sap_primary_instance]}
        nodeid: 1
      }
      node {
        ring0_addr: ${VM_METADATA[sap_secondary_instance]}
        nodeid: 2
      }
    }
    quorum {
      provider: corosync_votequorum
      expected_votes: 2
      two_node: 1
    }
EOF
}


ha::config_pacemaker_primary() {
  main::errhandle_log_info "Creating cluster on primary node"
  main::errhandle_log_info "--- Creating corosync-keygen"
  corosync-keygen
  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    main::errhandle_log_info "--- Starting csync2"
    script -q -c 'ha-cluster-init -y csync2' > /dev/null 2>&1 &
    ha::config_corosync "${PRIMARY_NODE_IP}"
    main::errhandle_log_info "--- Starting cluster"
    sleep 5s
    systemctl enable pacemaker
    systemctl start pacemaker
  elif [ "${LINUX_DISTRO}" = "RHEL" ]; then
    main::errhandle_log_info "--- Creating /etc/corosync/corosync.conf"
    pcs cluster setup --name hana --local "${VM_METADATA[sap_primary_instance]} ${VM_METADATA[sap_secondary_instance]}" --force
    main::errhandle_log_info "--- Starting cluster services & enabling on startup"
    service pacemaker start
    service pscd start
    systemctl enable pcsd.service
    systemctl enable pacemaker
    main::errhandle_log_info "--- Setting hacluster password"
    echo linux | passwd --stdin hacluster
  fi
}


ha::pacemaker_maintenance() {
  local mode="${1}"

  main::errhandle_log_info "Setting cluster maintenance mode to ${mode}"
  crm configure property maintenance-mode="${mode}"
}


ha::config_pacemaker_secondary() {
  main::errhandle_log_info "Joining ${VM_METADATA[sap_secondary_instance]} to cluster"

  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    ha::config_corosync "${SECONDARY_NODE_IP}"
    bash -c "ha-cluster-join -y -c ${VM_METADATA[sap_primary_instance]} csync2"
    systemctl enable pacemaker
    systemctl start pacemaker
    systemctl enable hawk
    systemctl start hawk    
  elif [ "${LINUX_DISTRO}" = "RHEL" ]; then
    corosync-keygen
    pcs cluster setup --name hana --local "${VM_METADATA[sap_primary_instance]} ${VM_METADATA[sap_secondary_instance]}" --force
    service pacemaker start
    service pscd start
    systemctl enable pcsd.service
    systemctl enable pacemaker
  fi

  main::complete
}


ha::pacemaker_add_stonith() {
  main::errhandle_log_info "Cluster: Adding STONITH devices"
  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    crm configure primitive STONITH-"${VM_METADATA[sap_primary_instance]}" stonith:external/gcpstonith op monitor interval="300s" timeout="60s" on-fail="restart" op start interval="0" timeout="60s" onfail="restart" params instance_name="${VM_METADATA[sap_primary_instance]}" gcloud_path="${GCLOUD}" logging="yes"
    crm configure primitive STONITH-"${VM_METADATA[sap_secondary_instance]}" stonith:external/gcpstonith op monitor interval="300s" timeout="60s" on-fail="restart" op start interval="0" timeout="60s" onfail="restart" params instance_name="${VM_METADATA[sap_secondary_instance]}" gcloud_path="${GCLOUD}" logging="yes"
    crm configure location LOC_STONITH_"${VM_METADATA[sap_primary_instance]}" STONITH-"${VM_METADATA[sap_primary_instance]}" -inf: "${VM_METADATA[sap_primary_instance]}"
    crm configure location LOC_STONITH_"${VM_METADATA[sap_secondary_instance]}" STONITH-"${VM_METADATA[sap_secondary_instance]}" -inf: "${VM_METADATA[sap_secondary_instance]}"
  fi
}


ha::pacemaker_add_vip() {
  main::errhandle_log_info "Cluster: Adding virtual IP"
  if ! ping -c 1 -W 1 "${VM_METADATA[sap_vip]}"; then 
    if [ "${LINUX_DISTRO}" = "SLES" ]; then
      crm configure primitive rsc_vip_int-primary IPaddr2 params ip="${VM_METADATA[sap_vip]}" cidr_netmask=32 nic="eth0" op monitor interval=10s
      if [[ -n "${VM_METADATA[sap_vip_secondary_range]}" ]]; then
        crm configure primitive rsc_vip_gcp-primary ocf:gcp:alias op monitor interval="60s" timeout="60s" op start interval="0" timeout="180s" op stop interval="0" timeout="180s" params alias_ip="${VM_METADATA[sap_vip]}/32" hostlist="${VM_METADATA[sap_primary_instance]} ${VM_METADATA[sap_secondary_instance]}" gcloud_path="${GCLOUD}" alias_range_name="${VM_METADATA[sap_vip_secondary_range}" logging="yes" meta priority=10
      else
        crm configure primitive rsc_vip_gcp-primary ocf:gcp:alias op monitor interval="60s" timeout="60s" op start interval="0" timeout="180s" op stop interval="0" timeout="180s" params alias_ip="${VM_METADATA[sap_vip]}/32" hostlist="${VM_METADATA[sap_primary_instance]} ${VM_METADATA[sap_secondary_instance]}" gcloud_path="${GCLOUD}" logging="yes" meta priority=10
      fi
      crm configure group g-primary rsc_vip_int-primary rsc_vip_gcp-primary
    fi
  else
    main::errhandle_log_warning "- VIP is already associated with another VM. The cluster setup will continue but the floating/virtual IP address will not be added"
  fi
}


ha::pacemaker_config_bootstrap_hdb() {
  main::errhandle_log_info "Cluster: Configuring bootstrap for SAP HANA"
  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    crm configure property no-quorum-policy="ignore"
    crm configure property startup-fencing="true"
    crm configure property stonith-timeout="300s"
    crm configure property stonith-enabled="true"
    crm configure rsc_defaults resource-stickiness="1000"
    crm configure rsc_defaults migration-threshold="5000"
    crm configure op_defaults timeout="600"
  elif [ "${LINUX_DISTRO}" = "RHEL" ]; then
    pcs property set no-quorum-policy="ignore"
    pcs property set startup-fencing="true"
    pcs property set stonith-timeout="300s"
    pcs property set stonith-enabled="true"
    pcs resource defaults default-resource-stickness=1000
    pcs resource defaults default-migration-threshold=5000
    pcs resource op defaults timeout=600s
  fi
}


ha::pacemaker_config_bootstrap_nfs() {
  main::errhandle_log_info "Cluster: Configuring bootstrap for NFS"
  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    crm configure property no-quorum-policy="ignore"
    crm configure property startup-fencing="true"
    crm configure property stonith-timeout="300s"
    crm configure property stonith-enabled="true"
    crm configure rsc_defaults resource-stickiness="100"
    crm configure rsc_defaults migration-threshold="5000"
    crm configure op_defaults timeout="600"
  elif [ "${LINUX_DISTRO}" = "RHEL" ]; then
    pcs property set no-quorum-policy="ignore"
    pcs property set startup-fencing="true"
    pcs property set stonith-timeout="300s"
    pcs property set stonith-enabled="true"
    pcs resource defaults default-resource-stickness=1000
    pcs resource defaults default-migration-threshold=5000
    pcs resource op defaults timeout=600s
  fi
}


ha::pacemaker_add_hana() {
  main::errhandle_log_info "Cluster: Adding HANA nodes"

  if [ "${LINUX_DISTRO}" = "SLES" ]; then
    cat <<EOF > /root/.deploy/cluster.tmp
    primitive rsc_SAPHanaTopology_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} ocf:suse:SAPHanaTopology \
        operations \$id="rsc_sap2_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]}-operations" \
        op monitor interval="10" timeout="600" \
        op start interval="0" timeout="600" \
        op stop interval="0" timeout="300" \
        params SID="${VM_METADATA[sap_hana_sid]}" InstanceNumber="${VM_METADATA[sap_hana_instance_number]}"

    clone cln_SAPHanaTopology_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} rsc_SAPHanaTopology_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} \
        meta is-managed="true" clone-node-max="1" target-role="Started" interleave="true"
EOF

    crm configure load update /root/.deploy/cluster.tmp

    cat <<EOF > /root/.deploy/cluster.tmp
    primitive rsc_SAPHana_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} ocf:suse:SAPHana \
        operations \$id="rsc_sap_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]}-operations" \
        op start interval="0" timeout="3600" \
        op stop interval="0" timeout="3600" \
        op promote interval="0" timeout="3600" \
        op monitor interval="10" role="Master" timeout="700" \
        op monitor interval="11" role="Slave" timeout="700" \
        params SID="${VM_METADATA[sap_hana_sid]}" InstanceNumber="${VM_METADATA[sap_hana_instance_number]}" PREFER_SITE_TAKEOVER="true" \
        DUPLICATE_PRIMARY_TIMEOUT="7200" AUTOMATED_REGISTER="false"

    ms msl_SAPHana_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} rsc_SAPHana_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} \
        meta is-managed="true" notify="true" clone-max="2" clone-node-max="1" \
        target-role="Started" interleave="true"

    colocation col_saphana_ip_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} 4000: g-primary:Started \
        msl_SAPHana_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]}:Master
    order ord_SAPHana_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} Optional: cln_SAPHanaTopology_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]} \
        msl_SAPHana_${VM_METADATA[sap_hana_sid]}_HDB${VM_METADATA[sap_hana_instance_number]}
EOF

    crm configure load update /root/.deploy/cluster.tmp
  fi
}
