{% set data = salt['pillar.get']('data') %}
{% set uuid = salt['disk.blkid'](data.device)[data.device]['UUID'] %}

{{ data.device }}_directory_mount_azure:
  file.directory:
    - name: {{ data.path }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: {{ data.path }}
    - device: UUID={{ uuid }}
    - fstype: {{ data.fstype }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
