include:
{% if grains['provider'] != 'aws' %}
  - default.minimal
{% if grains['os_family'] == 'Suse' %}
  - default.registration
{% endif %}
  - default.repos
  - default.pkgs
  {% if grains['ntp_server'] != ''%}
  - default.ntp
  {% endif %}

timezone_package:
  pkg.installed:
{% if grains['os_family'] == 'Suse' %}
    - name: timezone
{% else %}
    - name: tzdata
{% endif %}

timezone_symlink:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ grains['timezone'] }}
    - force: true
    - require:
      - pkg: timezone_package

timezone_setting:
  timezone.system:
    - name: {{ grains['timezone'] }}
    - utc: True
    - require:
      - file: timezone_symlink

{% if grains['authorized_keys'] %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}

refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh

{% else %}

{% if grains['os_family'] == 'Suse' %}
  - default.registration
{% endif %}
  - default.repos
  - default.pkgs
{% endif %}

