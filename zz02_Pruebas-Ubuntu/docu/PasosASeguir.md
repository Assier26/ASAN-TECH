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
│   ├── 02-instalar-docker.yml
│   ├── 03-instalar-kubernetes.yml
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
--------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------
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

    - Pulsar "/home/asan/.ssh/id_rsa" cuando pregunta donde guardar las claves
        - Deja en blanco la contraseña

    - verificar que se han creado:
            ls ~/.ssh/

    - Pasar la clave a los hosts.
        ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.12
        ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.13

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
--------------------------------------------------------------------------



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

  sudo kubeadm config images pull --kubernetes-version v1.30.10


sudo ctr -n k8s.io images pull registry.k8s.io/pause:3.9
sudo ctr -n k8s.io images tag registry.k8s.io/pause:3.9 registry.k8s.io/pause:3.8


10. 
TASK [kubernetes-master : Generate the Join Command] ***********************************************************************************************************************************
fatal: [master1]: FAILED! => {"changed": true, "cmd": "kubeadm token create --print-join-command > /tmp/join-command", "delta": "0:01:00.136373", "end": "2025-03-06 11:53:42.633641", "msg": "non-zero return code", "rc": 1, "start": "2025-03-06 11:52:42.497268", "stderr": "failed to create or update bootstrap token with name bootstrap-token-ifxovc: unable to create Secret: Post \"https://10.0.2.15:6443/api/v1/namespaces/kube-system/secrets?timeout=10s\": dial tcp 10.0.2.15:6443: connect: connection refused\nTo see the stack trace of this error execute with --v=5 or higher", "stderr_lines": ["failed to create or update bootstrap token with name bootstrap-token-ifxovc: unable to create Secret: Post \"https://10.0.2.15:6443/api/v1/namespaces/kube-system/secrets?timeout=10s\": dial tcp 10.0.2.15:6443: connect: connection refused", "To see the stack trace of this error execute with --v=5 or higher"], "stdout": "", "stdout_lines": []}




El error que estás viendo indica que el comando kubeadm token create no pudo conectarse al API server de Kubernetes (https://10.0.2.15:6443). Esto sucede porque el API server no está disponible o no está escuchando en esa dirección y puerto.


- name: Store Kubernetes initialization output to file
  copy:
    content: "{{ kubeadm_init_output.stdout }}"
    dest: /tmp/kubeadm_output
  delegate_to: master1

lo he cambiado de "localhost" a "master"


- name: Initialize Kubernetes control plane
  command: kubeadm init --pod-network-cidr=10.244.0.0/16
  args:
    creates: /etc/kubernetes/admin.conf
  become: true
  register: kubeadm_init_output




- name: Initialize Kubernetes control plane
  command: kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.12
  args:
    creates: /etc/kubernetes/admin.conf
  become: true
  register: kubeadm_init_output




TASK [kubernetes-master : Generate the Join Command] ***********************************************************************************************************************************
fatal: [master1]: FAILED! => {"changed": true, "cmd": "kubeadm token create --print-join-command > /tmp/join-command", "delta": "0:01:00.038618", "end": "2025-03-06 12:03:01.500167", "msg": "non-zero return code", "rc": 1, "start": "2025-03-06 12:02:01.461549", "stderr": "failed to create or update bootstrap token with name bootstrap-token-4e2s0q: unable to create Secret: Post \"https://10.0.2.15:6443/api/v1/namespaces/kube-system/secrets?timeout=10s\": dial tcp 10.0.2.15:6443: connect: connection refused\nTo see the stack trace of this error execute with --v=5 or higher", "stderr_lines": ["failed to create or update bootstrap token with name bootstrap-token-4e2s0q: unable to create Secret: Post \"https://10.0.2.15:6443/api/v1/namespaces/kube-system/secrets?timeout=10s\": dial tcp 10.0.2.15:6443: connect: connection refused", "To see the stack trace of this error execute with --v=5 or higher"], "stdout": "", "stdout_lines": []}

PLAY RECAP 



Verificar la configuración del API server

cat /etc/kubernetes/manifests/kube-apiserver.yaml


- --advertise-address=192.168.1.12

sudo systemctl restart kubelet



Verificar el archivo kubeconfig
sudo cat /etc/kubernetes/admin.conf
server: https://192.168.1.12:6443




sudo systemctl status kubelet
sudo cat /etc/containerd/config.toml

sudo kubeadm config images pull --kubernetes-version v1.30.10
sudo ctr -n k8s.io images pull registry.k8s.io/pause:3.9
sudo ctr -n k8s.io images tag registry.k8s.io/pause:3.9 registry.k8s.io/pause:3.8


sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.12




sudo netstat -tuln
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo cat /etc/kubernetes/manifests/kube-scheduler.yaml
sudo cat /etc/kubernetes/manifests/etcd.yaml


sudo cat /etc/netplan/
sudo vim /etc/netplan


sOLUCIONADO

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
  

TASK [kubernetes-master : Wait for API server to be available] *************************************************************************************************************************
FAILED - RETRYING: [master1]: Wait for API server to be available (30 retries left).
FAILED - RETRYING: [master1]: Wait for API server to be available (1 retries left).
fatal: [master1]: FAILED! => {"attempts": 30, "changed": false, "elapsed": 0, "msg": "Status code was -1 and not [200]: Request failed: <urlopen error [Errno 111] Connection refused>", "redirected": false, "status": -1, "url": "https://192.168.1.12:6443/healthz"}
...ignoring

TASK [kubernetes-master : Fail if API server is not available after retries] ***********************************************************************************************************
fatal: [master1]: FAILED! => {"changed": false, "msg": "El API server no está disponible después de 5 minutos. Verifica el estado del clúster."}




sudo systemctl status kubelet
sudo systemctl start kubelet
sudo journalctl -xeu kubelet



sudo systemctl status containerd
sudo systemctl restart containerd


sudo kubeadm config images pull --kubernetes-version v1.30.10




sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml
sudo cat /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo cat /etc/kubernetes/manifests/kube-scheduler.yaml
sudo cat /etc/kubernetes/manifests/etcd.yaml



sudo systemctl status kube-apiserver






