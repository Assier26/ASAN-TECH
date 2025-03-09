-----------------------------------------------------
    --- Pasos a seguir para desplegar el Proyecto de Ansible ASAN-TECH  --
    *** Este proyecto está realizado para que el host master de kubernetes 
    aloje la página web y la base de datos.

-----------------------------------------------------
    --- Estructura del Proyecto ---
-----------------------------------------------------
/proyecto
│
├── ansible/
│   ├── inventory
│   ├── playbook-main.yml          # Playbook principal
│   ├── 01-configuraciones-comunes.yml
│   ├── 02-instalar-kubernetes.yml
│   ├── 04-configurar-master.yml
│   ├── 05-configurar-workers.yml
│   ├── 06-desplegar-aplicacion.yml
│   ├── 07-verificar-cluster.yml
│   ├── roles/
│   │   ├── common/
│   │   ├── docker/
│   │   ├── kubernetes-master/
│   │   ├── kubernetes-worker/
│   │   └── deploy-service/
│
├── kubernetes/
│   ├── web-configmap.yaml
│   ├── mysql-secret.yaml
│   ├── mysql-deployment.yaml
│   ├── mysql-service.yaml
│   ├── web-deployment.yaml
│   └── web-service.yaml
│
├── web/
│   ├── index.html
│   ├── style.css
│   ├── script.js
│   └── backend.php
│
└── database/
    └── init.sql
-----------------------------------------------------
    --- RESUMEN GENERAL ---
    - 1. Preconfiguración: Configura los hosts (usuarios, SSH, swap, etc.).
    - 2. Instalación de Docker: Instala Docker en todos los nodos.
    - 3. Instalación de Kubernetes: Instala Kubernetes en el Master y los Workers.
    - 4. Inicialización del clúster: Inicializa Kubernetes en el Master y une los Workers.
    - 5. Despliegue de servicios: Despliega MySQL y la página web en Kubernetes.
    - 6. Verificación: Verifica que todo esté funcionando correctamente.
-------------------------------------------------------------------------
    --- Despliegue de Servicios ---
Orden de Pasos de ejecución:
    ----------------------
1. Tareas de Configuración Previa. (ÇMás abajo)
    ----------------------
2. Ejecutar el playbook de despliegue desde /mnt/carp_com/ASAN_TECH/..
    chmod +x deploy.sh
    ./deploy.sh
    ----------------------
3. Probar Conexión
ansible all -i ansible/inventory -m ping
    ----------------------
4. Integración con la Página Web
    Una vez que todo esté configurado, puedes usar el playbook playbook-deploy.yml 
    para desplegar servicios desde la página web.

5. Acceder a la página web:
        Usa la IP del nodo de Kubernetes y el puerto 30000 para acceder a la página web.
-------------------------------------------------------------------------
    --- 1. Configuración Previa ---
*** En un paso posterior crearemos el usuario asan, a partir de 
entonces usaremos ese usuario para todo.
    ------------------------------------------------------------------
1. Maquinas virtuales
    - Ansible: 1
    - Master: 1
    - Workers: 2
    - Cliente para control
    ------------------------------------------------------------------
2. Configuración de red Fija
- Interfaz NAT:
    red: 10.0.2.0/24
    ip:  10.0.2.15
    Gw:  10.0.2.2
    DNS: 8.8.8.8
- UbServDesk-Servidor1 -> hostname: ansible
    user: Servidor1
    pass: C@ntrasena
    ip: 192.168.1.11
- UbServ-Servidor2 -> hostname: master1
    user: Servidor2
    pass: C@ntrasena
    ip: 192.168.1.12
- UbServ-Servidor3 -> hostname: worker1
    user: Servidor3
    pass: C@ntrasena
    ip: 192.168.1.13
- UbServ-Servidor4 -> hostname: worker2
    user: Servidor4
    pass: C@ntrasena
    ip: 192.168.1.14
- UbDeskt-Cliente1 ->  hostname: cliente1; para controlar por ssh los servers.
    user: Cliente1
    pass: C@ntrasena
    ip: 192.168.1.21
    ------------------------------------------------------------------
