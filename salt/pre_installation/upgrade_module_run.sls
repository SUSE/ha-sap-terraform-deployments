# Old module.run style will be deprecated after sodium release
upgrade_module_run:
  file.append:
    - name: /etc/salt/minion
    - text:
      - 'use_superseded:'
      - '- module.run'
