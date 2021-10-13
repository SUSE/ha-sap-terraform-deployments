# settings according to
# https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-configure-nfsv41-domain
/etc/idmapd.conf:
  file.line:
    - match: "^Domain = localdomain"
    - mode: replace
    - content: |
        Domain = defaultv4iddomain.com
    - require:
      - pkg: nfs-client

nfs-idmapd:
  service.running:
    - enable: True
    - require:
      - pkg: nfs-client
      - file: /etc/idmapd.conf
    - watch:
      - pkg: nfs-client
      - file: /etc/idmapd.conf

clear_idmap_cache:
  cmd.run:
    - name: nfsidmap -c
    - onchanges:
      - file: /etc/idmapd.conf
