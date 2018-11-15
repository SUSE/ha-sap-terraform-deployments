#!/bin/bash -xe

function install_hana()
{
    # Install HANA
    mkdir /root/sap_inst
    rm -f /var/tmp/hana.done
    aws s3 sync ${hana_inst} /root/sap_inst
    chmod +x /tmp/prepare_env.sh
    chmod +x /tmp/install_hana.sh
    chmod -R 755 /root/sap_inst
    /tmp/prepare_env.sh xvdd /hana xfs
    cp /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_hostname0.conf /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_$(hostname -s).conf
    sed -i 's/^hostname=.*/hostname='$(hostname -s)'/' /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_$(hostname -s).conf
    /tmp/install_hana.sh inst SPS02 PRD
    local HANAPWD=$(grep ^master_password /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_$(hostname -s).conf | cut -d= -f2)
    su -lc "hdbuserstore set backupkey0 $(hostname -s) SYSTEM $HANAPWD" prdadm
    su -lc "hdbuserstore set backupkey1 $(hostname -s):30015 SYSTEM $HANAPWD" prdadm
    su -lc "hdbuserstore set backupkey2 $(hostname -s)@SYSTEMDB SYSTEM $HANAPWD" prdadm
    su -lc "hdbuserstore set backupkey3 $(hostname -s):30015@SYSTEMDB SYSTEM $HANAPWD" prdadm
    su -lc "hdbuserstore set backupkey5 $(hostname -s):30013@SYSTEMDB SYSTEM $HANAPWD" prdadm
    su -lc "hdbuserstore set backupkey4 $(hostname -s):30015 SYSTEM $HANAPWD" prdadm
    echo "$(hostname -s)" > /var/tmp/hana.done
    if [[ "$(hostname -s)" == "ip-10-0-1-0" ]]; then
        ssh-keyscan -H ip-10-0-1-1 >> ~/.ssh/known_hosts
        while (! ssh ip-10-0-1-1 "cat /var/tmp/hana.done"); do sleep 10; done
        su -lc "hdbsql -u system -i 00 -d systemdb -p $HANAPWD \"BACKUP DATA FOR FULL SYSTEM USING FILE ('backup')\"" prdadm
        su -lc "hdbnsutil -sr_enable --name=MST" prdadm
        sleep 30
        scp /usr/sap/PRD/SYS/global/security/rsecssfs/data/SSFS_PRD.DAT ip-10-0-1-1:/usr/sap/PRD/SYS/global/security/rsecssfs/data/SSFS_PRD.DAT
        scp /usr/sap/PRD/SYS/global/security/rsecssfs/key/SSFS_PRD.KEY ip-10-0-1-1:/usr/sap/PRD/SYS/global/security/rsecssfs/key/SSFS_PRD.KEY
        ssh ip-10-0-1-1 'su -lc "HDB stop" prdadm'
        ssh ip-10-0-1-1 'su -lc "hdbnsutil -sr_register --name=SLV --remoteHost=ip-10-0-1-0 --remoteInstance=00 --replicationMode=sync --operationMode=logreplay" prdadm'
        ssh ip-10-0-1-1 'su -lc "HDB start" prdadm'
        # Wait for initialization to complete
        sleep 60
        su -lc "HDBSettings.sh systemReplicationStatus.py" prdadm || true
    fi
    # sudo zypper -n install yast2-sap-ha
}

# Leave a log...
exec > /root/init-nodes.log 2>&1

# Set $HOME as it's not automatically set by cloud init
export HOME="/root"

# Configure aws-cli
mkdir ~/.aws
echo "[default]" > ~/.aws/config
echo "region=${aws_region}" >> ~/.aws/config
# Wait for AWS credentials file to be provisioned and then move it to its corresponding place
while (! mv -f /tmp/credentials ~/.aws/); do echo "Waiting for AWS credentials..."; sleep 5; done

# Set unique initiator name
IQN=$(echo "iqn.$(date +"%Y-%m").$(grep search /etc/resolv.conf | awk -F. 'BEGIN {OFS="."} ($1 = substr($1,8)) {print $2,$1}'):$(iscsi-iname|cut -d: -f2)")
sed -i -e '/^InitiatorName/d' /etc/iscsi/initiatorname.iscsi
echo "InitiatorName=$IQN" >> /etc/iscsi/initiatorname.iscsi

# Add watchdog for HA
echo softdog > /etc/modules-load.d/softdog.conf
systemctl restart systemd-modules-load.service

# Wait for iSCSI server
# First test the iSCSI server is reachable for 5 minutes. If it's not, abort
for ((i=1; i<=30; i++)); do ping -q -c 1 ${iscsiip} && break; done || (echo "Aborting init script. Cannot reach iSCSI server" && exit 1)
while (! timeout 10 bash -c 'cat < /dev/null > /dev/tcp/${iscsiip}/3260'); do echo "Waiting for iSCSI"; sleep 5; done

# Configure iSCSI initiator
systemctl stop iscsid
sed -i -r '/^node.startup/s/^node.startup = .+/node.startup = automatic/' /etc/iscsi/iscsid.conf
systemctl enable --now iscsid
iscsiadm -m discovery -t st -p "${iscsiip}:3260" -l -o new

# Wait for iSCSI devices
while (! ls /dev/disk/by-path/ip-${iscsiip}:*-lun-9 ); do sleep 5; done
ls /dev/disk/by-path/

chmod +x /tmp/sshkeys.sh
/tmp/sshkeys.sh

# Check whether we should install HANA
test "${init_type}" != "skip-hana" && install_hana

test "${init_type}" == "skip-cluster" && exit 0

# Initialize cluster on master and exit
# Master node is 10.0.1.0. Check instances.tf to see why
SBDDEV=$(ls /dev/disk/by-path/ip-${iscsiip}:*-lun-9)
if [ "$(hostname)" == "ip-10-0-1-0" ]; then
    sudo ha-cluster-init -y -u -s $SBDDEV && exit 0
    echo "Failed to initialize cluster"
    exit 1
fi

# Wait and join cluster. Do so only if HAWK is already up in the master
# Cluster master is 10.0.1.0. Check instances.tf to see why
while (! timeout 10 bash -c 'cat < /dev/null > /dev/tcp/10.0.1.0/7630'); do echo "Waiting for Cluster Init"; sleep 5; done
# Found HAWK on the master node. Wait 30 seconds for it to finish initialization before ha-cluster-join
sleep 30
ha-cluster-join -yc "ip-10-0-1-0" || true
sleep 5
systemctl is-active pacemaker || systemctl restart pacemaker
if [[ "${init_type}" != "skip-hana" ]]; then
    test -f /tmp/dlm.template && sudo crm configure load update /tmp/dlm.template
    sleep 5
    sed -i -e 's/%NODE0%/ip-10-0-1-0/g' -e 's/%NODE1%/ip-10-0-1-1/g' -e 's/%HANAIP%/10.0.0.250/g' /tmp/hanasr.template
    test -f /tmp/hanasr.template && sudo crm configure load update /tmp/hanasr.template
fi
