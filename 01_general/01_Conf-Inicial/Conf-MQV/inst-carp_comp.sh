#Actualizar 
apt update && apt upgrade -y

# --	Instalación Vbox	--
#Instalar dependencias Vbox
apt install build-essential dkms linux-headers-$(uname -r)
#Insertamos el cd en la maquina virtual de GuestAdditions
# Montamos el cd en /mnt
mount /dev/cdrom /mnt
# Ejecutamos el programa
/mnt/VBoxLinuxAdditions.run

# --	Carpeta Compartida (carp_comp)	--
# Crear el directorio compartido
mkdir /mnt/carp_com
# Crear el montaje persistente en /etc/fstab.
# usamos  ">" para sobreescribir, y ">>" para añadir al final
cp /etc/fstab /etc/fstab.bak
echo "carp_com /mnt/carp_com vboxsf defaults 0 0" >> /etc/fstab

# --	Reiniciamos	--
reboot
