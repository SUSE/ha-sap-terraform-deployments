upgrade_module_run:
  file.append:
    - name: /etc/salt/minion
    - text:
      - 'use_superseded:'
      - '- module.run'
