enable_eth1:
  cmd.run:
    #- name: /sbin/ifconfig eth1 {{ grains['host_ip'] }}
    - name: /sbin/ip a add {{ grains['host_ip'] }}/24 dev eth1 & /sbin/ip link set eth1 up
