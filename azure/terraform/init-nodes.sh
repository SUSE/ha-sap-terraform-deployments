#!/bin/bash

cat > $HOME/at-init-nodes.sh <<EOP
#!/bin/bash -xe

# install_hana: sets up the environment and calls /root/sap_inst/install_hana.sh (expected in the install master share)
# to install hana on both nodes. Call as install_hana path_to_share username password

function install_hana()
{
    # Install HANA
    sudo mkdir /root/sap_inst
    rm -f /var/tmp/hana.done
    ### CHANGE LINE BELOW for mount point
    sudo mount -t cifs "\$1" /root/sap_inst -o vers=3.0,username=\$2,password=\$3,dir_mode=0777,file_mode=0777,sec=ntlmssp
    sudo chmod +x /tmp/prepare_env.sh
    sudo chmod +x /tmp/install_hana.sh
    sudo /tmp/prepare_env.sh sdc /hana xfs
    sudo cp /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_hostname0.conf /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_$(hostname -s).conf
    sudo sed -i 's/^hostname=.*/hostname='$(hostname -s)'/' /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_$(hostname -s).conf
    sudo /tmp/install_hana.sh inst SPS03 PRD
    local HANAPWD=\$(sudo grep ^master_password /root/sap_inst/hana_inst_config_PRD/hdblcm_hana2.0_$(hostname -s).conf | cut -d= -f2)
    sudo su -lc "hdbuserstore set backupkey0 $(hostname -s) SYSTEM \$HANAPWD" prdadm
    sudo su -lc "hdbuserstore set backupkey1 $(hostname -s):30015 SYSTEM \$HANAPWD" prdadm
    sudo su -lc "hdbuserstore set backupkey2 $(hostname -s)@SYSTEMDB SYSTEM \$HANAPWD" prdadm
    sudo su -lc "hdbuserstore set backupkey3 $(hostname -s):30015@SYSTEMDB SYSTEM \$HANAPWD" prdadm
    sudo su -lc "hdbuserstore set backupkey5 $(hostname -s):30013@SYSTEMDB SYSTEM \$HANAPWD" prdadm
    sudo su -lc "hdbuserstore set backupkey4 $(hostname -s):30015 SYSTEM \$HANAPWD" prdadm
    echo "$(hostname -s)" > /var/tmp/hana.done
    if [[ "$(hostname -s)" == "node-0" ]]; then
        sudo bash -c "ssh-keyscan -H node-1 >> ~/.ssh/known_hosts"
        while (! sudo ssh node-1 "cat /var/tmp/hana.done"); do sleep 10; done
        sudo su -lc "hdbsql -u system -i 00 -d systemdb -p \$HANAPWD \"BACKUP DATA FOR FULL SYSTEM USING FILE ('backup')\"" prdadm
        sudo su -lc "hdbnsutil -sr_enable --name=MST" prdadm
        sleep 30
        sudo scp /usr/sap/PRD/SYS/global/security/rsecssfs/data/SSFS_PRD.DAT node-1:/usr/sap/PRD/SYS/global/security/rsecssfs/data/SSFS_PRD.DAT
        sudo scp /usr/sap/PRD/SYS/global/security/rsecssfs/key/SSFS_PRD.KEY node-1:/usr/sap/PRD/SYS/global/security/rsecssfs/key/SSFS_PRD.KEY
        sudo ssh node-1 'su -lc "HDB stop" prdadm'
        sudo ssh node-1 'su -lc "hdbnsutil -sr_register --name=SLV --remoteHost=node-0 --remoteInstance=00 --replicationMode=sync --operationMode=logreplay" prdadm'
        sudo ssh node-1 'su -lc "HDB start" prdadm'
        # Wait for initialization to complete
        sleep 60
        sudo su -lc "HDBSettings.sh systemReplicationStatus.py" prdadm || true
    fi
    # sudo zypper -n install yast2-sap-ha
}

