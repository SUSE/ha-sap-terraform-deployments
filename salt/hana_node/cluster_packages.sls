habootstrap-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

{% if grains['install_from_ha_sap_deployment_repo'] is defined and grains['install_from_ha_sap_deployment_repo'] == true %}   # TODO: Very long line
install_cluster_packages: # Change the name
  pkg.installed:
    - fromrepo: {{ grains['ha_sap_deployment_repo'] }}
    - retry:
        attempts: 3
        interval: 15
    - refresh: True
    - pkgs:
        - corosync
        - crmsh
        - csync2
        - fence-agents
        - ha-cluster-bootstrap
        - hawk2
        - hawk-apiserver
        - pacemaker
        - resource-agents
        - sbd
{% endif %}