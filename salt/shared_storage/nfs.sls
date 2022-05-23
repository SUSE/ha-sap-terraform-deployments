install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

# We cannot use showmount as some of the required ports are not always available
# and have to use netcat to check the NFS availability.
# (aws efs storage or azure load balancers don't serve portmapper 111 and mountd 20048 ports)
netcat-openbsd:
 pkg.installed:
   - retry:
      attempts: 3
      interval: 15

# provider variables and code
{% if grains['provider'] == 'azure' %}
include:
  - provider.azure.nfsv4
  {% set nfs_options = "rw,hard,rsize=1048576,wsize=1048576,sec=sys,vers=4.1,tcp,_netdev" %}
{%- else %}
  {% if grains['nfs_options'] is defined %}
    {% set nfs_options = grains['nfs_options'] %}
  {%- else %}
    {% set nfs_options = "defaults,_netdev" %}
  {%- endif %}
{%- endif %}

# role variables
{% if grains['role'] == "netweaver_node" %}
  {% set site = 1 %}
  {% set mounts = ["sapmnt"] %}
  {% set mount_base = "/tmp" %}
  {% set persist = False %}
{% elif grains['role'] == "hana_node" %}
  {% if grains['provider'] == 'gcp' and grains['hana_scale_out_shared_storage_type'] == "filestore" %}
    {% set mounts = grains["nfs_mount_ip"] %}
  {% elif grains['provider'] == 'libvirt' and grains['hana_scale_out_shared_storage_type'] == "nfs" %}
    {% set mounts = grains["nfs_mount_ip"] %}
  {% elif grains['provider'] == 'openstack' and grains['hana_scale_out_shared_storage_type'] == "nfs" %}
    {% set mounts = grains["nfs_mount_ip"] %}
  {% endif %}
  {% set mount_base = "/hana" %}
  {% set persist = True %}
  {% set hana_sid = grains['hana_sid'].upper() %}
  {% set hana_instance = '{:0>2}'.format(grains['hana_instance_number']) %}
  # define sites based on even/odd hostname
  {% set host_num = grains['host']|replace(grains['name_prefix'], '') %}
  {% if (host_num|int % 2) == 1 %}
    {% set site = 1 %}
  {% elif (host_num|int % 2) == 0 %}
    {% set site = 2 %}
  {% endif %}
{% endif %}

{%- for mount in mounts %}
  # role+provider section
  {% if grains['role'] == "netweaver_node" %}
    # globally set netweaver nfs variables
    {% if grains['netweaver_nfs_share'] != "" %}
      # define IPs and share
      {% set nfs_server_ip = grains['netweaver_nfs_share'].split(':')[0] %}
      {% set nfs_share = grains['netweaver_nfs_share'] %}
    {% endif %}
    # overwrite netweaver nfs variables on a per cloud provider and scenario basis
    {% if grains['provider'] == 'aws' %}
      {% if grains['netweaver_shared_storage_type'] == "efs" %}
        # define IPs and share
        {% set nfs_server_ip = grains['efs_mount_ip'][mount][0] %}
        {% set nfs_share = nfs_server_ip + ':/' %}
      {% endif %}
    {% elif grains['provider'] == 'azure' %}
      {% if grains['netweaver_shared_storage_type'] == "anf" %}
        # define IPs and share
        {% set nfs_server_ip = grains['anf_mount_ip'][mount][0] %}
        {% set nfs_share = nfs_server_ip + ':/netweaver-' + mount %}
      {% endif %}
    {% elif grains['provider'] == 'libvirt' %}
      {% if grains['netweaver_shared_storage_type'] == "nfs" %}
        # define IPs and share
        {% set nfs_server_ip = grains['nfs_mount_ip'][mount][0] %}
        {% set nfs_share = grains['netweaver_nfs_share'] + '/' + mount %}
      {% endif %}
    {% elif grains['provider'] == 'openstack' %}
      {% if grains['netweaver_shared_storage_type'] == "nfs" %}
        # define IPs and share
        {% set nfs_server_ip = grains['nfs_mount_ip'][mount][0] %}
        {% set nfs_share = grains['netweaver_nfs_share'] + '/' + mount %}
      {% endif %}
    {% endif %}
  {% elif grains['role'] == "hana_node" %}
    {% if grains['provider'] == 'aws' %}
      {% if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "efs" %}
        # define IPs and share
        {% set nfs_server_ip = grains['efs_mount_ip'][mount][site - 1] %}
        {% set nfs_share = nfs_server_ip + ':/' + grains['name_prefix'] + '-' + mount + '-' + site|string %}
      {% endif %}
    {% elif grains['provider'] == 'azure' %}
      {% if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "anf" %}
        # define IPs and share
        {% set nfs_server_ip = grains['anf_mount_ip'][mount][site - 1] %}
        {% set nfs_share = nfs_server_ip + ':/' + grains['name_prefix'] + '-' + mount + '-' + site|string %}
      {% endif %}
    {% elif grains['provider'] == 'gcp' %}
      {% if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "filestore" %}
        # define IPs and share
        {% set nfs_server_ip = grains['nfs_mount_ip'][mount][site - 1] %}
        {% set nfs_share = nfs_server_ip + ':/' + mount + '_' + site|string %}
      {% endif %}
    {% elif grains['provider'] == 'libvirt' %}
      {% if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "nfs" %}
        # define IPs and share
        {% set nfs_server_ip = grains['nfs_mount_ip'][mount][site - 1] %}
        {% set nfs_dir = grains['nfs_mount_dir'][mount][site - 1] %}
        {% set nfs_share = nfs_server_ip + ':' + nfs_dir %}
      {% endif %}
    {% elif grains['provider'] == 'openstack' %}
      {% if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "nfs" %}
        # define IPs and share
        {% set nfs_server_ip = grains['nfs_mount_ip'][mount][site - 1] %}
        {% set nfs_share = nfs_server_ip + ':' + grains['nfs_mounting_point'] + '/' + hana_sid + '/' + hana_instance + '/' + 'site_' + site|string + '/' + mount %}
      {% endif %}
    {% endif %}
  {% endif %}

wait_until_nfs_is_ready_{{ grains['role'] }}_{{ mount }}:
  cmd.run:
    - name: until nc -zvw5 {{ nfs_server_ip }} 2049;do sleep 30;done
    - output_loglevel: quiet
    - timeout: 1200
    - require:
      - pkg: netcat-openbsd

# Add a delay to the folder creation https://github.com/SUSE/ha-sap-terraform-deployments/issues/633
wait_before_mount_{{ grains['role'] }}_{{ mount }}:
  module.run:
    - test.sleep:
      - length: 3
    - require:
      - wait_until_nfs_is_ready_{{ grains['role'] }}_{{ mount }}

mount_{{ grains['role'] }}_{{ mount }}:
  file.directory:
    - name: {{ mount_base }}/{{ mount }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: {{ mount_base }}/{{ mount }}
    - device: {{ nfs_share }}
    - fstype: nfs
    - mkmnt: True
    - persist: {{ persist }}
    - opts: {{ nfs_options }}
    - require:
      - wait_before_mount_{{ grains['role'] }}_{{ mount }}
      {%- if grains['provider'] == 'azure' %}
      - sls: provider.azure.nfsv4
      {% endif %}

permissions_{{ grains['role'] }}_{{ mount }}:
  file.directory:
    - name: {{ mount_base }}/{{ mount }}
    - user: root
    - mode: "0755"
    - makedirs: True
    - require:
      - mount_{{ grains['role'] }}_{{ mount }}

{%- endfor %}