3. Configurar DNS
    -- Configurar hostname en cada nodo.
        sudo hostnamectl set-hostname ansible
        sudo hostnamectl set-hostname master1
        sudo hostnamectl set-hostname worker1
        sudo hostnamectl set-hostname worker2
    -- Configurar /etc/hosts en cada nodo, ejemplo del nodo Ansible.
        192.168.1.11 ansible
        192.168.1.12 master1
        192.168.1.13 worker1
        192.168.1.14 worker2
    ------------------------------------------------------------------
4. Crear usuario "asan" en todos los host con permisos sudo
    sudo adduser asan
    sudo usermod -aG sudo asan
    ----------------------
-- Hacer que el usuario escale privilegios. Ejecutar "visudo" y añadir al final.
    asan    ALL=(ALL)       NOPASSWD: ALL
    ------------------------------------------------------------------
5. *** Lo he metido dentro del playbook de kubernetes.***
    Deshabilitar swap en todos los nodos (Para Kubernetes)
    sudo swapoff -a
    sudo sed -i '/swap/d' /etc/fstab  # Deshabilitar swap permanentemente
    ------------------------------------------------------------------
4. Nodo Ansible
    1. Actualizar librerias y dependencias
        sudo apt update && sudo apt upgrade -y
    --------------------------------
    2. Instalar Ansible
        - sudo apt install -y software-properties-common gnupg2 curl
        - curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        - echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        - sudo apt install ansible
        --------------------------------
    3. Instalar y generar las claves SSH
    - Instalar ssh
        apt install openssh-server -y
    - Generar la clave
    * Hacerlo todo con el usuario asan.
        asan@ansible: sudo ssh-keygen -t rsa -b 4096
    - Pulsar "/home/asan/.ssh/id_rsa" para guardar las claves
    - Deja en blanco la contraseña
    - verificar que se han creado:
            ls ~/.ssh/
    - Pasar la clave a los hosts.
        ssh-copy-id -i ~/.ssh/id_rsa.pub asan@master1
        ssh-copy-id -i ~/.ssh/id_rsa.pub asan@worker1
    - Permisos de los archivos
        sudochmod 700 /home/asan/.ssh
        sudo chmod 600 /home/asan/.ssh/id_rsa
        sudo chmod 644 /home/asan/.ssh/id_rsa.pub
        sudo chmod 644 /home/asan/.ssh/authorized_keys
        sudo chown -R asan:asan /home/asan/.ssh
    - Verificar Conexión y Revisar que se han pasado las claves:
        ssh asan@192.168.1.12
        cat ~/.ssh/authorized_keys
    ----------------------
    - Otra Opción: Ejecutar el script "setup-ssh-keys.sh".
        - chmod +x setup-ssh-keys.sh
        - ./setup-ssh-keys.sh
    --------------------------------
    4. Crear la base de datos y la web con kubernetes
    -- Configmap
        kubectl apply -f kubernetes/web-configmap.yaml
        kubectl get configmap web-files -o yaml

        kubectl apply -f kubernetes/mysql-secret.yaml
        kubectl apply -f kubernetes/mysql-deployment.yaml
        kubectl apply -f kubernetes/mysql-service.yaml
        kubectl apply -f kubernetes/web-deployment.yaml
        kubectl apply -f kubernetes/web-service.yaml
------------------------------------------------------------------------
Fallos
En caso de fallo de ...:
1. "corregido " - En repositorios de kubernetes
        - lista de repositorios
            ls /etc/apt/sources.list.d/
        - eliminarlo
            sudo rm /etc/apt/sources.list.d/kubernetes.list

2. "corregido " - * Los servidores tienen que tener 2 cpu si no no funciona.
3. "corregido " - playbook de kubernetes, añade mal la variable de netorno de 
        - name: Update Kubeadm Environment Variable
        blockinfile:
            path: /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
            block: |
            [Service]
            Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"
            marker: "# {mark} ANSIBLE MANAGED BLOCK"
4. Fallo en 
        - name: Initialize Kubernetes control plane
        command: kubeadm init --pod-network-cidr=10.244.0.0/16
        args:
            creates: /etc/kubernetes/admin.conf
        become: true
        register: kubeadm_init_output
