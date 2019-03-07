restart_targetcli:
  service.running:
    - name: targetcli
    - enable: True
