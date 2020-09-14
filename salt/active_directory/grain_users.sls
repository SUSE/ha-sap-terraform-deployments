# hana user:
# https://help.sap.com/viewer/6b94445c94ae495c83a19646e7c3fd56/2.0.04/en-US/3c831ee47beb4499972774f4a080d1d3.html
{% set hana = salt['pillar.get']('hana') %}
{% set host = grains['host'] %}
{% for node in hana.nodes if node.host == host %}

sidadm_login_ls:
  cmd.run:
    - name: su -lc 'ls -l' {{ node.sid }}adm

# sed before remove the grains so call it is idempotent
add_sidadm_grains:
  cmd.run:
    - name: |
        sed -i '/ad_sid_uid/d' /etc/salt/grains
        sed -i '/ad_sid_gid/d' /etc/salt/grains
        echo "ad_sid_uid: `id {{ node.sid }}adm -u`" >> /etc/salt/grains
        echo "ad_sid_gid: `id {{ node.sid }}adm -g`" >> /etc/salt/grains


{% endfor %}
