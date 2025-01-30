#!/bin/bash

# Este script modifica el archivo de configuración de Netplan en Ubuntu 24

# Crear el contenido del archivo de configuración de Netplan
# Usamos "EOL" para crear un bloque de texto con varias líneas
# Deshabilitar DHCP para la NAT, asegura poder instalar sin bajar la otra interfaz
cat <<EOL > /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false 
      addresses:
        - 10.0.2.15/24
      routes:
        - to: 0.0.0.0/0
          via: 10.0.2.2
      nameservers:
        addresses:
          - 8.8.8.8   
          - 8.8.4.4
    enp0s8:
      dhcp4: false
      addresses:
        - 192.168.1.4/24
      routes:
        - to: 0.0.0.0/0
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8   
          - 8.8.4.4
EOL

# Aplicar la configuración de Netplan
netplan apply

