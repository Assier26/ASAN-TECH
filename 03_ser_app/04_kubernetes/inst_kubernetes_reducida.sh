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




# --------------    Prueba de Instalación por pasos --------------------------
# 1. Configurar la red
#     Ambos nodos deben tener direcciones IP estáticas
#     Los nodos deben poder comunicarse entre sí 

# 2. habilita el trafico 6443, puedes desactivar el firewall.
#     habilita tráfico en el puerto 6443 para la API de Kubernetes
sudo systemctl stop ufw
sudo systemctl disable ufw

# 3. Instalar containerd en ambos nodos

# 4. Instalar Kubernetes en ambos nodos

# 5. configurar nodo maestro
#       1. Inicializa el clúster en el nodo maestro
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
#   Al finalizar, Kubernetes mostrará un comando para unir los nodos worker al clúster, algo como:
#   Guarda este comando porque lo usaremos en el nodo worker más adelante.
#   kubeadm join 192.168.1.100:6443 --token abcdef.1234567890abcdef \
#     --discovery-token-ca-cert-hash sha256 ....

#       2. Para poder usar kubectl sin sudo, ejecuta:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#       3. Prueba que Kubernetes esté funcionando:
#   Si todo está bien, debería mostrar el nodo maestro 
#   con el estado NotReady (porque aún no configuramos la red de pods).
kubectl get nodes

#       4. Instalar CNI (Red de Kubernetes)
#   Kubernetes necesita un CNI (Container Network Interface) para que los pods puedan comunicarse entre ellos.
#   Vamos a instalar Calico como red de Kubernetes:
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
#   Verifica que los pods de Calico estén corriendo:
#       Ahora el nodo maestro debería cambiar de NotReady a Ready
kubectl get pods -n kube-system

# 6. configurar nodo trabajador
#     Usa el comando que obtuviste en el paso 4 (cambiar IP y hash según el nodo maestro):
sudo kubeadm join 192.168.1.100:6443 --token abcdef.1234567890abcdef \
#     --discovery-token-ca-cert-hash sha256:xxxx
#      Si perdiste el comando, puedes generarlo de nuevo en el nodo maestro con:
kubeadm token create --print-join-command
#       Después de unos minutos, verifica en el nodo maestro si el nodo worker se ha unido:
kubectl get nodes

#  7. Prueba el clúster
kubectl create deployment nginx --image=nginx
kubectl get pods -o wide

# ---------------        Prueba 2        ------------------------
Esta parte esta dedicada a desplegar un deployment en el cluster de kubernetes 
para cada aplicación, después crearemos los servicios para exponer las aplicaciones.
Usaremos volumenes persistentes y para usar dominios utilizaremos Ingress.

1. Crear un Deployment para Nextcloud.
    Nextcloud es un servicio que necesita:
        - Una base de datos (MySQL o PostgreSQL).
        - Un volumen persistente para almacenar archivos.
        - el archivo esta en la misma carpta /04_kubernetes/nextcloud-deployment.yaml
        - Vamos a usar MariaDB como base de datos y un volumen persistente.

2. Crear un Deployment para FacturaScript.
        - el archivo esta en la misma carpta /04_kubernetes/mariadb-Nextclout-deployment.yaml
        - FacturaScript necesita un servidor web con PHP y una base de datos.
        - Vamos a usar Apache con PHP y MariaDB.

3. Usar Persistent Volumes (PV) y Persistent Volume Claims (PVC) para almacenar datos.
        - Crear Persistent Volumes y Persistent Volume Claims
        - Para que los datos no se pierdan al reiniciar los pods.
        - storage.yaml

4. Crear servicios (Service) para exponer las aplicaciones.
    1. Si solo quieres probar en el clúster sin dominio, usa un NodePort.
        - storage.yaml
        Ahora puedes acceder a:
            - Nextcloud: http://<IP_DEL_NODE>:30080
            - FacturaScript: http://<IP_DEL_NODE>:30081

5. Exponer Nextcloud y FacturaScript con Ingress (opcional) si quieres usar dominios.
Si tienes un dominio y quieres usar Ingress, instala Ingress Controller:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
Luego crea el siguiente archivo: ingress.yaml

Para acceder, agrega en /etc/hosts:
<IP_DEL_NODE> nextcloud.local
<IP_DEL_NODE> facturascript.local


Desplegar todo:
kubectl apply -f mariadb-deployment.yaml
kubectl apply -f storage.yaml
kubectl apply -f nextcloud-deployment.yaml
kubectl apply -f facturascript-deployment.yaml
kubectl apply -f services.yaml
kubectl apply -f ingress.yaml




# ---------------        Prueba 3        ------------------------
¿Cómo forzar que los pods se ejecuten en el worker?
Si quieres que los pods de Nextcloud y FacturaScript solo se ejecuten en el worker, sigue estos pasos.

🔹 Paso 1: Identificar el nombre del nodo worker
Ejecuta este comando en el nodo maestro:

kubectl get nodes
🔹 Salida esperada:

NAME        STATUS   ROLES           AGE     VERSION
master      Ready    control-plane   1d      v1.29.0
worker1     Ready    <none>          1d      v1.29.0
El nodo worker se llama worker1 en este caso.

🔹 Paso 2: Modificar los Deployments para usar nodeSelector
Añade lo siguiente en spec.template.spec dentro de cada Deployment para que los pods solo se ejecuten en worker1.


      nodeSelector:
        kubernetes.io/hostname: worker1

Ejemplo modificado para Nextcloud:

yaml
Copiar
Editar
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nextcloud
  template:
    metadata:
      labels:
        app: nextcloud
    spec:
      nodeSelector:
        kubernetes.io/hostname: worker1
      containers:
        - name: nextcloud
          image: nextcloud:latest
          ports:
            - containerPort: 80
          env:
            - name: NEXTCLOUD_ADMIN_USER
              value: "admin"
            - name: NEXTCLOUD_ADMIN_PASSWORD
              value: "adminpassword"

Haz lo mismo en facturascript-deployment.yaml.

🔹 Paso 3: Aplicar los cambios
Después de modificar los archivos, vuelve a aplicarlos con:


kubectl apply -f nextcloud-deployment.yaml
kubectl apply -f facturascript-deployment.yaml

Verifica que los pods estén corriendo en el worker:

kubectl get pods -o wide
🔹 Salida esperada:
sql
Copiar
Editar
NAME                           READY   STATUS    NODE
nextcloud-abcdefg123           1/1     Running   worker1
facturascript-abcdefg456       1/1     Running   worker1

-----------------------------------------------------------------

Si el nodo worker1 se cae, Kubernetes no podrá ejecutar los pods porque están restringidos a ese nodo.
Si quieres permitir que Kubernetes los ejecute en cualquier nodo en caso de emergencia, omite nodeSelector o usa affinity rules.











