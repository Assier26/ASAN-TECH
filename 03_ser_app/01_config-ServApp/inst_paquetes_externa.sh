#!/bin/bash

set -e  # Detener el script si hay errores

echo "🚀 Iniciando instalación de Docker y Kubernetes en Ubuntu Server 24.04"

# Actualizar paquetes del sistema
echo "🔄 Actualizando paquetes..."
sudo apt update && sudo apt upgrade -y

# Instalar paquetes requeridos
echo "📦 Instalando paquetes necesarios..."
sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

# Instalar Docker
echo "🐳 Instalando Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilitar y verificar Docker
sudo systemctl enable docker
sudo systemctl start docker
echo "✅ Docker instalado: $(docker --version)"

# Configurar containerd para Kubernetes
echo "⚙️ Configurando containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Agregar repositorio de Kubernetes
echo "🔗 Agregando repositorio de Kubernetes..."
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-apt-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Instalar Kubernetes (kubelet, kubeadm, kubectl)
echo "☸️ Instalando Kubernetes..."
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo "✅ Kubernetes instalado"

# Configurar sysctl para Kubernetes
echo "⚙️ Configurando parámetros del kernel..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
EOF

sudo sysctl --system

# Deshabilitar swap (requerido por Kubernetes)
echo "🛑 Deshabilitando swap..."
sudo swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab

echo "🎉 Instalación completa. Docker y Kubernetes están listos para usarse."
