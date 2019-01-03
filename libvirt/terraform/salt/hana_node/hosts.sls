{% for ip in grains['host_ips'] %}
hana0{{ loop.index }}:
  host.present:
    - ip: {{ ip }}
    - names:
      - hana0{{ loop.index }}
{% endfor %}
