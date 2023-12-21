# EricServices-DNS-Server
Installation Script to Install:  
**BIND** - Authoritative DNS Server  
**MaxMind GeoIP** Database  

# Features  
BIND DNS Server  
Detailed Logging for Monitoring  
GeoIP Aware DNS Responses  

# Dependencies  
Rocky Linux, Redhat, Fedora, or CentOS  
Configure Domain registrar to point to DNS Server  

# Installation  
## Live (Read the Code first!)  
    bash <(curl -s https://raw.githubusercontent.com/EricServices-Repo/DNS/main/install.sh)  
    
## Manual:  
    cd /opt  
    wget https://raw.githubusercontent.com/EricServices-Repo/DNS/main/install.sh  
    chmod +x install.sh  
    ./install.sh  

# Variables  
DOMAIN - Authoritative DNS Domain  
GEOIPACCT - MaxMind Account  
GEOIPKEY - MaxMind API Key  

# Post Installation  
# Access  
# Customization  
# Support    
[Discord](https://discord.gg/8nKBgURRbW)  
