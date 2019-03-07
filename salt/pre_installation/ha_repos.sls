add-saphana-repo:
  pkgrepo.managed:
    - name: saphana
{% if grains['osfinger'] == 'SLES-12' %}
    #- Factory repo currently broken due to python dependency issue
    #- baseurl: https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_12_SP4/
    - baseurl: https://download.opensuse.org/repositories/home:/xarbulu:/sap-deployment/SLE_12_SP4/
{% elif grains['osfinger'] == 'SLES-15' %}
    #- Factory repo currently broken due to python dependency issue
    #- baseurl: https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/
    - baseurl: https://download.opensuse.org/repositories/home:/xarbulu:/sap-deployment/SLE_15/
{% endif %}
    - gpgautoimport: True
