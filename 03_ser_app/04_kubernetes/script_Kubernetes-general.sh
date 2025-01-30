#!/bin/bash
#
# Este script tiene el objetivo de lanzarse y configurar 
#  e instalar automáticamente Kubernetes.
#
echo "[INFO] Empieza la instalación y configuración de Kubernetes, por favor mantente a la espera ..."

# 
# ---   1. Actualizar el sistema
echo "[INFO] Actualizando el sistema..."

sudo apt update -y && sudo apt upgrade -y
# 
# ---   2. Instalar dependencias necesarias
echo "[INFO] Instalando dependencias necesarias..."

sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
# 
# ---   3. Instalar Kubernetes
echo "[INFO] Instalando Kubernetes..."

# Añadir la clave GPG de Kubernetes
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # Permitimos a la API leer sin privilegios
# 
# Esto sobrescribe cualquier configuración existente en /etc/apt/sources.list.d/kubernetes.list
echo "[INFO] Configurando el repositorio de Kubernetes..."

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # Esto ayuda a encontrar los comandos de instalación de Kubernetes
# 
# Instalar Kubernetes
echo "[INFO] Instalando paquetes de Kubernetes..."

sudo apt-get update
sudo apt-get install -y kubectl kubelet kubeadm
# Mantener la versión actual y hacer que Kubernetes no se actualice automaticamente
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
# 
# Verificar que Kubernetes esté instalado
echo "Verificando la instalación de ..."

sudo  kubectl version --client 
sudo  kubeadm version
# 
# -- ------------------   Hasta aqui funciona del tirón     ------------------  
# ---   4. Deshabilitar swap (requerido por Kubernetes)
echo "[INFO] Deshabilitando swap..."

sudo swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab
free -h
# 
# ---   5. Activamos las funciones del kernel
echo "[INFO] Activando funciones del kernel..."

sudo modprobe overlay
sudo modprobe br_netfilter
# 
# ---   Añadir configuraciones de red   ---
echo "[INFO] Configurando parámetros del sistema de red para Kubernetes..."

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# Aplicar los cambios inmediatamente
echo "[INFO] Aplicando configuraciones del sistema..."

sudo sysctl --system
# 
# Configurar la carga de los modulos de manera persistente
echo "[INFO] Configurando carga de módulos de manera persistente..."

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
# 
# ---   6. Instalar contairnerd io ---
echo "[INFO] Instalando containerd.io..."

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Actualizamos e instalamos containerd.io
sudo apt update
sudo apt install -y containerd.io
# 
# Configure containerd and start service
echo "[INFO] Configurando containerd..."

sudo mkdir -p /etc/containerd
sudo containerd config default|sudo tee /etc/containerd/config.toml
# 
# restart containerd
echo "[INFO] Reiniciando y habilitando el servicio containerd..."

sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status  containerd
# 