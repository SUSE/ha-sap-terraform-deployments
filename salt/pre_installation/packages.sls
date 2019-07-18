iscsi-formula:
  pkg.installed:
    - fromrepo: ha-factory
    - retry:
        attempts: 3
        interval: 15

{% if grains['role'] == 'iscsi_srv' %}
move-iscsi-folder:
  cmd.run:
    - name: mv /srv/salt/iscsi /root/salt/
    - unless: file.path_exists_glob('/root/salt/iscsi')

/srv/salt:
  file.absent:
  - require:
    - move-iscsi-folder
{% endif %}
