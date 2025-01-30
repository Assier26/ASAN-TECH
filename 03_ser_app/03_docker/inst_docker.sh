#!/bin/bash
#
# Este script tiene la función de instalar Docker en la máquina
# 
#
# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias necesarias..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
echo "Dependencias... instaladas"

# Añadir la clave GPG de Docker
echo "Añadiendo la clave GPG de Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Añadir el repositorio de Docker
echo "Añadiendo el repositorio de Docker..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
echo "Instalando Docker..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verificar que Docker esté instalado
echo "Verificando la instalación de Docker..."
sudo docker --version || { echo "Error: Docker no se instaló correctamente"; exit 1; }

# Habilitar y arrancar el servicio de Docker
sudo systemctl enable docker
sudo systemctl start docker
echo "Docker habilitado e iniciado..."