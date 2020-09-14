# hana user:
# https://help.sap.com/viewer/6b94445c94ae495c83a19646e7c3fd56/2.0.04/en-US/3c831ee47beb4499972774f4a080d1d3.html
{% set hana = salt['pillar.get']('hana') %}
{% for node in hana.nodes}


# NOTE: we can't use normal saltstack call like grain.set etc,  because we need to retrieve id dinamically and use {{ node.sid }} inside.
add_sidadm_grains:
  cmd.run:
    - name: |
        sed -i '/ad_sid_uid/d' /etc/salt/grains
        sed -i '/ad_sid_gid/d' /etc/salt/grains
        echo "ad_sid_uid: `id {{ node.sid }}adm -u`" >> /etc/salt/grains
        echo "ad_sid_gid: `id {{ node.sid }}adm -g`" >> /etc/salt/grains


{% endfor %}
