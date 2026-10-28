#!/bin/sh
#Append MAC address to hostname

if [ -e /etc/ethernetmac.eth0 ] ; then
    HOSTNAME_STEM="$(hostname | sed -e 's/\-.*//')"
    HOSTNAME_MAC="${HOSTNAME_STEM}-$(cat /etc/ethernetmac.eth0 | sed -e "s/\://g" -e "y/ABCDEF/abcdef/")"
    hostname ${HOSTNAME_MAC}
fi
