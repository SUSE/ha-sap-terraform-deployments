## todo there is a problem with node.sid
# NOTE: we can't use normal saltstack call like grain.set etc,  because we need to retrieve id dinamically and use {{ node.sid }} inside.
add_sidadm_grains:
  cmd.run:
    - name: |
        sed -i '/ad_sid_uid/d' /etc/salt/grains
        sed -i '/ad_sid_gid/d' /etc/salt/grains
        echo "ad_sid_uid: `id prdadm -u`" >> /etc/salt/grains
        echo "ad_sid_gid: `id prdadm -g`" >> /etc/salt/grains


{% endfor %}
