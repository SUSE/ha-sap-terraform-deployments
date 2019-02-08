#!/bin/bash

# Summary: Script with functions to install HANA
# Authors: Ilya Manyugin <ilya.manyugin@suse.com>

# shellcheck disable=SC1091
. /etc/os-release

#EXPECT_SCRIPT="$(pwd)/install_hana.expect"
MEDIA_DIR=/root/sap_inst
HANA_VOLUME=vdc
IS_HANA_2=0

mem_kb=$(head -n1 /proc/meminfo | awk '{ print $2 }')
mem_gb=$(echo "scale=2; $mem_kb/1024/1024" | bc -l)

# Make bash 3.2 on SLES 11 happy
# bash 4 supports vvv=${2^^} expansion
function uppercase(){
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

function good_msg(){
	echo -e "\e[1m\e[32m$1\e[0m"
}

function ok_msg(){
	echo -e "\e[33m$1\e[0m"
}

function bad_msg(){
	echo -e "\e[1m\e[31m$1\e[0m"
}

function die(){
	bad_msg "Error: $1"
	exit 1
}

function usage(){
	local script
	script=$(basename "$0")
	echo "$script [key | lk | bck | bkp | fw | clean | -h | inst]"
	cat <<-EOF
	key 	create a secure user store key xxxadm
	lk      list keys from the secure user store
	bck    	perform HANA backup using the secure key xxxadm
	bkp    	backup HANA production files (global.ini and hook)
	fw     	disable susefirewall
	clean   clean system (as if the cluster config wasn't there)
	inst 	install HANA [SPS12] [QAS|PRD|OUT|XXX] [virt]
	-h      print this message and quit
EOF
}

function create_key(){
	good_msg "Creating a secure user store key xxxadm..."
	ok_msg "Executing | su -lc 'hdbuserstore SET xxxadm \"localhost:30015\" system SECRET_PASSWORD' xxxadm |"
	su -lc 'hdbuserstore SET xxxadm "localhost:30015" system SECRET_PASSWORD' xxxadm; rc=$?
	exit $rc
}

function list_keys(){
	good_msg "Listing available keys from the secure user store..."
	ok_msg "Executing | su -lc 'hdbuserstore LIST' xxxadm |"
	su -lc 'hdbuserstore LIST' xxxadm; rc=$?
	exit $rc	
}

function create_backup(){
	good_msg "Creating backup..."
	ok_msg "Executing | su -lc \"hdbsql -U xxxadm \"BACKUP DATA USING FILE ('backup')\"\" xxxadm |"
	su -lc "hdbsql -U xxxadm \"BACKUP DATA USING FILE ('backup')\"" xxxadm; rc=$?
	exit $rc
}

function disable_firewall(){
	good_msg "Disabling firewall..."
	ok_msg "Executing | systemctl stop SuSEfirewall2 |"
	systemctl stop SuSEfirewall2 || die "Could not stop firewall"
	systemctl disable SuSEfirewall2 || die "Could not disable firewall"
	exit $rc
}

function clean_system(){
	good_msg "Cleaning the system"

	ok_msg "Cleaning the cluster configuration"
	for i in $(seq 1 5); do
		echo ">> step $i: stopping"
    	crm configure property stop-all-resources=yes
    	echo ">> erasing"
    	crm configure erase
    	sleep 3
    	echo "... and repeating"
    done    

	ok_msg "Disabling the services"
	systemctl stop hawk pacemaker
	systemctl disable hawk pacemaker csync2 sbd

	ok_msg "Deleting configs"
	rm -f /etc/corosync/authkey 2>/dev/null
	rm -f /etc/csync2/key_hagroup 2>/dev/null

	exit 0
}

function backup_production(){
	# test the hana_adjust_production_system call
	# local action=${1:-check}
	# local action=${1:-check}
	# local systemid=${2:-XXX}
	local systemid="XXX"
	good_msg "Backing up the production"
	# local bkpath="/root/hbackup.$$"
	local hook_dir="/hana/shared/$systemid/srHook"
	local hook_file="srTakeover.py"
	local glob_ini_path="/hana/shared/$systemid/global/hdb/custom/config/global.ini"
	
	# action = check
	ok_msg "> Hook directory: $hook_dir"
	if [[ -d $hook_dir ]]; then
		good_msg "\tExists:"
		local hook_path="$hook_dir/$hook_file"
		ok_msg "> Hook script: $hook_path"
		if [[ -f $hook_path ]]; then
			good_msg "\tExists"
			head -n10 $hook_path
		else
			bad_msg "\tDoes not exist"
		fi
	else
		bad_msg "\tDoes not exist"
	fi
	echo
	ok_msg "> global.ini: $glob_ini_path"
	if [[ -f $glob_ini_path ]]; then
		good_msg "\tExists"
		gal=$(grep -i "global_allocation_limit" "$glob_ini_path")
		ok_msg "\t* global_allocation_limit:"
		if [[ -z $gal ]]; then
			bad_msg "\t\tNot set"
		else
			good_msg "$gal"
		fi
		pct=$(grep -i "preload_column_tables" "$glob_ini_path")
		ok_msg "\t* preload_column_tables:"
		if [[ -z $pct ]]; then
			bad_msg "\t\tNot set"
		else
			good_msg "$pct"
		fi
	else
		bad_msg "\tDoes not exist"
	fi

	# ls -l $hook_path 2>/dev/null; rc=$?
	# if [[ rc -ne 0 ]]; then
		
	# fi
	# ls -l $glob_ini_path 2>/dev/null; rc=$?


	# # action = backup
	# mkdir $bkpath
	exit 0
}

case "$1" in
	bkp )
		backup_production
		;;
	key )
		create_key
		;;
	lk )
		list_keys
		;;
	bck )
		create_backup
		;;
	fw )
		disable_firewall
		;;
	clean )
		clean_system
		;;
	-h )
		usage
		exit 0
		;;
	inst)
		vvv=$(uppercase "$2")
		HANA_VERSION=${vvv:-SPS12}
		HANA_SYS=$(uppercase ${3:-XXX})
		CFG_DIR="$MEDIA_DIR/hana_inst_config_${HANA_SYS}"
		virt=$(uppercase "$4")
		if [[ $virt == 'VIRT' ]]; then
			HANA_VIRTUAL_HOST=1
		else
			HANA_VIRTUAL_HOST=0
		fi
		;;
	* )
		usage
		die "Incorrect arguments"
		;;
