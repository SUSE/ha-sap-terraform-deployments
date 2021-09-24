#cloud-config

# Sets up bastion SNAT router.
# Adapted https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-linux-with-powervs#linux-networking to work with SLES.
# This assumes eth0 is on a public subnet and eth1 is on a private subnet

runcmd:
- |
  echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/powervs-snat.conf
  /sbin/sysctl --system
  grep -q '^iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE$' /etc/init.d/after.local || echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/init.d/after.local
  /usr/sbin/iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE >/dev/null 2>&1 || /usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  sed -i '/^MTU=/cMTU=1450' /etc/sysconfig/network/ifcfg-eth1
  grep -q '^ETHTOOL_OPTIONS=' /etc/sysconfig/network/ifcfg-eth1 && sed -i "s/^ETHTOOL_OPTIONS=/ETHTOOL_OPTIONS='-K eth1 rx off'" /etc/sysconfig/network/ifcfg-eth1 || echo "ETHTOOL_OPTIONS='-K eth1 rx off'" >> /etc/sysconfig/network/ifcfg-eth1
  /usr/bin/systemctl restart network
