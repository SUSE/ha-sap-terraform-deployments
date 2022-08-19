{% if grains['osfullname'] == 'SLES' %}
{% if grains['osmajorrelease'] == 12 %}
# nginx package is only available in Packagehub on SLES12
packagehub_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p PackageHub/{{ grains['osrelease'] }}/{{ grains['osarch'] }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}
{% endif %}

nginx:
  pkg.installed

nginx_config_file:
  file.managed:
    - name:  /etc/nginx/nginx.conf
    - source: salt://bastion/templates/nginx.conf.j2
    - template: jinja
    - makedirs: True
    - context:
        monitoring_srv_ip: {{ grains['monitoring_srv_ip'] }}
    - require:
      - pkg: nginx

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: nginx
      - file: nginx_config_file
