#!/usr/bin/env bash
#EricServic.es DNS Server

##### Variables ###############################
# DOMAIN - Email Domain
###############################################

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

read -p "Set DOMAIN [ericservic.es]:" DOMAIN
DOMAIN="${DOMAIN:=ericservic.es}"
echo "$DOMAIN"


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
yum install open-vm-tools firewalld wget named -y 

echo -e "${GREEN}Turning on the Firewall${ENDCOLOR}"
systemctl enable firewalld
systemctl restart firewalld

echo -e "${GREEN}Allow Ports for Email Server on Firewall\n${ENDCOLOR}"
firewall-cmd --permanent --add-port={53/udp}

echo -e "${GREEN}Reload the firewall.\n${ENDCOLOR}"
firewall-cmd --reload

echo -e "${GREEN}Ports allowed on firewall.\n${ENDCOLOR}"
firewall-cmd --list-all

# Permissive Mode #
###################
echo -e "${GREEN}Setting to Permissive Mode for install\n${ENDCOLOR}"
setenforce 0

echo -e "${GREEN}Setting Permissive SELINUX value.\n${ENDCOLOR}"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
