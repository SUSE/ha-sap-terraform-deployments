/etc/salt/minion.d/environment_base.conf:
  file.managed:
    - contents: |
        file_roots:
          base:
            - /srv/salt
            - /usr/share/salt-formulas/states

/etc/salt/minion.d/environment_predeployment.conf:
  file.managed:
    - contents: |
        file_roots:
          predeployment:
            - /srv/salt
            - /usr/share/salt-formulas/states

# prevent "[WARNING ] top_file_merging_strategy is set to 'merge' and multiple top files were found."
/etc/salt/minion.d/top_file_merging_strategy.conf:
  file.managed:
    - contents: |
        top_file_merging_strategy: same

backup_salt_configuration:
  file.copy:
    - name: /etc/salt/minion.backup
    - source: /etc/salt/minion

# Old module.run style will be deprecated after sodium release
upgrade_module_run:
  file.append:
    - name: /etc/salt/minion
    - text:
      - 'use_superseded:'
      - '- module.run'

minion_service:
  service.dead:
    - name: salt-minion
    - enable: False
