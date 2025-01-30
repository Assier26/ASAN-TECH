#!/bin/bash
#
# Este script tiene la función de instalar el contendor de Nextcloud en Docker
# 
#
# Actualizar los paquetes del sistema
echo "Actualizando los paquetes del sistema..."
sudo apt update -y
sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias necesarias..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Añadir la clave GPG de Docker
echo "Añadiendo la clave GPG de Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Añadir el repositorio de Docker
echo "Añadiendo el repositorio de Docker..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
echo "Instalando Docker..."
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Verificar que Docker esté funcionando
echo "Verificando el estado de Docker..."
sudo systemctl status docker > docker_status.txt
cat docker_status.txt

# Crear directorios para Nextcloud (persistencia)
echo "Creando directorios persistentes para Nextcloud..."
sudo mkdir -p /var/lib/nextcloud/config
sudo mkdir -p /var/lib/nextcloud/data

# Ejecutar el contenedor de Nextcloud con volúmenes persistentes
echo "Ejecutando el contenedor de Nextcloud..."
sudo docker run -d \
  -p 8080:80 \
  -v /var/lib/nextcloud/config:/var/www/html/config \
  -v /var/lib/nextcloud/data:/var/www/html/data \
  --name nextcloud \
  nextcloud

# Confirmar instalación
echo "Nextcloud está corriendo en http://$(hostname -I | awk '{print $1}'):8080"
echo "Accede a esta dirección para completar la instalación."

#Hacer que el inicio del contenedor sea automático
docker update --restart unless-stopped nextcloud