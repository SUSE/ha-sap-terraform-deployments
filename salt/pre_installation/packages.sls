iscsi-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

# with devel mode, vendor changes are allowed
{% if grains.get('devel_mode') %}
update_systems_packages_from_devel:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys update --auto-agree-with-licenses
    - retry:
        attempts: 3
        interval: 15
    - require:
      - pkg: iscsi-formula
{% endif %}
