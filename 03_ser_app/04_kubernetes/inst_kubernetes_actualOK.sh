#!/bin/bash
#
# Este script tiene el objetivo de seguir paso a paso la instalación
# y configuración de Kubernetes.
#
# ---   1. Actualizar el sistema
sudo apt update -y && sudo apt upgrade -y
# 
# ---   2. Instalar dependencias necesarias
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
# 
# ---   3. Instalar Kubernetes
# Añadir la clave GPG de Kubernetes
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # Permitimos a la API leer sin privilegios
# 
# Esto sobrescribe cualquier configuración existente en /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # Esto ayuda a encontrar los comandos de instalación de Kubernetes
# 
# Instalar Kubernetes
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
sudo swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab
free -h
# 
# ---   5. Activamos las funciones del kernerl
sudo modprobe overlay
sudo modprobe br_netfilter
# 
# ---   Añadir configuraciones de red   ---
#   Este bloque crea (o sobrescribe) el archivo /etc/sysctl.d/k8s.conf 
#   con las siguientes configuraciones:
#   1. net.bridge.bridge-nf-call-iptables = 1
#       Permite que iptables procese el tráfico de paquetes en redes puenteadas.
#       Necesario para que los pods en Kubernetes puedan comunicarse correctamente.
#   2. net.ipv4.ip_forward = 1
#       Habilita el reenvío de paquetes en IPv4.
#       Sin esto, los nodos no pueden enrutar tráfico entre contenedores y redes externas.
#   3. net.bridge.bridge-nf-call-ip6tables = 1
#       Permite a ip6tables procesar tráfico de IPv6 en redes puenteadas (si se usa IPv6 en el clúster).
#       No es necesario si no se usa IPv6.
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# 
#  ---- o ----
# cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
# overlay
# br_netfilter
# EOF
#  ---- o ----
# cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
# net.bridge.bridge-nf-call-iptables = 1
# net.ipv4.ip_forward = 1
# net.bridge.bridge-nf-call-arptables = 1
# EOF
# --------
# Aplicar los cambios inmediatamente
    # Esto carga todas las configuraciones de /etc/sysctl.d/.
sudo sysctl --system
# 
# Configurar la carga de los modulos de manera persistente
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
# 
#  ---- o ----
# cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
# overlay
# br_netfilter
# EOF
# --------
# 
# ---   6. Instalar contairnerd io ---
# Añadimos el repositorio de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo add-apt-repository "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Clave GPG de Docker
- name: Descargar Clave GPG de Docker
  shell: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
  become: true

# Repositorio de Docker
- name: Añadir Repositorio de Docker
  apt_repository:
    repo: "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    state: present

# Actualizar los Repositorios
- name: Actualizar los Repositorios
  apt:
    update_cache: yes
    cache_valid_time: 3600




# Actualizamos e instalamos containerd.io
sudo apt update
sudo apt install -y containerd.io
# 
# Configure containerd and start service
sudo mkdir -p /etc/containerd
sudo containerd config default|sudo tee /etc/containerd/config.toml
# 
# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status  containerd
# 
# 
# 
# ----------------------------------------------------------------------------
# --- Hasta aqui se instala tanto en el nodo master como en el nodo worker ---
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
#                           ---  NODO MASTER  ---
# 5. Descargar imagenes de kubernetes
sudo kubeadm config images pull



# -- ------------------   Hasta aqui funciona del tirón     ------------------




# 
# comprobar los puertos para la comunicación interna de kubernetes
nc 127.0.0.1 6443 -v
# -- ----------------------------------------------------------------------------
echo "🎉 Instalación completa. Docker y Kubernetes están listos para usarse."
# -- ----------------------------------------------------------------------------