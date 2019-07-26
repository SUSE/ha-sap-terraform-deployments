backup-salt-configuration:
  file.copy:
    - name: /etc/salt/minion.backup
    - source: /etc/salt/minion

configure-file-roots:
  file.append:
    - name: /etc/salt/minion
    - text: |
        file_roots:
          base:
            - /srv/salt
            - /usr/share/salt-formulas/states
            - /root/salt
