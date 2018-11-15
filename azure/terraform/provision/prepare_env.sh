#!/bin/bash

source /etc/os-release

function verlte()
{
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

function verlt()
{
    [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

function format_and_mount()
{
    local HANA_VOLUME=${1:-vdc}
    local MOUNT_POINT=${2:-"/hana"}
    local HANA_FS_TYPE=${3:-ext4}
    local HANA_PART

    echo "HANA_VOLUME=$HANA_VOLUME, MOUNT_POINT=$MOUNT_POINT, HANA_FS_TYPE=$HANA_FS_TYPE"

    local DMVAL=$(sudo multipath -l -v1 "/dev/sdc")
    test -n "$DMVAL" && HANA_VOLUME="mapper/$DMVAL"

    echo ">> mkdir -v $MOUNT_POINT"
    mkdir -v $MOUNT_POINT
    echo ">> parted --script /dev/$HANA_VOLUME mklabel msdos"   
    parted --script /dev/$HANA_VOLUME mklabel msdos
    echo ">> parted --script /dev/$HANA_VOLUME mkpart primary ext2 1M 100%"
    parted --script /dev/$HANA_VOLUME mkpart primary ext2 1M 100%
    sleep 1
    if [[ -n "$DMVAL" ]]; then
      HANA_PART="/dev/${HANA_VOLUME}-part1"
    else
      HANA_PART="/dev/${HANA_VOLUME}1"
    fi
    echo ">> mkfs.$HANA_FS_TYPE ${HANA_PART}"
    mkfs.$HANA_FS_TYPE ${HANA_PART} || die "Could not format ${HANA_PART}"
    if [[ $HANA_FS_TYPE -eq "xfs" ]]; then
      echo -e "${HANA_PART}\t${MOUNT_POINT}\t${HANA_FS_TYPE}\trw\t0 0" >> /etc/fstab
    else
      echo -e "${HANA_PART}\t${MOUNT_POINT}\t${HANA_FS_TYPE}\trw,acl,user_xattr\t0 0" >> /etc/fstab
    fi
    mount $MOUNT_POINT || die "Could not mount $MOUNT_POINT"
    echo "Done!"
}

cat <<-END >> /root/.bashrc
    alias ll='ls -l'
    alias yopen='less /var/log/YaST2/y2log'
    alias ytail='tail -f /var/log/YaST2/y2log'
    alias ydel='rm /var/log/YaST2/y2log'
    run='cd /root/yast-sap-ha ;  ./run.sh'
    alias hins='cd /root/sap_inst; ./install_hana.sh'
END

format_and_mount "$1" "$2" "$3"
