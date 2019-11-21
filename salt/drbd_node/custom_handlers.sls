# install the custom handler for splitbrain
/var/lib/drbd/notify-split-brain-haclusterexporter-suse-metric.sh:
  file.managed:
    - source: salt://drbd_node/files/notify-split-brain-haclusterexporter-suse-metric.sh
