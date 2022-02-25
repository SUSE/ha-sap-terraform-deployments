# based on: https://docs.aws.amazon.com/sap/latest/general/data-provider-installallation.html
#
{%- set aws_provider_url = "https://aws-sap-dataprovider-"~grains['region']~".s3."~grains['region']~".amazonaws.com/v4/installers" %}

## java is a prerequisite for aws-sap-data-provider
# does not work: resolve_capabilities throws error code =! 0
# java:
#   pkg.installed:
#     - resolve_capabilities: True
#     - retry:
#         attempts: 3
#         interval: 15
install_java:
  cmd.run:
    - name: zypper -n install -y --capability java-headless

import_aws_data_provider_key:
  cmd.run:
    - name: rpm --import {{ aws_provider_url }}/RPM-GPG-KEY-AWS

install_aws_data_providers:
  cmd.run:
    - name: zypper in -y {{ aws_provider_url }}/linux/SUSE/aws-sap-dataprovider-sles-standalone.x86_64.rpm
    - require:
      - import_aws_data_provider_key

aws-dataprovider:
  service.running:
    - require:
        - install_java
        - install_aws_data_providers
