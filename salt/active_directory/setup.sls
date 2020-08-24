install_sssd_packages:
  pkg.latest:
    - pkgs:
      - realmd
      - adcli
      - sssd
      - sssd-tools
      - sssd-ad
      - samba-client
      - tcsh

adapt_dns_to_ad:
  file.replace:
    - name: '/etc/sysconfig/network/config'
    - pattern: "NETCONFIG_DNS_STATIC_SERVERS=.*"
    - repl: "NETCONFIG_DNS_STATIC_SERVERS={{ grains.get('ad_server') }}"
    - require:
      - install_sssd_packages

wickedd:
  service.running:
    - watch:
      - file : /etc/sysconfig/network/config

wicked:
  service.running:
    - watch:
      - file : /etc/sysconfig/network/config

wickedd-nanny:
  service.running:
    - watch:
      - file : /etc/sysconfig/network/config

# todo: this will fail because minor bug see https://github.com/freedesktop/realmd/pull/1
join_domain:
  cmd.run:
    - name: echo {{ grains.get('ad_adm_pwd') }} | realm join {{ grains.get('ad_server') }}  --automatic-id-mapping=no
    # TODO improve this to make something more reliable
    - check_cmd:
      - ls /etc/sssd/sssd.conf
    - require:
      - install_sssd_packages

# TODO: this should be removed once https://github.com/freedesktop/realmd/pull/1 is merged and pkg builded
add_sssd_pam:
  cmd.run:
    - name: pam-config --add --sss
    - require:
      - join_domain

add_sssd_passwd_nsswitch:
  file.replace:
    - name: '/etc/nsswitch.conf'
    - pattern: "^passwd:.*"
    - repl: "passwd: compat sss"
    - require:
      - join_domain


add_sssd_group_nsswitch:
  file.replace:
    - name: '/etc/nsswitch.conf'
    - pattern: "^group:.*"
    - repl: "group: compat sss"
    - require:
      - join_domain


add_sssd_shadow_nsswitch:
  file.replace:
    - name: '/etc/nsswitch.conf'
    - pattern: "^shadow:.*"
    - repl: "shadow: compat sss"
    - require:
      - join_domain

# caching

# we need this to cleanup
allow_pam_caching_oneday_cleanup:
  file.replace:
    - name: '/etc/sssd/sssd.conf'
    - pattern: "offline_credentials_expiration =.*"
    - repl: ''
    - require:
      - join_domain

# TODO this is not idempotent since it add always 1
allow_pam_caching_oneday:
  file.replace:
    - name: '/etc/sssd/sssd.conf'
    - pattern: {{ '[pam]' | regex_escape }}
    - repl: '\g<0>\noffline_credentials_expiration = 1'
    - require:
      - join_domain

sssd_service:
  service.running:
    - name: sssd
    - enable: True
    - require:
      - pkg: install_sssd_packages
      - file: allow_pam_caching_oneday
    - watch:
      - file: /etc/sssd/sssd.conf

disable_qualified_names:
  file.replace:
    - name: '/etc/sssd/sssd.conf'
    - pattern: "use_fully_qualified_names =.*"
    - repl: "use_fully_qualified_names = False"
    - require:
      - join_domain