5. Fallo en el worker con container.io.
6. Fallo al conectar al cluster de kubernetes

        - He creado claves ssh en worker y master y se las he pasado al contrario
        - Verificar la Resolución DNS
        - Verificar la Conexión SSH Manualmente
7. Error con comando join
    TASK [kubernetes-worker : Read Join Command from Master] 
    fatal: [worker1 -> master1]: FAILED! => {"changed": false, "msg": "file not found: /tmp/join-command"}

    El error indica que el archivo /tmp/join-command no se encuentra en master1. Esto sucede porque el playbook de master1 no ha generado correctamente el archivo join-command antes de que el playbook de worker1 intente leerlo

    Verifica que el archivo /tmp/join-command existe en master1:
    ssh asan@master1 "ls -l /tmp/join-command"

    Si el archivo no existe, ejecuta manualmente el comando para generarlo
    ssh asan@master1 "kubeadm token create --print-join-command > /tmp/join-command"

    Verifica que el archivo /tmp/join-command tenga permisos de lectura para el usuario asan
    ssh asan@master1 "chmod 644 /tmp/join-command"


8. Corregido -> No actualiza master1 ni descarga paquetes
    - Problema, mala configuracion en el archivo netplan.
--------------
network:
    ethernets:
        enp0s3:
            addresses:
            - 10.0.2.15/24
            nameservers:
                addresses:
                - 8.8.8.8
                search: 
                - 8.8.8.8
            routes:
            -   to: default
                via: 10.0.2.2
        enp0s8:
            addresses:
            - 192.168.1.13/24
            nameservers:
                addresses:
                - 8.8.8.8
                search: 
                - 8.8.8.8
    version: 2
-------------------
    - sudo cat /etc/netplan/50-cloud-init.yaml
    - sudo netplan try
    - sudo netplan apply
    - sudo apt update
9. Corregido.
- name: Initialize Kubernetes control plane
  command: kubeadm init --pod-network-cidr=10.244.0.0/16
  args:
    creates: /etc/kubernetes/admin.conf
  become: true
  register: kubeadm_init_output
En el master:
    - sudo kubeadm config images pull --kubernetes-version v1.30.10
    - sudo ctr -n k8s.io images pull registry.k8s.io/pause:3.9
    - sudo ctr -n k8s.io images tag registry.k8s.io/pause:3.9 registry.k8s.io/pause:3.8
10. Conexión a la API
La API no se despliega correctamente, los puertos que usa no se despliegan aunque estén habilitados en el firewall.

Estrácto de código-> 

- name: Wait for API server to be available
  uri:
    url: https://192.168.1.12:6443/healthz
    validate_certs: no
    status_code: 200
  register: api_server_status
  until: api_server_status.status == 200
  retries: 5
  delay: 10
  ignore_errors: yes
  
Error que da al ejecutar el script, al llegar a kubernetes-master/task/main.yml -> 

TASK [kubernetes-master : Wait for API server to be available] *******************************
FAILED - RETRYING: [master1]: Wait for API server to be available (1 retries left).
fatal: [master1]: FAILED! => {"attempts": 30, "changed": false, "elapsed": 0, "msg": "Status code was -1 and not [200]: Request failed: <urlopen error [Errno 111] Connection refused>", "redirected": false, "status": -1, "url": "https://192.168.1.12:6443/healthz"}
...ignoring

TASK [kubernetes-master : Fail if API server is not available after retries] **********************



PRUEBAS PARA CORREGIR EL ERROR:

1. Voy a reducir el archivo de ejecución del master a lo básico y así
probar si alguno de los errores anteriores que ya hemos corregido
nos está creando el error, o quizás alguan directiva que hemos metido
que en realidad no funcione o funcione mal.
Así seccionamos el problema poco a poco.








--------    Pasos de Verificación   --------------------
- Verificar Kubelet
sudo systemctl status kubelet
sudo systemctl restart kubelet
sudo journalctl -xeu kubelet

- Verificar containerd
sudo cat /etc/containerd/config.toml
sudo systemctl status containerd
sudo systemctl restart containerd

- Verificar el archivo kubeconfig
sudo cat /etc/kubernetes/admin.confsudo kubeadm config images pull --kubernetes-version v1.30.10

