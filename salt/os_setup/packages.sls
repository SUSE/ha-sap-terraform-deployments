# check if iscsi-formula should be installed
{%- if grains.get('role') == "iscsi_srv" %}
iscsi-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
{%- endif %}

# iscsi kernel modules are not available in kernel-default-base
kernel-default-base:
  pkg.removed:
  - retry:
      attempts: 3
      interval: 15

kernel-default:
  pkg.installed:
  - retry:
      attempts: 3
      interval: 15
  # install kernel-default if kernel-default-base is installed, do not touch otherwise
  - require:
    - pkg: kernel-default-base
