#! /bin/bash
set -e
find . -name \*.sh -exec bash -n {} \;
find . -name \*.tpl | while read f ; do head -1 "$f" | grep -qnE '^#! ?/bin/(ba)?sh' && bash -n "$f" ; done
find . -name \*.json -type f | while read f ; do cat "$f" | python -m json.tool >/dev/null ; done

echo "executing terraform check , init and validate for each provider"
for provider in $(find * -maxdepth 0 -type d | grep -Ev 'salt|pillar_examples'); do
  echo "============================"
  echo "doing tests for $provider"
  echo "============================"
  echo

  cd $provider ;

  /tmp/terraform fmt -check ;
  rm -f remote-state.tf ;
  if [[ "$provider" == "libvirt" ]]; then
    continue ;
  fi ;
  /tmp/terraform init ;
  if [[ "$provider" == "gcp" ]]; then
    /tmp/terraform validate -var-file=terraform.tfvars.example -var sap_hana_sidadm_password="NOT_SECRET" -var sap_hana_system_password="NOT_SECRET" -var gcp_credentials_file=/dev/null -var private_key_location=/dev/null -var public_key_location=/dev/null ;
  else
    /tmp/terraform validate -var-file=terraform.tfvars.example -var private_key_location=/dev/null -var public_key_location=/dev/null ;
  fi ;
done
