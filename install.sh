#!/usr/bin/env bash
#EricServic.es DNS Server

##### Variables ######################################
# DOMAIN - Authoritative Domain
# GEOIPACCT - GeoIP Account Number
# GEOIPKEY - GeoIP Key
# IPADDR - Nameserver IP Address
# SECONDARYIPADDR - Secondary Nameserver IP Address
######################################################

#################
# Define Colors #
#################
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${GREEN}EricServic.es DNS Server${ENDCOLOR}"

echo -e "${BLUE} ______      _       _____                 _                    ${ENDCOLOR}"  
echo -e "${BLUE}|  ____|    (_)     / ____|               (_)                   ${ENDCOLOR}"
echo -e "${BLUE}| |__   _ __ _  ___| (___   ___ _ ____   ___  ___   ___  ___    ${ENDCOLOR}"
echo -e "${BLUE}|  __| | '__| |/ __|\___ \ / _ \ '__\ \ / / |/ __| / _ \/ __|   ${ENDCOLOR}"
echo -e "${BLUE}| |____| |  | | (__ ____) |  __/ |   \ V /| | (__ |  __/\__ \   ${ENDCOLOR}"
echo -e "${BLUE}|______|_|  |_|\___|_____/ \___|_|    \_/ |_|\___(_)___||___/ \n${ENDCOLOR}"

#####################
# Set all Variables #
#####################
echo -e "${GREEN}Set Variables for custom install.${ENDCOLOR}"

read -p "Set DOMAIN [ericcdn.com]:" DOMAIN
DOMAIN="${DOMAIN:=ericcdn.com}"
echo "$DOMAIN"

read -p "Set GeoIP Account Number [0]:" GEOIPACCT
GEOIPACCT="${GEOIPACCT:=0}"
echo "$GEOIPACCT"

read -p "Set GeoIP Key [0000000000]:" GEOIPKEY
GEOIPKEY="${GEOIPKEY:=00000000}"
echo "$GEOIPKEY"

read -p "Is this the Primary Nameserver [Y/n]:" PRIMARYNS
PRIMARYNS="${PRIMARYNS:=Y}"
echo "$PRIMARYNS"

################################
# Updates + Install + Firewall #
################################
echo -e "${GREEN}Process updates and install${ENDCOLOR}"
sleep 1

echo -e "Yum Update"
yum update -y

echo -e "Install epel-release"
yum install epel-release -y

echo -e "${GREEN}Check to see if required programs are installed.${ENDCOLOR}"
yum install open-vm-tools firewalld wget named geoip geoipupdate -y 

echo -e "${GREEN}Turning on the Firewall${ENDCOLOR}"
systemctl enable firewalld
systemctl restart firewalld

echo -e "${GREEN}Allow Ports for Email Server on Firewall\n${ENDCOLOR}"
firewall-cmd --permanent --add-port={53/udp,53/tcp}

echo -e "${GREEN}Reload the firewall.\n${ENDCOLOR}"
firewall-cmd --reload

echo -e "${GREEN}Ports allowed on firewall.\n${ENDCOLOR}"
firewall-cmd --list-all


###################
# Permissive Mode #
###################
echo -e "${GREEN}Setting to Permissive Mode for install${ENDCOLOR}"
setenforce 0

echo -e "${GREEN}Setting Permissive SELINUX value${ENDCOLOR}"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config



###########################
# Configure Named Service #
###########################

echo -e "${GREEN}Configure Named Service${ENDCOLOR}"

echo -e "Check to see if nginx.conf.old file exists already.\n"
NAMEDOLD_FILE=/etc/named.conf.old
if test -f "$NAMEDOLD_FILE"; then
    echo -e "$NAMEDOLD_FILE already exists, need to delete.\n"
    rm /etc/named.conf.old
fi

echo -e "Check to see if nginx.conf file exists already.\n"
NAMED_FILE=/etc/named.conf
if test -f "$NAMED_FILE"; then
    echo -e "$NAMED_FILE already exists, needs to be moved.\n"
    mv /etc/named.conf /etc/named.conf.old
fi

echo -e "Make sure no nginx.conf file exists now, and download it.\n"
if [ ! -f "$NAMED_FILE" ]
then
curl -o /etc/named.conf https://raw.githubusercontent.com/EricServices-Repo/DNS/main/config/named.conf
fi

sed -i 's/IPADDR/$IPADDR/' /etc/named.conf
