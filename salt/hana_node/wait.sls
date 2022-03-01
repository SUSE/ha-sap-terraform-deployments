# Make sure all hana nodes are reachable via ssh and finished pre-deployment (cluster authorized_keys).
# This is very important for scale-out setups as HANA deployment is done via ssh.
# It also prevents other timing race conditions.
{%- for num in range(1,grains['node_count']) %}
{%- set node = grains['name_prefix'] ~ '%02d' % num %}
wait_until_ssh_is_ready_{{ node }}:
  cmd.run:
    - name: until ssh -o ConnectTimeout=3 -o PreferredAuthentications=publickey {{ node }} "rpm -q saphanabootstrap-formula";do sleep 30;done
    - output_loglevel: quiet
    - timeout: 1200
{%- endfor %}

{%- if grains['hana_scale_out_enabled'] %}
{%- set node = grains['name_prefix'] ~ 'mm' %}
wait_until_ssh_is_ready_{{ node }}:
  cmd.run:
    - name: until ssh -o ConnectTimeout=3 -o PreferredAuthentications=publickey {{ node }} "rpm -q saphanabootstrap-formula";do sleep 30;done
    - output_loglevel: quiet
    - timeout: 1200
{%- endif %}
