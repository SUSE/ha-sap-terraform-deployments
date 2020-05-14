{% set repository = 'SLE_'~grains['osrelease_info'][0] %}
{% set repository = repository~'_SP'~grains['osrelease_info'][1] if grains['osrelease_info']|length > 1 else repository %}

server_monitoring_repo:
  pkgrepo.managed:
    - humanname: Server:Monitoring
    - baseurl: https://download.opensuse.org/repositories/server:/monitoring/{{ repository }}/
    - refresh: True
    - gpgautoimport: True
    - retry:
        attempts: 3
        interval: 15
    - require_in:
        - pkg: prometheus
        - pkg: grafana

include:
  - .prometheus
  - .grafana
