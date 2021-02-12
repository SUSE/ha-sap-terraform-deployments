# Code based in: https://docs.aws.amazon.com/sap/latest/general/data-provider-install.html
import_aws_data_provider_key:
  cmd.run:
    - name: rpm --import https://aws-sap-data-provider.s3.amazonaws.com/Installers/RPM-GPG-KEY-AWS

install_aws_data_providers:
  cmd.run:
    - name: zypper in -y https://aws-sap-data-provider.s3.amazonaws.com/Installers/aws-sap-dataprovider-sles.x86_64.rpm
    - require:
      - import_aws_data_provider_key

aws-dataprovider:
  service.running:
    - require:
        - install_aws_data_providers
