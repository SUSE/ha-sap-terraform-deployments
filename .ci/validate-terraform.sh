#! /bin/bash
set -e
find . -name \*.sh -exec bash -n {} \;
find . -name \*.tpl | while read f ;
do
  if [[ $(head -1 "$f") == *"/bin/bash"* ]]; then
    echo "Testing tpl file: $f"
    bash -n "$f"
  fi
done


echo "executing terraform check , init and validate for each provider"
for provider in $(find * -maxdepth 0 -type d | grep -Ev 'salt|pillar_examples|doc|pillar'); do
  echo "============================"
  echo "doing tests for $provider"
  echo "============================"
  echo

  cd $provider ;
  echo "--------------------------"
  echo " executing terraform fmt"
  echo "--------------------------"
  /tmp/terraform fmt -check ;
  rm -f remote-state.tf ;
  if [[ "$provider" == "libvirt" ]]; then continue ; fi ;
  echo "--------------------------"
  echo "** PASSED ** "
  echo "--------------------------"


  echo "--------------------------"
  echo " executing terraform init"
  echo "--------------------------"
  /tmp/terraform init ;
  echo "--------------------------"
  echo "** PASSED ** "
  echo "--------------------------"


  echo "--------------------------"
  echo " executing terraform validate"
  echo "--------------------------"

  if [[ "$provider" == "gcp" ]]; then
    /tmp/terraform validate -var-file=terraform.tfvars.example -var gcp_credentials_file=/dev/null -var private_key_location=/dev/null -var public_key_location=/dev/null ;
  else
    /tmp/terraform validate -var-file=terraform.tfvars.example -var private_key_location=/dev/null -var public_key_location=/dev/null ;
  fi ;
  echo "-------> $provider ALL tests PASSED!"
  cd ..
done
