#cloud-config

cloud_config_modules:
  - runcmd

cloud_final_modules:
  - scripts-user

runcmd:
  - |
    # add any command here
