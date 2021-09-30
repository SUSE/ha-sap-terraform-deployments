# check if iscsi-formula should be installed
{%- if grains.get('role') == "iscsi_srv" %}
iscsi-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
{%- endif %}

# iscsi kernel modules are not available in kernel-default-base
# There is not reliable way to switch kernels directly with salt as dependency resolution is not yet implemented.
kernel-default-install:
  cmd.run:
    - name: zypper -n install --force-resolution kernel-default
    # install kernel-default if kernel-default-base is installed, do not touch otherwise
    - only_if:
      - rpm -q kernel-default-base

kernel-default-base-remove:
  pkg.removed:
    - name: kernel-default-base
    - retry:
        attempts: 3
        interval: 15
    - require:
      - cmd: kernel-default-install

