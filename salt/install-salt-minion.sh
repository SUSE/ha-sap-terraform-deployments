#!/bin/bash
REGISTER="false"
DEREGISTER="false"

function print_help(){
    cat <<-EOF

Install the salt-minion

If registration code is provided it will be installed from the official SUSE Repositories.

For this, a Registration Code is required and your system will be
connected to the SUSE Customer Center.

Supported Options:

  -r [REG CODE]    Registration Code that will be used to register the system.
  -d               Deregister the System after the salt-minion installation (only makes sense if -r flag is set)
  -h               Show this help.

EOF
}



function install_salt_minion(){

    # If required, REGISTER
    if [[ $REGISTER != "false" ]]; then
      # Check SLE version
      source /etc/os-release
      # Register the system on SCC
      SUSEConnect -r "$REGISTER"

      # Register the modules accordingly with the SLE version.
      if [[ $VERSION_ID =~ ^12\.? ]]; then
        SUSEConnect -p sle-module-adv-systems-management/12/x86_64
      elif [[ $VERSION_ID =~ ^15\.? ]]; then
        SUSEConnect -p sle-module-basesystem/$VERSION_ID/x86_64
      else
        echo "SLE Product version not supported by this script. Please, use version 12 or higher."
        exit 1
      fi
    fi

    # We have to force refresh the repos and the keys (keys may change during lifetime of this OS/image)
    zypper --non-interactive --gpg-auto-import-keys refresh --force --services
    zypper --non-interactive install salt-minion

    # If required, DEREGISTER
    if [[ $REGISTER != "false" && $DEREGISTER != "false" ]]; then
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
        REGISTER="$OPTARG"
        ;;
    *)
        echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
  esac
done
install_salt_minion
