# Current version of the iscsi formula has a really strage way of formatting the pillar file
# We need to check the latest change in upstrean
# meanwhile

update_saveconfig:
  file.serialize:
    - name: /etc/target/saveconfig.json
    - user: root
    - group: root
    - mode: "0600"
    - formatter: json
    - dataset_pillar: iscsi:target:lio:myconf

restart_targetcli:
  service.running:
    - name: targetcli
    - enable: True
    - watch:
      - file: /etc/target/saveconfig.json
