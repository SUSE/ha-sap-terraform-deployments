#!/usr/bin/env bash
set -eo pipefail
# Script to provision the machines using salt. It provides different stages to install and
# configure salt and run different salt executions. Find more information in print_help method
# or running `sh provision.sh -h`

get_grain () {
    re="$1:\s*(.*)"
    grains_file=$2
    grains_file=${grains_file:="/etc/salt/grains"}
    grains_content=$(grep -E "$re" "$grains_file")
    if [[ $grains_content =~ $re ]]; then
        echo "${BASH_REMATCH[1]}";
        return 0
    else
        return 1
    fi
}

log_ok () {
    node=$(hostname)
    timestamp=$(date -u)
    message="$timestamp::$node::[INFO] $1"
    if [[ "$(get_grain provisioning_output_colored)" == "true" ]]; then
      green="\033[0;32m"
      nc="\033[0m" # No Color
      echo -e "$green$message $nc"
    else
      echo -e "$message"
    fi
}

log_error () {
    node=$(hostname)
    timestamp=$(date -u)
    message="$timestamp::$node::[ERROR] $1"
    if [[ "$(get_grain provisioning_output_colored)" == "true" ]]; then
      red="\033[0;31m"
      nc="\033[0m" # No Color
      echo -e "$red$message $nc"
    else
      echo -e "$message"
    fi
    exit 1
}

salt_color_flag () {
    if [[ "$(get_grain provisioning_output_colored)" == "true" ]]; then
        echo "--force-color"
    else
        echo "--no-color"
    fi
}

install_salt_minion () {
    reg_code=$1
    # If required, register
    if [[ $reg_code != "" ]]; then
      # Check SLE version
      source /etc/os-release
      # Register the system on SCC
      SUSEConnect -r "$reg_code"

      # Register the modules accordingly with the SLE version.
      if [[ $VERSION_ID =~ ^12\.? ]]; then
        # shellcheck disable=SC2046
        SUSEConnect -p sle-module-adv-systems-management/12/$(uname -m)
      elif [[ $VERSION_ID =~ ^15\.? ]]; then
        # shellcheck disable=SC2046
        SUSEConnect -p sle-module-basesystem/${VERSION_ID:+"$VERSION_ID"}/$(uname -m)
      else
        log_error "SLE Product version not supported by this script. Please, use version 12 or higher."
      fi
    fi

    # We have to force refresh the repos and the keys (keys may change during lifetime of this OS/image)
    zypper --non-interactive --gpg-auto-import-keys refresh --force --services
    zypper --non-interactive install salt-minion

    # deregister
    if [[ $reg_code != "" ]]; then
       SUSEConnect -d
    fi
}

repeat_command () {
    cmd=$1
    timeout=${2:-120}
    interval=${3:-15}
    timeout "$timeout" bash -c "until $cmd;do sleep $interval;done"
}

