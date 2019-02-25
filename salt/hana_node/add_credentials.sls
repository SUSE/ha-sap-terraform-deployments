add_credentials:
  file.managed:
    - name: ~{{ grains['username'] }}/.aws/config
    - source: /tmp/credentials
    - makedirs: true
