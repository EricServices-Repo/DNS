#!/usr/bin/env bash
#EricServic.es DNS Server

##### Variables ###############################
# DOMAIN - Authoritative Domain
# GEOIPACCT - GeoIP Account Number
# GEOIPKEY - GeoIP Key
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

read -p "Set DOMAIN [ericcdn.com]:" DOMAIN
DOMAIN="${DOMAIN:=ericcdn.com}"
echo "$DOMAIN"

read -p "Set GeoIP Account Number [0]:" GEOIPACCT
GEOIPACCT="${GEOIPACCT:=0}"
echo "$GEOIPACCT"

read -p "Set GeoIP Key [0000000000]:" GEOIPKEY
GEOIPKEY="${GEOIPKEY:=00000000}"
echo "$GEOIPKEY"

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
mv /etc/named.conf /etc/named.conf.old

cat << EOF >> /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
// See the BIND Administrator's Reference Manual (ARM) for details about the
// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
        listen-on port 53 { $IPADDRESS; };
        //listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
        rate-limit {
            ipv4-prefix-length 32;
            window 10;
            responses-per-second 5;
            errors-per-second 1;
            nxdomains-per-second 1;
            slip 2;
        };


	/*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
         - If you are building a RECURSIVE (caching) DNS server, you need to enable
           recursion.
         - If your recursive DNS server has a public IP address, you MUST enable access
           control to limit queries to your legitimate users. Failing to do so will
           cause your server to become part of large scale DNS amplification
           attacks. Implementing BCP38 within your network would greatly
           reduce such attack surface
        */
        recursion no;
        geoip-directory "/usr/share/GeoIP";

        dnssec-enable yes;
        dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.root.key";

        managed-keys-directory "/var/named/dynamic";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};

