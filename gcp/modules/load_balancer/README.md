# GCP load balancer

This module implements a GCP load balancer with the purpose of managing the HA cluster virtual ip address, focused for 2 node clusters. This means that it has two different groups, for the primary and secondary nodes.

Find here the implementation details:
- https://cloud.google.com/solutions/sap/docs/sap-hana-ha-vip-migration-sles
- https://cloud.google.com/solutions/sap/docs/sap-hana-ha-config-sles
