{%- if grains['role'] in ['iscsi_srv', 'drbd_node', 'hana_node', 'netweaver_node'] %}
install-salt-formulas:
  pkg.installed:
    - pkgs:
      {%- if grains['role'] == 'iscsi_srv' %}
      - iscsi-formula
      {%- elif grains['role'] == 'drbd_node' %}
      - drbd-formula`
      - habootstrap-formula
      {%- elif grains['role'] == 'hana_node' %}
      - saphanabootstrap-formula
      - habootstrap-formula
      {%- elif grains['role'] == 'netweaver_node' %}
      - sapnwbootstrap-formula
      - habootstrap-formula
      {%- endif %}
    - retry:
        attempts: 3
        interval: 15
{%- endif %}
