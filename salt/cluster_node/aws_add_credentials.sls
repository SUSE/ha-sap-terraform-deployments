{%- set aws_config_file = "~"~grains['username']~"/.aws/config" %}

{%- if grains['aws_access_key_id'] and grains['aws_secret_access_key'] %}
create_credentials_file:
  file.managed:
    - name: {{ aws_config_file }}
    - makedirs: true

add_default_profile:
  file.append:
    - name: {{ aws_config_file }}
    - text: |
        [default]
        region = {{ grains['region'] }}
        aws_access_key_id = {{ grains['aws_access_key_id'] }}
        aws_secret_access_key = {{ grains['aws_secret_access_key'] }}
    - unless: cat {{ aws_config_file }} | grep "default"

{%- elif grains['aws_credentials_file'] %}
create_credentials_file:
  file.managed:
    - name: {{ aws_config_file }}
    - source: {{ grains['aws_credentials_file'] }}
    - makedirs: true

remove_temp_credentials_file:
  file.absent:
    - name: {{ grains['aws_credentials_file'] }}
{%- endif %}

# Append the new profile. It's done with a template because we need to get the keys from the current
# file and we need to run some salt commands after the previous states
# This last part maybe could moved to habootstrap-formula
add_cluster_profile:
  file.append:
    - name: {{ aws_config_file }}
    - template: jinja
    - source: salt://cluster_node/templates/aws_credentials_template.j2
    - unless: cat {{ aws_config_file }} | grep "profile {{ grains['aws_cluster_profile'] }}"
    - require:
      - create_credentials_file
