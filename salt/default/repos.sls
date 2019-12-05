{% if grains['os_family'] == 'Suse' %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - retry:
        attempts: 3
        interval: 15

workaround_susecloud_register:
  cmd.run:
    - name: |
        rm /etc/SUSEConnect && /
        rm -f /etc/zypp/{repos,services,credentials}.d/* && /
        rm -f /usr/lib/zypp/plugins/services/* && /
        sed -i '/^# Added by SMT reg/,+1d' /etc/hosts && /
        /usr/sbin/registercloudguest --force-new && /
        zypper --non-interactive --gpg-auto-import-keys refresh
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'test -e /usr/sbin/registercloudguest'
    - onfail:
      - cmd: refresh_repos

{% endif %}
