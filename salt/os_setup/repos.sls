{% if grains['os_family'] == 'Suse' %}

# Workaround for the 'Script died unexpectedly' error bsc#1158664
# If it is a PAYG image, it will force a new registration before refreshing.
# Also the pure refresh will not be executed as salt will still report failure.
# See: https://github.com/saltstack/salt/issues/16291
workaround_payg_cleanup:
  cmd.run:
    - name: |
        rm -f /etc/SUSEConnect &&
        rm -f $(ls /etc/zypp/{repos,services,credentials}.d/* | grep -v -e 'ha-factory' -e 'server_monitoring') &&
        rm -f /usr/lib/zypp/plugins/services/* &&
        sed -i '/^# Added by SMT reg/,+1d' /etc/hosts
    - onlyif: 'test -e /usr/sbin/registercloudguest'

workaround_payg_new_register:
  cmd.run:
    - name: /usr/sbin/registercloudguest --force-new
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'test -e /usr/sbin/registercloudguest'

refresh_repos_after_registration:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'zypper lr'

{% endif %}
