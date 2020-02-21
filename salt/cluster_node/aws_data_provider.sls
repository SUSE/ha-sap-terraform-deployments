get_aws_data_provider:
  cmd.run:
    - name: wget https://s3.amazonaws.com/aws-data-provider/bin/aws-agent_install.sh -O /usr/bin/aws-agent_install.sh
    - unless: ls /usr/bin/aws-agent_install.sh

change_script_mode:
  file.managed:
    - name: /usr/bin/aws-agent_install.sh
    - mode: '0755'

start_script:
  cmd.run:
    - name: /usr/bin/aws-agent_install.sh
    - unless: systemctl status aws-agent
