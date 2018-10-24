#!/bin/bash -xe

# Leave a log...
exec > /root/init-nodes.log 2>&1

# Set root password and SSH connection
echo "root:SECRET_PASSWORD" | chpasswd
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Set unique initiator name
IQN=$(echo "iqn.$(date +"%Y-%m").$(grep search /etc/resolv.conf | awk -F. 'BEGIN {OFS="."} ($1 = substr($1,8)) {print $2,$1}'):$(iscsi-iname|cut -d: -f2)")
sed -i -e '/^InitiatorName/d' /etc/iscsi/initiatorname.iscsi
echo "InitiatorName=$IQN" >> /etc/iscsi/initiatorname.iscsi

# Add watchdog for HA
echo softdog > /etc/modules-load.d/softdog.conf
systemctl restart systemd-modules-load.service

# Wait for iSCSI server
while (! timeout 10 bash -c 'cat < /dev/null > /dev/tcp/${iscsiip}/3260'); do echo "Waiting for iSCSI"; sleep 5; done

# Configure iSCSI initiator
systemctl stop iscsid
sed -i -r '/^node.startup/s/^node.startup = .+/node.startup = automatic/' /etc/iscsi/iscsid.conf
systemctl enable --now iscsid
iscsiadm -m discovery -t st -p "${iscsiip}:3260" -l -o new

# Wait for iSCSI devices
while (! ls /dev/disk/by-path/ip-${iscsiip}:*-lun-9 ); do sleep 5; done
ls /dev/disk/by-path/

# Initialize cluster on master and exit
# Master node is 10.0.1.0. Check instances.tf to see why
SBDDEV=$(ls /dev/disk/by-path/ip-${iscsiip}:*-lun-9)
if [[ "$(hostname)" == "ip-10-0-1-0" || "$(hostname)" == "node-1" ]]; then
  sudo ha-cluster-init -y -u -s $SBDDEV && exit 0
  echo "Failed to initialize cluster"
  exit 1
fi

# Create expect script to handle password request in ha-cluster-join
CLUSTERJOIN="/root/wrap-cluster-join"
cat > $CLUSTERJOIN <<EOF
set timeout 60
set host [lrange \$argv 1 end]
set password [lindex \$argv 0]
eval spawn ha-cluster-join -yc \$host
expect "password:"
send "\$password\\r";
expect "Done"
close
EOF

# Wait and join cluster. Do so only if HAWK is already up in the master
# Cluster master is 10.0.1.0. Check instances.tf to see why
while (! timeout 10 bash -c 'cat < /dev/null > /dev/tcp/10.0.1.0/7630'); do echo "Waiting for Cluster Init"; sleep 5; done

# Found HAWK on the master node. Wait 30 seconds for it to finish initialization before ha-cluster-join
sleep 30
expect $CLUSTERJOIN "SECRET_PASSWORD" "10.0.1.0"
sleep 5
systemctl is-active pacemaker || systemctl restart pacemaker

