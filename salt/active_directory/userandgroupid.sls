# this states need to be executed after the machine join a domain with realmd otherwise we can't get the users and jinja fails

{% set groupid = salt['cmd.shell']('id prdadm -g') %}
{% set userid = salt['cmd.shell']('id prdadm -u') %}

# this 2 grains, are used by hana/netweaver formulas, for overwriting default installation
# so that hana/netweaver can work without posix attributes, since we are using sssd dinamically mapping
add_sidadm_groupid_grains:
  module.run:
    -grains.set:
      - key: sidadm_ad_groupid
      - val: {{ groupid }}

add_groupid_grains:
  module.run:
    -grains.set:
      - key: sidadm_ad_userid
      - val: {{ userid }}
