#!/bin/bash -xe

sleep 30

exec > $HOME/init-iscsi.log 2>&1

iscsidev="/dev/sdc"
DMVAL=$(sudo multipath -l -v1 "$iscsidev")
test -n "$DMVAL" && iscsidev="/dev/mapper/$DMVAL"

# Partition device $iscsidev
sudo parted --align optimal --wipesignatures --script "$iscsidev" mklabel gpt
sudo parted --script "$iscsidev" mkpart primary 1MiB 1024MiB
sudo parted --script "$iscsidev" mkpart primary 1025MiB 2048MiB
sudo parted --script "$iscsidev" mkpart primary 2049MiB 3072MiB
sudo parted --script "$iscsidev" mkpart primary 3073MiB 4096MiB
sudo parted --script "$iscsidev" mkpart primary 4097MiB 5120MiB
sudo parted --script "$iscsidev" mkpart primary 5121MiB 6144MiB
sudo parted --script "$iscsidev" mkpart primary 6145MiB 7168MiB
sudo parted --script "$iscsidev" mkpart primary 7169MiB 8192MiB
sudo parted --script "$iscsidev" mkpart primary 8193MiB 9216MiB
sudo parted --script "$iscsidev" mkpart primary 9217MiB 10239MiB

# Configure iSCSI server

# Get an IQN name
IQN=$(echo "iqn.$(date +"%Y-%m").$(grep search /etc/resolv.conf | awk -F. 'BEGIN {OFS="."} ($1 = substr($1,8)) {print $2,$1}'):$(sudo iscsi-iname|cut -d: -f2)")
MYIP=$(host iscsisrv | awk '{print $NF}')

# Load iSCSI target kernel module and wait a bit for the module to load
sudo /bin/bash -c "echo target_core_mod > /etc/modules-load.d/target.conf"
sudo systemctl restart systemd-modules-load.service
sleep 3

# Add Target Portal Group
sudo lio_node --addtpg=$IQN 1

# Add Network Portal
sudo lio_node --addnp=$IQN 1 $MYIP:3260

# Disable authentication
sudo lio_node --disableauth=$IQN 1
sudo lio_node --demomode=$IQN 1

# Enable Target Portal Group
sudo lio_node --enabletpg=$IQN 1
sudo lio_node --addnodeacl=$IQN 1 $IQN

# Add LUNs with the partitioned devices
DEVALIAS=$(echo "$iscsidev" | awk -F/ '{print $2"_"$3}')
test -n "$DMVAL" && iscsidev="$iscsidev-part"
for i in {1..10}; do sudo tcm_node --iblock "iblock_0/$DEVALIAS$i" "${iscsidev}$i"; done
for i in {1..10}; do sudo lio_node --addlun=$IQN 1 $((i-1)) "$DEVALIAS$i" "iblock_0/$DEVALIAS$i"; done
for i in {1..10}; do sudo lio_node --addlunacl=$IQN 1 $(echo $IQN | cut -d: -f1) $((i-1)) $((i-1)); done
for i in {1..10}; do sudo lio_node --disablelunwp=$IQN 1 $(echo $IQN | cut -d: -f1) $((i-1)); done

# Disable demo mode write protect
sudo lio_node --settpgattr=$IQN 1 demo_mode_write_protect 0

# Save running configuration
sudo /bin/bash -c "lio_dump --s > /etc/target/lio_setup.sh"
sudo /bin/bash -c "tcm_dump --s > /etc/target/tcm_setup.sh"
sudo chmod +x /etc/target/*_setup.sh

# Disable demo mode write protect and authentication on saved configuration
sudo systemctl stop target
sudo sed -i -e '/\/demo_mode_write_protect$/s/^echo 1/echo 0/' /etc/target/lio_setup.sh
grep demo_mode_write_protect /etc/target/lio_setup.sh
sudo sed -i -e '/\/authentication$/s/^echo 1/echo 0/' /etc/target/lio_setup.sh
grep authentication /etc/target/lio_setup.sh

# Enable cache_dynamic_acls and generate_node_acls
sudo sed -i -e '/\/cache_dynamic_acls$/s/^echo 0/echo 1/' /etc/target/lio_setup.sh
grep cache_dynamic_acls /etc/target/lio_setup.sh
sudo sed -i -e '/\/generate_node_acls$/s/^echo 0/echo 1/' /etc/target/lio_setup.sh
grep generate_node_acls /etc/target/lio_setup.sh

# Enable & start iSCSI target
sudo systemctl enable --now target

