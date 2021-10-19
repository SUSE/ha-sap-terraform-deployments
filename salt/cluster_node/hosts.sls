{% for ip in grains['host_ips'] %}
{{ grains['name_prefix'] }}{{ '{:0>2}'.format(loop.index) }}:
  host.present:
    - ip: {{ ip }}
    - names:
      - {{ grains['name_prefix'] }}{{ '{:0>2}'.format(loop.index) }}
{% endfor %}

{% if grains['majority_maker_ip']|default(None) and grains['majority_maker_node']|default(None) %}
{{ grains['majority_maker_node'] }}:
  host.present:
    - ip: {{ grains['majority_maker_ip'] }}
{% endif %}