logging {
        channel default_log {
                file "/var/named/log/default.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel auth_servers_log {
                file "/var/named/log/auth_servers.log" versions 100 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel dnssec_log {
                file "/var/named/log/dnssec.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel zone_transfers_log {
                file "/var/named/log/zone_transfers.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel ddns_log {
                file "/var/named/log/ddns.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel client_security_log {
                file "/var/named/log/client_security.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
	channel security_file {
                file "/var/named/log/security.log" versions 3 size 30m;
                severity dynamic;
                print-time yes;
        };
        channel rate_limiting_log {
                file "/var/named/log/rate_limiting.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel rpz_log {
                file "/var/named/log/rpz.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
        channel dnstap_log {
                file "/var/named/log/dnstap.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
		};
//
// If you have the category ‘queries’ defined, and you don’t want query logging
// by default, make sure you add option ‘querylog no;’ - then you can toggle
// query logging on (and off again) using command ‘rndc querylog’
//
        channel queries_log {
                file "/var/named/log/queries.log" versions 600 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity info;
        };
//
// This channel is dynamic so that when the debug level is increased using
// rndc while the server is running, extra information will be logged about
// failing queries.  Other debug information for other categories will be
// sent to the channel default_debug (which is also dynamic), but without
// affecting the regular logging.
//
        channel query-errors_log {
                file "/var/named/log/query-errors.log" versions 10 size 1m;
                print-time yes;
                print-category yes;
                print-severity yes;
                severity dynamic;
        };
//
// This is the default syslog channel, defined here for clarity.  You don’t
// have to use it if you prefer to log to your own channels.
// It sends to syslog’s daemon facility, and sends only logged messages
// of priority info and higher.
// (The options to print time, category and severity are non-default.)
//
        channel default_syslog {
                print-time yes;
                print-category yes;
                print-severity yes;
                syslog daemon;
                severity info;
        };
//
// This is the default debug output channel, defined here for clarity.  You
// might want to redefine the output destination if it doesn’t fit with your
// local system administration plans for logging.  It is also a special
// channel that only produces output if the debug level is non-zero.
//
        channel default_debug {
                print-time yes;
                print-category yes;
                print-severity yes;
                file "named.run";
                severity dynamic;
        };
//
// Log routine stuff to syslog and default log:
//
        category default { default_syslog; default_debug; default_log; };
        category config { default_syslog; default_debug; default_log; };
        category dispatch { default_syslog; default_debug; default_log; };
        category network { default_syslog; default_debug; default_log; };
        category general { default_syslog; default_debug; default_log; };
        category security { security_file; };
//
// From BIND 9.12 and newer, you can direct zone load logging to another
// channel with the new zoneload logging category.  If this would be useful
// then firstly, configure the new channel, and then edit the line below
// to direct the category there instead of to syslog and default log:
//
//        category zoneload { default_syslog; default_debug; default_log; };
//
// Log messages relating to what we got back from authoritative servers during
// recursion (if lame-servers and edns-disabled are obscuring other messages
// they can be sent to their own channel or to null).  Sometimes these log
// messages will be useful to research why some domains don’t resolve or
// don’t resolve reliably
//
        category resolver { auth_servers_log; default_debug; };
//        category cname { auth_servers_log; default_debug; };
        category delegation-only { auth_servers_log; default_debug; };
        category lame-servers { auth_servers_log; default_debug; };
        category edns-disabled { auth_servers_log; default_debug; };
//
// Log problems with DNSSEC:
//
//        category dnssec { dnssec_log; default_debug; };
//
// Log together all messages relating to authoritative zone propagation
//
        category notify { zone_transfers_log; default_debug; };
        category xfer-in { zone_transfers_log; default_debug; };
        category xfer-out { zone_transfers_log; default_debug; };
//
// Log together all messages relating to dynamic updates to DNS zone data:
//
        category update{ ddns_log; default_debug; };
        category update-security { ddns_log; default_debug; };
//
// Log together all messages relating to client access and security.
// (There is an additional category ‘unmatched’ that is by default sent to
// null but which can be added here if you want more than the one-line
// summary that is logged for failures to match a view).
//
        category client{ client_security_log; default_debug; };
        category security { client_security_log; default_debug; };
//
// Log together all messages that are likely to be related to rate-limiting.
// This includes RRL (Response Rate Limiting) - usually deployed on authoritative
// servers and fetches-per-server|zone.  Note that it does not include
// logging of changes for clients-per-query (which are logged in category
// resolver).  Also note that there may on occasions be other log messages
// emitted by the database category that don’t relate to rate-limiting
// behaviour by named.
//
        category rate-limit { rate_limiting_log; default_debug; };
//        category spill { rate_limiting_log; default_debug; };
        category database { rate_limiting_log; default_debug; };
//
// Log DNS-RPZ (Response Policy Zone) messages (if you are not using DNS-RPZ
// then you may want to comment out this category and associated channel)
//
        category rpz { rpz_log; default_debug; };
//
// Log messages relating to the "dnstap" DNS traffic capture system  (if you
// are not using dnstap, then you may want to comment out this category and
// associated channel).
//
//        category dnstap { dnstap_log; default_debug; };
//
// If you are running a server (for example one of the Internet root
// nameservers) that is providing RFC 5011 trust anchor updates, then you
// may be interested in logging trust anchor telemetry reports that your
// server receives to analyze anchor propagation rates during a key rollover.
// If this would be useful then firstly, configure the new channel, and then
// un-comment and the line below to direct the category there instead of to
// syslog and default log:
//
//      category trust-anchor-telemetry { default_syslog; default_debug; default_log; };
//
// If you have the category ‘queries’ defined, and you don’t want query logging
// by default, make sure you add option ‘querylog no;’ - then you can toggle
// query logging on (and off again) using command ‘rndc querylog’
//
        category queries { queries_log; };
//
// This logging category will only emit messages at debug levels of 1 or
// higher - it can be useful to troubleshoot problems where queries are
// resulting in a SERVFAIL response.
//
        category query-errors {query-errors_log; };
};
EOF



