#! /bin/bash

# this is a custom handler for drbd splitbrain
# see upstream doc https://docs.linbit.com/docs/users-guide-8.4/#s-configure-split-brain-behavior

# the main goal of this handler signal via file when the splitbrain mechanism occurs.
# the handler create a simple file which is then tracked by the ha_cluster_exporter https://github.com/ClusterLabs/ha_cluster_exporter
# and from this file we create a metrics for detecting splitbrain and monitor it

# remember to remove the file once the drbd splitbrain is over, otherwise the exporter will always set the metric of splitbrain to present

mkdir -p /var/run/drbd/splitbrain
echo "DRBD split-brain detected! Remember to remove the file /var/lib/drbd/drbd-split-brain-detected once the splitbrain is solved!" > /var/run/drbd/splitbrain/drbd-split-brain-detected-$DRBD_RESOURCE-$DRBD_VOLUME
