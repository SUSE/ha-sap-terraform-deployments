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
