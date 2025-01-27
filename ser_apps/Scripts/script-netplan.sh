echo "network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.10.4/24
      gateway4: 192.168.10.1  # Ajusta la puerta de enlace si es necesario
      nameservers:
        addresses:
          - 8.8.8.8    # Servidor DNS (puedes cambiarlo por otro)
          - 8.8.4.4" > /etc/netplan/00-installer-config.yaml
netplan try
netplan apply