bootstrap_salt () {
    # handle case where something exists already in /srv/salt
    mkdir -p /srv/salt
    cp -R /tmp/salt/* /srv/salt || true
    rm -rf /tmp/salt
    mkdir -p /srv/pillar
    cp -R /tmp/pillar/* /srv/pillar || true
    rm -rf /tmp/pillar

    # Check if offline_mode is enabled
    [[ "$(get_grain offline_mode /tmp/grains)" == "true" ]] && offline_mode=1
    # Get registration code
    reg_code=$(get_grain reg_code /tmp/grains)
    # Check if salt-call is installed
    command -v salt-call > /dev/null 2>&1 && salt_installed=1

    # Workaround for the cases where the cloud providers are coming without repositories
    # https://www.suse.com/support/kb/doc/?id=7022311
    # Check if the deployment is executed in a cloud provider
    [[ "$(get_grain provider /tmp/grains)" =~ aws|azure|gcp ]] && cloud=1
    if [[ ${offline_mode} != 1 && ${cloud} == 1 && "${reg_code}" == "" ]]; then
        repeat_command "systemctl is-active guestregister.service | grep inactive" 300
        zypper lr || sudo /usr/sbin/registercloudguest --force-new
    fi

    # Install salt if offline_mode is False and salt is not already installed
    if [[ ${offline_mode} != 1 && ${salt_installed} != 1 ]]; then
        install_salt_minion "${reg_code}"
    fi

    # Recheck if salt-call is installed. If it's not available stop execution
    command -v salt-call || log_error "salt call isn't installed"
    # Move salt grains to salt folder
    mkdir -p /etc/salt;mv /tmp/grains /etc/salt || true
    log_ok "bootstrapped salt"
}

os_setup () {
    # Execute the states within /srv/salt/os_setup
    # This first execution is done to configure the salt minion and install the iscsi formula
    # shellcheck disable=SC2046
    salt-call --local \
        --log-level=$(get_grain provisioning_log_level) \
        --log-file=/var/log/salt-os-setup.log \
        --log-file-level=debug \
        --retcode-passthrough \
        $(salt_color_flag) \
        state.apply os_setup || log_error "os setup failed"
    log_ok "os setup done"
}

predeploy () {
    # Execute the states defined in /srv/salt/top.sls
    # This execution is done to pre configure the cluster nodes, the support machines and install the formulas
    # shellcheck disable=SC2046
    salt-call --local \
        --log-level=$(get_grain provisioning_log_level) \
        --log-file=/var/log/salt-predeployment.log \
        --log-file-level=debug \
        --retcode-passthrough \
        $(salt_color_flag) \
        state.highstate saltenv=predeployment || log_error "predeployment failed"
    log_ok "predeployment done"
}

deploy () {
    # Execute SAP and HA installation with the salt formulas
    if [[ $(get_grain role) =~ .*_node ]]; then
        # shellcheck disable=SC2046
        salt-call --local \
            --log-level=$(get_grain provisioning_log_level) \
            --log-file=/var/log/salt-deployment.log \
            --log-file-level=debug \
            --retcode-passthrough \
            $(salt_color_flag) \
            state.highstate saltenv=base || log_error "deployment failed"
        log_ok "deployment done"
    fi
}

run_tests () {
    [[ "$(get_grain hwcct)" == "true" ]] && hwcct_mode=1
    if [[ ${hwcct_mode} && $(get_grain role) == hana_node ]]; then
        # We need to export HOST with the new hostname set by Salt
        # Otherwise, hwcct will error out.
        HOST=$(hostname)
        export HOST
        # Execute qa state file
        # shellcheck disable=SC2046
        salt-call --local \
            --log-level=$(get_grain provisioning_log_level) \
            --log-file=/var/log/salt-qa.log \
            --log-file-level=debug \
            --retcode-passthrough \
            $(salt_color_flag) \
            state.apply hwcct || log_error "hwcct execution failed"
        log_ok "tests done"
    fi
}

print_help () {
    cat <<-EOF
Provision the machines. The provisioning has different steps, so they can be executed depending on
the selected flags. The actions are always executed in the same order (if multiple are selected),
from top to bottom in this help text.

Supported Options (if no options are provided (excluding -l) all the steps will be executed):
  -s               Bootstrap salt installation and configuration. It will register to SCC channels if needed
  -o               Execute OS setup operations. Register to SCC, updated the packages, etc
  -p               Execute predeployment operations (update hosts and hostnames, install support packages, etc)
  -d               Execute deployment operations (install sap, ha, drbd, etc)
  -q               Execute qa tests
  -l [LOG_FILE]    Append the log output to the provided file
  -h               Show this help.
EOF
}

argument_number=0
while getopts ":hsopdql:" opt; do
    argument_number=$((argument_number + 1))
    case $opt in
        h)
            print_help
            exit 0
            ;;
        s)
            excute_bootstrap_salt=1
            ;;
        o)
            excute_os_setup=1
            ;;
        p)
            excute_predeploy=1
            ;;
        d)
            excute_deploy=1
            ;;
        q)
            excute_run_tests=1
            ;;
        l)
            log_to_file=$OPTARG
            ;;
        *)
            echo "Invalid option -$OPTARG" >&2
            print_help
            exit 1
            ;;
    esac
done

if [[ -n $log_to_file ]]; then
    argument_number=$((argument_number - 1))
    # Find the logic of the next command in: https://unix.stackexchange.com/questions/145651/using-exec-and-tee-to-redirect-logs-to-stdout-and-a-log-file-in-the-same-time
    exec > >(tee -a "$log_to_file")
fi

if [ $argument_number -eq 0 ]; then
    bootstrap_salt
    os_setup
    predeploy
    deploy
    run_tests
else
    [[ -n $excute_bootstrap_salt ]] && bootstrap_salt
    [[ -n $excute_os_setup ]] && os_setup
    [[ -n $excute_predeploy ]] && predeploy
    [[ -n $excute_deploy ]] && deploy
    [[ -n $excute_run_tests ]] && run_tests
fi
exit 0
