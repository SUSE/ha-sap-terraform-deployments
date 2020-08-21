install_sssd_packages:
  pkg.latest:
    - pkgs:
      - realmd
      - adcli
      - sssd
      - sssd-tools
      - sssd-ad
      - samba-client
 
