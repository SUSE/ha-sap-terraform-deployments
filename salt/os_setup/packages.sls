{%- if grains['role'] in ['iscsi_srv', 'drbd_node', 'hana_node', 'netweaver_node'] %}
install-salt-formulas:
  pkg.installed:
    - pkgs:
      - salt-shaptools: 0.3.11+git.1605797958.ae2f08a-3.6.1
      {%- if grains['role'] == 'iscsi_srv' %}
      - iscsi-formula: 1.1.1-1.6.1
      {%- elif grains['role'] == 'drbd_node' %}
      - drbd-formula: 0.4.0+git.1611073587.55c0dfd-3.3.2
      - habootstrap-formula: 0.4.1+git.1611775401.451718e-3.12.1
      {%- elif grains['role'] == 'hana_node' %}
      - python3-shaptools: 0.3.11+git.1605798399.b036435-3.6.1
      - saphanabootstrap-formula: 0.7.0+git.1611071677.5443549-3.8.2
      - habootstrap-formula: 0.4.1+git.1611775401.451718e-3.12.1
      {%- elif grains['role'] == 'netweaver_node' %}
      - python3-shaptools: 0.3.11+git.1605798399.b036435-3.6.1
      - sapnwbootstrap-formula: 0.6.0+git.1611071663.f186586-3.8.2
      - habootstrap-formula: 0.4.1+git.1611775401.451718e-3.12.1
      {%- endif %}
    - retry:
        attempts: 3
        interval: 15
{%- endif %}