esac

case $HANA_VERSION in
	SPS03 )
#		INST_DIR=$MEDIA_DIR/51052481/DATA_UNITS/HDB_LCM_LINUX_X86_64
		INST_DIR=$MEDIA_DIR/51053381/DATA_UNITS/HDB_LCM_LINUX_X86_64
		IS_HANA_2=1
		;;
	SPS02 )
		INST_DIR=$MEDIA_DIR/51052325/DATA_UNITS/HDB_LCM_LINUX_X86_64
		IS_HANA_2=1
		;;
	SPS01 )
		INST_DIR=$MEDIA_DIR/51052030/DATA_UNITS/HDB_LCM_LINUX_X86_64
		IS_HANA_2=1
		;;
	SPS00 ) # HANA 2.0
		INST_DIR=$MEDIA_DIR/51051635/DATA_UNITS/HDB_LCM_LINUX_X86_64
		IS_HANA_2=1
		;;
	SPS12 )
		# INST_DIR=$MEDIA_DIR/51051151/DATA_UNITS/HDB_LCM_LINUX_X86_64 # SPS12        
		INST_DIR=$MEDIA_DIR/51051857/DATA_UNITS/HDB_LCM_LINUX_X86_64 # SPS12 DSP(SAP HANA DB 1.00.122.6)       
		;;
	SPS11 )
		INST_DIR=$MEDIA_DIR/51050838/DATA_UNITS/HDB_LCM_LINUX_X86_64
		;;
	SPS10 )
		INST_DIR=$MEDIA_DIR/51050456/DATA_UNITS/HDB_LCM_LINUX_X86_64
		;;
	* )
		die "There is no installation media for HANA version '$HANA_VERSION'"
		;;
