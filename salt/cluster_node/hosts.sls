{% for ip in grains['host_ips'] %}
{{ grains['name_prefix'] }}{{ '{:0>2}'.format(loop.index) }}:
  host.present:
    - ip: {{ ip }}
    - names:
      - {{ grains['name_prefix'] }}{{ '{:0>2}'.format(loop.index) }}
{% endfor %}