# Leave a log...
exec > $HOME/init-nodes.log 2>&1

# Show parameters
echo \$@

# Set unique initiator name
IQN=\$(echo "iqn.\$(date +"%Y-%m").\$(grep search /etc/resolv.conf | awk -F. 'BEGIN {OFS="."} (\$1 = substr(\$1,8)) {print \$2,\$1}'):\$(sudo iscsi-iname|cut -d: -f2)")
sudo sed -i -e '/^InitiatorName/d' /etc/iscsi/initiatorname.iscsi
sudo /bin/bash -c "echo InitiatorName=\$IQN >> /etc/iscsi/initiatorname.iscsi"

# Add watchdog for HA
sudo /bin/bash -c "echo softdog > /etc/modules-load.d/softdog.conf"
sudo systemctl restart systemd-modules-load.service

# Configure NTP
sudo yast2 ntp-client enable
sudo yast2 ntp-client add server=0.de.pool.ntp.org

# Wait for iSCSI server
host iscsisrv && iscsiip=\$(host iscsisrv | awk '{print \$NF}')
# First test the iSCSI server is reachable for 5 minutes. If it's not, abort
for ((i=1; i<=30; i++)); do ping -q -c 1 \$iscsiip && break; done || (echo "Aborting init script. Cannot reach iSCSI server" && exit 1)
while (! timeout 10 bash -c "cat < /dev/null > /dev/tcp/\$iscsiip/3260"); do echo "Waiting for iSCSI"; sleep 5; done

# Configure iSCSI initiator
sudo systemctl stop iscsid
sudo sed -i -r '/^node.startup/s/^node.startup = .+/node.startup = automatic/' /etc/iscsi/iscsid.conf
sudo systemctl enable --now iscsid
sudo iscsiadm -m discovery -t st -p "\$iscsiip:3260" -l -o new

# Wait for iSCSI devices
while (! ls /dev/disk/by-path/ip-\$iscsiip:*-lun-9 ); do sleep 5; done
ls /dev/disk/by-path/

sudo chmod +x /tmp/sshkeys.sh
sudo /tmp/sshkeys.sh

# Check whether we should install HANA
INSTOPT="\$1"
shift
test "\$INSTOPT" != "skip-hana" && install_hana \$@

test "\$INSTOPT" == "skip-cluster" && exit 0

# Initialize cluster on master and exit
# Master node is node-0. Check instances.tf to see why
SBDDEV=\$(ls /dev/disk/by-path/ip-\$iscsiip:*-lun-9)
if [ "\$(hostname)" == "node-0" ]; then
    sudo ha-cluster-init -y -u -s \$SBDDEV && exit 0
    echo "Failed to initialize cluster"
    exit 1
fi

# Wait and join cluster. Do so only if HAWK is already up in the master
# Cluster master is node-0. Check virtualmachines.tf to see why
while (! timeout 10 bash -c 'cat < /dev/null > /dev/tcp/node-0/7630'); do echo "Waiting for Cluster Init"; sleep 5; done
# Detected HAWK on the master node, so will give it a bit of time to finish ha-cluster-init
sleep 30
sudo ha-cluster-join -yc "node-0" || true
sleep 5
sudo systemctl is-active pacemaker || sudo systemctl restart pacemaker
if [[ "\$INSTOPT" != "skip-hana" ]]; then
    test -f /tmp/dlm.template && sudo crm configure load update /tmp/dlm.template
    sleep 5
    sed -i -e 's/%NODE0%/node-0/g' -e 's/%NODE1%/node-1/g' -e 's/%HANAIP%/10.74.1.5/g' /tmp/hanasr.template
    test -f /tmp/hanasr.template && sudo crm configure load update /tmp/hanasr.template
fi
EOP

chmod +x $HOME/at-init-nodes.sh
sudo systemctl enable --now atd
at now + 1 min <<EOP
$HOME/at-init-nodes.sh $@
EOP
exit 0
