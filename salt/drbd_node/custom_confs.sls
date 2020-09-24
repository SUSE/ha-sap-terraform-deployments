# install the custom handler for splitbrain
/usr/lib/drbd/notify-split-brain-haclusterexporter-suse-metric.sh:
  file.managed:
    - source:
      - salt://drbd_node/files/notify-split-brain-haclusterexporter-suse-metric.sh
      - /usr/share/salt-formulas/states/drbd/templates/examples/with_ha-sap-terraform-deployment/notify-split-brain-haclusterexporter-suse-metric.sh
    - replaced: False
    - mode: "0744"

# install drbd-formula(later than v0.3.11) first
/srv/pillar/drbd/drbd.sls:
  file.managed:
    - source: /usr/share/salt-formulas/states/drbd/templates/examples/with_ha-sap-terraform-deployment/pillar.example.drbd
    - replaced: False
    - mode: "0644"

/srv/pillar/drbd/cluster.sls:
  file.managed:
    - source: /usr/share/salt-formulas/states/drbd/templates/examples/with_ha-sap-terraform-deployment/pillar.example.cluster
    - replaced: False
    - mode: "0644"
