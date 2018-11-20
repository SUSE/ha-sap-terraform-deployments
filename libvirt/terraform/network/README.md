# Network Setup

This module does simply set up a network according to the parameter variables.

## Parameters

You can set four variables when using this module:

1. `net_ip` specifies the network IP address and subnet, e.g. 192.168.0.0/24.
1. `mode` specifies the mode, `nat`, `none`, `bridge` or `route`.
1. `bridge` specifies the name of the bridge interface to be used.
1. `cluster_id` specifies a unique ID for the cluster.

## Output

This module returns the **ID** of the network that has been set up.
