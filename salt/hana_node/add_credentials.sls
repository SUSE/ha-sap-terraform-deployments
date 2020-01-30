{% if grains['provider'] == 'aws' %}
create_credentials_file:
  file.managed:
    - name: ~{{ grains['username'] }}/.aws/config
    - makedirs: true

add_credentials:
  file.append:
    - name: ~{{ grains['username'] }}/.aws/config
    - text: |
        [default]
        region: {{ grains['region'] }}
        aws_access_key_id: {{ grains['aws_access_key_id'] }}
        aws_secret_access_key: {{ grains['aws_secret_access_key'] }}

add_cluster_profile:
  file.append:
    - name: ~{{ grains['username'] }}/.aws/config
    - text: |
        [profile {{ grains['aws_cluster_profile'] }}]
        region: {{ grains['region'] }}
        output: text
        aws_access_key_id: {{ grains['aws_access_key_id'] }}
        aws_secret_access_key: {{ grains['aws_secret_access_key'] }}
{% endif %}
