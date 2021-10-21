#!/usr/bin/env bash

set -x

######################----CREATE-SWAPFILE----################################

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

######################-----------END----------################################

######################---INSTALL-AWS-HELPER---################################

/usr/bin/apt update
/usr/bin/apt install amazon-ecr-credential-helper -y
mkdir -p ~/.docker
cat <<EOF >| ~/.docker/config.json
{
    "credsStore": "ecr-login",
    "373633196736.dkr.ecr.eu-west-2.amazonaws.com": "ecr-login"
}
EOF

######################-----------END----------################################

######################-----INSTALL-DOCKER-----################################

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
adduser ubuntu docker

######################-----------END----------################################

######################-INSTALL-DOCKER-COMPOSE-################################

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

######################-----------END----------################################

######################-------INSTALL-GIT-------###############################

/usr/bin/apt install git net-tools -y 

######################-----------END----------################################

######################-----Get-Public_IP------################################

PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

######################-----------END----------################################

######################--Get-Public_IP_MASTER--#################################

PUBLIC_IP_MASTER=${MASTER_IP}

######################-----------END----------################################

######################---Get-MYSQL_PASSWORD---################################

MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD}

######################-----------END----------################################

######################--Get-OPENVPN_PASSWORD--################################

OPENVPN_ADMIN_PASSWORD=${OPENVPN_PASSWORD}

######################-----------END----------################################

######################---RUN-DOCKER-COMPOSE---################################

git clone https://github.com/redheaven/ovpn-gui-var.git

# Master
if [ $${PUBLIC_IP_MASTER} == NULL ];
then
    MYSQL_ROOT_PASSWORD=$${MYSQL_ROOT_PASSWORD} OPENVPN_ADMIN_PASSWORD=$${OPENVPN_ADMIN_PASSWORD} HOST_ADDR=$${PUBLIC_IP} OPENVPN_SERVER_ADDR=$${PUBLIC_IP} docker-compose -f /ovpn-gui-var/docker-compose.yml up -d
else
# Slave
    MYSQL_ROOT_PASSWORD=$${MYSQL_ROOT_PASSWORD} OPENVPN_ADMIN_PASSWORD=$${OPENVPN_ADMIN_PASSWORD} HOST_ADDR=$${PUBLIC_IP_MASTER} OPENVPN_SERVER_ADDR=$${PUBLIC_IP}  docker-compose -f /ovpn-gui-var/docker-compose.yml up -d openvpn webadmin googleauth 
fi

######################-----------END----------################################