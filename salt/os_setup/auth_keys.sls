{% if grains['authorized_keys'] %}
authorized_keys:
  ssh_auth.present:
    - user: {{ grains['authorized_user'] }}
    - enc: ssh-rsa
    - names:
    {%- for key in grains['authorized_keys'] %}
      - {{ key }}
    {%- endfor %}
{% endif %}
