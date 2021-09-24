#cloud-config

# Uses the bastion SNAT router.
# Adapted https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-linux-with-powervs#linux-networking to work with SLES.
# This assumes eth0 is on a private subnet

runcmd:
- |
  echo 'default '${bastion_private}' - -' > /etc/sysconfig/network/ifroute-eth0
  sed -i 's/^NETCONFIG_DNS_STATIC_SERVERS=\"/NETCONFIG_DNS_STATIC_SERVERS=\"8.8.8.8/' /etc/sysconfig/network/config
  sed -i '/^MTU=/cMTU=1450' /etc/sysconfig/network/ifcfg-eth0
  grep -q '^ETHTOOL_OPTIONS=' /etc/sysconfig/network/ifcfg-eth0 && sed -i "s/^ETHTOOL_OPTIONS=/ETHTOOL_OPTIONS='-K eth0 rx off'" /etc/sysconfig/network/ifcfg-eth0 || echo "ETHTOOL_OPTIONS='-K eth0 rx off'" >> /etc/sysconfig/network/ifcfg-eth0
  rm -rf /etc/resolv.conf
  /usr/bin/systemctl restart network
