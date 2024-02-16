#!/usr/bin/env bash
#EricServic.es DNS Server Update Script

echo -e "Stop the BIND service\n"
systemctl stop named

echo -e "Check to see if AMER-EAST/ericcdn.com.zone.old file exists already.\n"
AMEREASTOLD_FILE=/var/named/AMER-EAST/ericcdn.com.zone.old
if test -f "$AMEREASTOLD_FILE"; then
    echo -e "$AMEREASTOLD_FILE already exists, need to delete.\n"
    rm /var/named/AMER-EAST/ericcdn.com.zone.old
fi

echo -e "Check to see if AMER-EAST/ericcdn.com.zone file exists already.\n"
AMEREAST_FILE=/var/named/AMER-EAST/ericcdn.com.zone
if test -f "$AMEREAST_FILE"; then
    echo -e "$AMEREAST_FILE already exists, needs to be moved.\n"
    mv /var/named/AMER-EAST/ericcdn.com.zone /var/named/AMER-EAST/ericcdn.com.zone.old
fi

echo -e "Make sure no named.conf file exists now, and download it.\n"
if [ ! -f "$AMEREAST_FILE" ]
then
curl -o /var/named/AMER-EAST/ericcdn.com.zone https://raw.githubusercontent.com/EricServices-Repo/DNS/main/config/AMER-eastern/ericcdn.com.conf
fi

echo -e "Restart the BIND service\n"
systemctl restart named
