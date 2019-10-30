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

{% if grains['role'] == 'drbd_node' %}
configure_use_superseded:
  file.append:
    - name: /etc/salt/minion
    - text: |

        use_superseded:
          - module.run
{% endif %}
