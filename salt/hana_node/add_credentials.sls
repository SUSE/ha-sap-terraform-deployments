{% if grains['provider'] == 'aws' %}
add_aws_credentials:
  file.managed:
    - name: ~{{ grains['username'] }}/.aws/config
    - source: /tmp/credentials
    - makedirs: true
{% endif %}
