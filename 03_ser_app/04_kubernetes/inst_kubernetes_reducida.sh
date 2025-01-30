#!/bin/bash
#
# Este script tiene la función de instalar Docker en la máquina
# 
#
# 1. Actualizar paquetes
sudo apt update -y && sudo apt -y full-upgrade
# 2. Instalación de Kubernetes
sudo apt install -y kubelet kubeadm kubectl 
sudo apt-mark hold kubelet kubeadm kubectl
sudo  kubectl  version --client && sudo  kubeadm version

# 3. Bloquear la memoria swap para evitar problemas con Kubernetes
# Comentar la linea de swap en el archivo /etc/fstab
vim /etc/fstab
sudo swapoff -a
sudo mount -a
free -h

# Activamos las funciones del kernerl
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter
# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# Reload sysctl
sudo sysctl --system
# Configure persistent loading of modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF


# 4. Instalar contairnerd io
# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start service
sudo mkdir -p /etc/containerd
sudo containerd config default|sudo tee /etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status  containerd

# 5. Descargar imagenes de kubernetes
sudo kubeadm config images pull

# edite archivo /etc/hosts
#127.0.0.1 localhost 
#IP_OF_THE_MACHINE k8scp

# 6. Inicializar el cluster
sudo kubeadm init --pod-network-cidr=172.24.0.0/16 --cri-socket=unix:///run/containerd/containerd.sock --upload-certs --control-plane-endpoint=k8scp

# HAver un copa del archivo de seguridad, evitar root
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#Exportar variable de entorno
export KUBECONFIG=$HOME/.kube/config

# Comprobar que el cluster está funcionando
kubectl cluster-info


# 7. Instalar un plugin de red
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml



# Instalar el operador
kubectl create -f tigera-operator.yaml

# Tendríamos el archivo custom-resources.yaml, el cual habría que modificar 
# con el rango de red definido en el kubeadm initcomando. 
# En el caso de esta guía es 172.24.0.0. 
# Podemos hacerlo con el siguiente comando:

sed -ie 's/192.168.0.0/172.24.0.0/g' custom-resources.yaml

# Cargamos el archivo que hemos modificado:
kubectl create -f custom-resources.yaml

# esperamos a que estén ready los pods
kubectl get pods --all-namespaces -w

# Lo ideal es que el maestro no ejecute pods,
# más alla de los propios del sistema.
# si queremos desactivarlo para pruebas
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# Confirmamaos el funcionamiento del nodo
kubectl get nodes -o wide


# 8- Agregar workers al clúster
# Los datos que necesitas:
#   - Host y puerto del plano de control, en este caso: k8scp:6443
#   - Token, ejecuta este comando en el servidor maestro:
kubeadm token create

# Token de descubrimiento ca, ejecute este comando en el servidor maestro nuevamente:
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

# Ahora, en el nodo trabajador, ejecuta el siguiente comando:
kubeadm join \
<control-plane-host>:<control-plane-port> \
--token <token> \
--discovery-token-ca-cert-hash sha256:<hash>
# Si quieres ver los tokens activos:
kubeadm token list

# 
















