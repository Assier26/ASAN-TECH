#!/bin/bash
#
# Este script tiene la función de instalar kubernetes en la máquina
# 
#
# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias necesarias..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Añadir la clave GPG de Kubernetes
echo "Añadiendo la clave GPG de Kubernetes..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Añadir el repositorio de Kubernetes
echo "Añadiendo el repositorio de Kubernetes..."
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Instalar 
echo "Instalando Kubernetes..."
sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl

# Mantener la versión actual y hacer que Kubernetes no se actualice automaticamente
sudo apt-mark hold kubelet kubeadm kubectl

# Verificar que Kubernetes esté instalado
echo "Verificando la instalación de ..."
sudo  kubectl version --client || { echo "Error: Kubernetes no se instaló correctamente"; exit 1; }
sudo  kubeadm version || { echo "Error: Kubernetes no se instaló correctamente"; exit 1; }
