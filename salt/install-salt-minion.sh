#!/bin/bash
DEREGISTER="false"

function print_help(){
    cat <<-EOF

Install the salt-minion provided via the official SUSE Repositories.

For this, a Registration Code is required and your system will be 
connected to the SUSE Customer Center.

Supported Options:

  -r [REG CODE]    Registration Code that will be used to register the system.
  -d               Deregister the System aften the salt-minion installation
  -h               Show this help. 

EOF
}



function install_salt_minion(){
    local regcode=$1

    # Check SLE version
    source /etc/os-release

    SUSEConnect -r "$regcode"

    # Register the modules accordingly with the SLE version.
    if [[ $VERSION == *"12"* ]]; then    
      SUSEConnect -p sle-module-adv-systems-management/12/x86_64
    elif [[ $VERSION == *"15"* ]]; then  
      SUSEConnect -p sle-module-basesystem/$VERSION_ID/x86_64
    else 
      echo "SLE Product version not supported by this script. Please, use version 12 or higher." 
      exit 1
    fi
    
    zypper --non-interactive install salt-minion

    # If required, DEREGISTER 
    if [[ $DEREGISTER == "true" ]]; then
       SUSEConnect -d
    fi
}      


while getopts ":hdr:" opt; do
  case $opt in
    h)
        print_help
        exit 0
        ;; 
    d) 
        DEREGISTER="true"
        ;;
    r)
        install_salt_minion "$OPTARG"
        exit 0 
        ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

