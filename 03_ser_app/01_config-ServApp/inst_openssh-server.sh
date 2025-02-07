#!/bin/bash
#
# Instalación de SSH
#   El demonio se llama "ssh": systemctl status ssh.
# 
apt update && apt upgrade -y
# Instalamos Open ssh
apt install -y openssh-server
# Configuramso el firewall para ssh
ufw allow ssh
ufw enable