# install the custom handler for splitbrain
/usr/lib/drbd/notify-split-brain-haclusterexporter-suse-metric.sh:
  file.managed:
    - source: salt://drbd/templates/ha_cluster_exporter/notify-split-brain-haclusterexporter-suse-metric.sh
    - mode: "0744"
    - makedirs: True
    - require:
      - pkg: drbd-formula
