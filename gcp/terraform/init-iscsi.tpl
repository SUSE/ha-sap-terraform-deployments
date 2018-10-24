#!/bin/bash -xe

exec > /root/init-iscsi.log 2>&1

# Searching the realpath of the device
ISCSIDEV=$(realpath ${iscsidev})

# Partition device
parted --align optimal --wipesignatures --script "$ISCSIDEV" mklabel gpt
parted --script "$ISCSIDEV" mkpart primary 1MiB 1024MiB
parted --script "$ISCSIDEV" mkpart primary 1025MiB 2048MiB
parted --script "$ISCSIDEV" mkpart primary 2049MiB 3072MiB
parted --script "$ISCSIDEV" mkpart primary 3073MiB 4096MiB
parted --script "$ISCSIDEV" mkpart primary 4097MiB 5120MiB
parted --script "$ISCSIDEV" mkpart primary 5121MiB 6144MiB
parted --script "$ISCSIDEV" mkpart primary 6145MiB 7168MiB
parted --script "$ISCSIDEV" mkpart primary 7169MiB 8192MiB
parted --script "$ISCSIDEV" mkpart primary 8193MiB 9216MiB
parted --script "$ISCSIDEV" mkpart primary 9217MiB 10239MiB

# Configure iSCSI server

# Get an IQN name
IQN=$(echo "iqn.$(date +"%Y-%m").$(grep search /etc/resolv.conf | awk -F. 'BEGIN {OFS="."} ($1 = substr($1,8)) {print $2,$1}'):$(iscsi-iname|cut -d: -f2)")

# Load iSCSI target kernel module and wait a bit for the module to load
modprobe target_core_mod
sleep 3

# Add Target Portal Group
lio_node --addtpg=$IQN 1

# Add Network Portal
lio_node --addnp=$IQN 1 10.0.0.254:3260

# Disable authentication
lio_node --disableauth=$IQN 1
lio_node --demomode=$IQN 1

# Enable Target Portal Group
lio_node --enabletpg=$IQN 1
lio_node --addnodeacl=$IQN 1 $IQN

# Add LUNs with the partitioned devices
DEVALIAS=$(echo "$ISCSIDEV" | awk -F/ '{print $2"_"$3}')
for i in {1..10}; do tcm_node --iblock "iblock_0/$DEVALIAS$i" "$ISCSIDEV$i"; done
for i in {1..10}; do lio_node --addlun=$IQN 1 $((i-1)) "$DEVALIAS$i" "iblock_0/$DEVALIAS$i"; done
for i in {1..10}; do lio_node --addlunacl=$IQN 1 $(echo $IQN | cut -d: -f1) $((i-1)) $((i-1)); done
for i in {1..10}; do lio_node --disablelunwp=$IQN 1 $(echo $IQN | cut -d: -f1) $((i-1)); done

# Disable demo mode write protect
lio_node --settpgattr=$IQN 1 demo_mode_write_protect 0

# Save running configuration
lio_dump --s > /etc/target/lio_setup.sh
tcm_dump --s > /etc/target/tcm_setup.sh
chmod +x /etc/target/*_setup.sh

# Disable demo mode write protect and authentication on saved configuration
systemctl stop target
sed -i -e '/\/demo_mode_write_protect$/s/^echo 1/echo 0/' /etc/target/lio_setup.sh
grep demo_mode_write_protect /etc/target/lio_setup.sh
sed -i -e '/\/authentication$/s/^echo 1/echo 0/' /etc/target/lio_setup.sh
grep authentication /etc/target/lio_setup.sh

# Enable cache_dynamic_acls and generate_node_acls
sed -i -e '/\/cache_dynamic_acls$/s/^echo 0/echo 1/' /etc/target/lio_setup.sh
grep cache_dynamic_acls /etc/target/lio_setup.sh
sed -i -e '/\/generate_node_acls$/s/^echo 0/echo 1/' /etc/target/lio_setup.sh
grep generate_node_acls /etc/target/lio_setup.sh

# Enable & start iSCSI target
systemctl enable --now target
