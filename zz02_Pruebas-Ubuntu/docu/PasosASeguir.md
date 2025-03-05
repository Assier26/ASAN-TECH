-----------------------------------------------------
    --- Pasos a seguir para desplegar el Proyecto de Ansible ASAN-TECH  --
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
1. Tareas de preconfiguración.
    ----------------------
2. Ejecutar el playbook de despliqgue
    chmod +x deploy.sh
    ./deploy.sh
    ----------------------
3. Probar Conexión
ansible all -i ansible/inventory -m ping
    ----------------------
4. Integración con la Página Web
    Una vez que todo esté configurado, puedes usar el playbook playbook-deploy.yml 
    para desplegar servicios desde la página web.
----------------------------------------------------------------------------------------------
    --- 1. Configuración Previa ---
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
- UbServDesk-Servidor1 -> Ansible
    user: Servidor1
    pass: C@ntrasena
    ip: 192.168.1.11
- UbServ-Servidor2 -> Master
    user: Servidor2
    pass: C@ntrasena
    ip: 192.168.1.12
- UbServ-Servidor3 -> Worker1
    user: Servidor3
    pass: C@ntrasena
    ip: 192.168.1.13
- UbServ-Servidor4 -> Worker2
    user: Servidor4
    pass: C@ntrasena
    ip: 192.168.1.14
- UbDeskt-Cliente1 -> Cliente para controlar por ssh los servers.
    user: Cliente1
    pass: C@ntrasena
    ip: 192.168.1.21
    ------------------------------------------------------------------
3. Configurar DNS
    -- Configurar hostname en cada nodo.
        sudo hostnamectl set-hostname ansible
        sudo hostnamectl set-hostname master
        sudo hostnamectl set-hostname worker1
        sudo hostnamectl set-hostname worker2
    -- Configurar /etc/hosts en cada nodo, ejemplo del nodo Ansible.
        192.168.1.11 ansible
        192.168.1.12 master
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
5. Deshabilitar swap en todos los nodos (Para Kubernetes)
    sudo swapoff -a
    sudo sed -i '/swap/d' /etc/fstab  # Deshabilitar swap permanentemente
    ------------------------------------------------------------------
4. Nodo Ansible
    1. Actualizar librerias y dependencias
        sudo apt update && sudo apt upgrade -y
    --------------------------------
    2. Instalar Ansible
        sudo apt install -y software-properties-common gnupg2 curl
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        
        sudo apt install terraform
        sudo apt install ansible
    --------------------------------
    3. Instalar y generar las claves SSH
    - Instalar ssh
        apt install openssh-server -y
    - Generar la clave
        ssh-keygen -t rsa -b 4096
        - Pulsar enter cuando pregunta donde guardar las claves
        - Deja en blanco la contraseña
    - verificar que se han creado:
            ls ~/.ssh/
    - Pasar la clave a los hosts.
        ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.12
        ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.13
    - Revisar que se han pasado las claves:
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