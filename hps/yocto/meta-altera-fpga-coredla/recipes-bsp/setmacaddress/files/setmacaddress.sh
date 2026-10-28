#!/bin/sh
# Attempt to set MAC address for given interface.  Search in turn
# 1) NV storage 
# 2) /etc/ethernetmac.<interface>
# 3) ifconfig

IFACE=eth0              #TODO is there a way to get during boot, vs. hardcoding?
NV_STORAGE="mmcblk0p1"
MAC_REGEX='[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}'
MAC_ADDRESS_FILE="ethernetmac.$1"
MAC_ETHERNETMAC=$(grep -o -i ${MAC_REGEX} "/etc/${MAC_ADDRESS_FILE}")

# Get MAC address from SD card if available (mounting partition if necessary)
SD_MOUNT=$(grep ${NV_STORAGE} /proc/mounts)
if [[ -z "${SD_MOUNT}" ]]; then
    mount /dev/${NV_STORAGE} /mnt
    MACADDRESS=$(grep -i -o ${MAC_REGEX} "/mnt/${MAC_ADDRESS_FILE}" 2>/dev/null)
    umount /mnt
else
    MOUNT_PATH=$(echo ${SD_MOUNT} | awk '{print $2}')
    MACADDRESS=$(grep -i -o ${MAC_REGEX} "${MOUNT_PATH}/${MAC_ADDRESS_FILE}" 2>/dev/null)
fi

# Get MAC address from /etc/${MAC_ADDRESS_FILE}, then ifconfig
if [[ -z "${MACADDRESS}" ]]; then
    if [ -n "${MAC_ETHERNETMAC}" ] ; then
	MACADDRESS="${MAC_ETHERNETMAC}"
    else
	MACADDRESS=$(ifconfig $IFACE | grep -o -i ${MAC_REGEX})
    fi
fi

# update mac address file if different
if [[ "$MACADDRESS" != "$MAC_ETHERNETMAC" ]]; then
    echo ${MACADDRESS} >/etc/${MAC_ADDRESS_FILE}
fi

/sbin/ifconfig $IFACE down && /sbin/ifconfig $IFACE hw ether ${MACADDRESS} && /sbin/ifconfig $IFACE up