sudo ctr -n k8s.io images pull registry.k8s.io/pause:3.9
sudo ctr -n k8s.io images tag registry.k8s.io/pause:3.9 registry.k8s.io/pause:3.8

- Verificar API-Server -> server: https://192.168.1.12:6443

sudo systemctl status kube-apiserver
sudo netstat -tuln

sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo cat /etc/kubernetes/manifests/kube-scheduler.yaml
sudo cat /etc/kubernetes/manifests/etcd.yaml

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.12
sudo systemctl status kubelet

- Verificación Incicial.
    - ls /etc/apt/sources.list.d/
    - sudo cat /etc/netplan/50-cloud-init.yaml
    - sudo netplan try
    - sudo netplan apply
    - sudo apt update && sudo apt upgrade -y
    - sudo cat /etc/hosts
    sudo adduser asan
    sudo usermod -aG sudo asan
    ----------------------
-- Hacer que el usuario escale privilegios. Ejecutar "visudo" y añadir al final.
    asan    ALL=(ALL)       NOPASSWD: ALL





Paso 1 . Instalar dependencias de Kubernetes
sudo apt install -y curl apt-transport-https ca-certificates software-properties-common python3 gnupg2 net-tools


sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common


curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get install -y kubectl kubelet kubeadm

sudo swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab
free -h



echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt-get update
sudo apt-get install -y containerd
ls -l /var/run/containerd/containerd.sock

sudo containerd config default > /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri"]

sudo systemctl restart containerd


cd /mnt/carp_com/ASAN-TECH/zz02_Pruebas-Ubuntu/
./deploy.sh 

# Antes de iniciar
# 1. dependencias
# 2. Memoria Swap
# 3. firewall
# 4. reglas forwarod
# 5. paquetes
    # 1. kubernetes
    # 2. containerd
        # 1. configuración
        # 2. plugin CRI
        # 3. reiniciar
# 7. Iniciar el cluster
# 8. configurar kubectl para el usuario actual
# 9. desplegar plugin de red.
# 10. Ingress Controller para exponer los servicios.

---
- name: Configurar Ingress Controller y unir worker al clúster
  hosts: all
  become: yes
  tasks:
    # 1. Instalar Helm (si no está instalado)
    - name: Instalar Helm
      apt:
        name: helm
        state: present
        update_cache: yes

    # 2. Agregar el repositorio de NGINX Ingress
    - name: Agregar repositorio de NGINX Ingress
      command: helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
      args:
        creates: /root/.config/helm/repositories.yaml  # Evita agregar el repositorio si ya existe

    - name: Actualizar repositorios de Helm
      command: helm repo update

    # 3. Instalar NGINX Ingress Controller
    - name: Instalar NGINX Ingress Controller
      command: |
        helm install ingress-nginx ingress-nginx/ingress-nginx \
          --namespace ingress-nginx \
          --create-namespace
      args:
        creates: /etc/kubernetes/manifests/ingress-nginx-controller.yaml  # Evita reinstalar si ya existe

    # 4. Verificar que el Ingress Controller esté en ejecución
    - name: Verificar estado del Ingress Controller
      command: kubectl get pods -n ingress-nginx
      register: ingress_status
      failed_when: "'Running' not in ingress_status.stdout"

    # 5. Unir un worker al clúster (solo en el nodo maestro)
    - name: Obtener el comando de unión del worker
      command: kubeadm token create --print-join-command
      register: join_command
      when: inventory_hostname == "master1"  # Cambia "master1" por el nombre de tu nodo maestro

    - name: Mostrar el comando de unión
      debug:
        msg: "Comando para unir el worker: {{ join_command.stdout }}"
      when: inventory_hostname == "master1"

    # 6. Ejecutar el comando de unión en los workers
    - name: Unir worker al clúster
      command: "{{ join_command.stdout }}"
      when: inventory_hostname != "master1"  # Ejecuta esto solo en los workers

    # 7. Verificar que el worker esté unido al clúster
    - name: Verificar nodos del clúster
      command: kubectl get nodes
      register: nodes_status
      failed_when: "'Ready' not in nodes_status.stdout"

    - name: Mostrar estado de los nodos
      debug:
        msg: "Estado de los nodos: {{ nodes_status.stdout }}"