esac

good_msg "Installing HANA version ${HANA_VERSION}"

# Check the volume

lsblk | grep $HANA_VOLUME ; rc=$?
if ! [ -d /hana ] && [ $rc -ne 0 ]; then
	bad_msg "Error: Could not find the /dev/$HANA_VOLUME or /hana for HANA"
	exit 1
fi

if [ ! -d /hana ]; then
	ok_msg "Creating and mounting /hana"
	mkdir -v /hana
	# make partition table
	ok_msg ">> parted --script /dev/$HANA_VOLUME mklabel msdos"
	parted --script /dev/$HANA_VOLUME mklabel msdos
	ok_msg ">> parted --script /dev/$HANA_VOLUME mkpart primary ext2 1M 100%"
	parted --script /dev/$HANA_VOLUME mkpart primary ext2 1M 100%

	# if [[ $VERSION == "11.4" ]]; then
	# 	HANA_FS_TYPE="ext3"
	# else
	# 	# HANA_FS_TYPE="ext4"
	# 	HANA_FS_TYPE="xfs"
	# fi
	HANA_FS_TYPE="xfs"
	
	ok_msg ">> mkfs.$HANA_FS_TYPE /dev/${HANA_VOLUME}1"
	sleep 1
	mkfs.$HANA_FS_TYPE /dev/${HANA_VOLUME}1 || die "Could not format /dev/${HANA_VOLUME}1"
	# echo -e "/dev/${HANA_VOLUME}1\t/hana\t${HANA_FS_TYPE}\trw,acl,user_xattr\t0  0" >> /etc/fstab
	echo -e "/dev/${HANA_VOLUME}1\t/hana\t${HANA_FS_TYPE}\tdefaults\t0  0" >> /etc/fstab
	mount /hana || die "Could not mount /hana"
	ok_msg "Done!"
else
	ok_msg "/hana exists, skipping file system creation"
fi


# Memory check

ok_msg "You have $mem_gb GB of memory"

if [[ $IS_HANA_2 -eq 1 ]]; then
	# config_profile="--configfile=$CFG_DIR/hdblcm_hana2.0_$(hostname -s).conf"
	config_profile="--configfile=$CFG_DIR/hdblcm_hana2.0_$(hostname).conf"
else
	config_profile="--configfile=$CFG_DIR/hdblcm_$(hostname -s).conf"
	if [[ $HANA_VIRTUAL_HOST -eq 1 ]]; then
		config_profile="--configfile=$CFG_DIR/hdblcm_$(hostname)_virt.conf"
	fi
fi

if (( $(echo "$mem_gb < 24" |bc -l) )); then
	ok_msg "The minimum required memory amount is 24 GB. Forcing the installation."
	additional_params="$config_profile --hdbinst_server_ignore=check_min_mem"
else
	additional_params="$config_profile"
fi

additional_params="$additional_params --ignore=check_platform"

cd $INST_DIR || die "Could not change to $INST_DIR"

# Run the installer

if [[ -n $DISPLAY ]]; then
	ok_msg "Running in GUI mode, DISPLAY is '$DISPLAY'."
	echo "executing ./hdblcmgui $additional_params"
	# expect -f $EXPECT_SCRIPT $additional_params
	./hdblcmgui $additional_params -b
else
	ok_msg "Running in console"
	# expect -f $EXPECT_SCRIPT $additional_params
	echo "executing ./hdblcm $additional_params"
	./hdblcm $additional_params -b
fi

