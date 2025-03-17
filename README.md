## ASAN-TECH
 Repositorio creado para el desarrollo y la implementación del TFG de Grado Superior de Administración de Sistemas en Red.
 Tutulo:       ASAN-TECH 
 Autores:      Asier García y Andrés Sierra
 
## CONCEPTO GENERALES DEL PROYECTO
La idea de proyecto es crear una estructura automatizada que levanta automáticamente los servicios necesarios a través 
de tecnologías como Ansible y Kubernetes.


## Diagrama de Red 
![diagrama de red](https://github.com/Assier26/ASAN-TECH/blob/main/01_general/Topologia/topologia_packet_tracer.jpeg?raw=true)


## TECNOLOGÍAS
1. WEB: html5, css, php, sql / apache2, nginx / phpMyAdmin
2. APP: docker, kubernetes, terraform, ansible
3. Sistemas: Linux Server 24 / pfsense
4. Protocolos utilizados:  https, ssh, ftp,
5. Otros: python.
6. Software a implementar: Nextcloud, FacturaScript, Wordpress, 

## TAREAS GENERALES













-----------------------------------------------------
    --- Pasos a seguir para desplegar el Proyecto de Ansible ASAN-TECH  --
    *** Este proyecto está realizado para que el host master de kubernetes 
    aloje la página web y la base de datos.

-----------------------------------------------------
    --- Estructura del Proyecto ---
-----------------------------------------------------
/proyecto
│
├── deploy.sh
├── deploy-ansible.sh
├── deploy-remoto.sh
├── ansible/
│   ├── inventory
│   ├── playbook-main.yml          # Playbook principal
│   ├── 01-configuraciones-comunes.yml
│   ├── 02-instalar-kubernetes.yml
│   ├── 04-configurar-master.yml
│   ├── 05-configurar-workers.yml
│   ├── 06-desplegar-web.yml
│   ├── 07-desplegar-servicios.yml
│   ├── 08-verificar-cluster.yml
│   └── roles/
│       ├── common/
│       └── deploy-service/
│       ├── kubernetes/
│       ├── kubernetes-master/
│       └── kubernetes-worker/
├── web/
│   ├── index.html
│   ├── style.css
│   ├── script.js
│   └── backend.php
│
└── database/
|    └── init.sql
├── servicios/
│   ├── Nextcloud
│   ├── FacturaScript
│   ├── OnlyOffice
│   └── Roundcube
-----------------------------------------------------
    --- RESUMEN GENERAL ---
    - 1. Preconfiguración: Configura los hosts (usuarios, SSH, swap, etc.).
    - 3. Instalación de Kubernetes: Instala Kubernetes en el Master y los Workers.
    - 4. Inicialización del clúster: Inicializa Kubernetes en el Master y une los Workers.
    - 5. Despliegue de servicios: Despliega MySQL y la página web en Kubernetes.
    - 6. Verificación: Verifica que todo esté funcionando correctamente.
-------------------------------------------------------------------------

    --- Despliegue del Proyecto ---

    ----------------------
1. Tareas de Configuración Previa. (Más abajo)
    ----------------------
2. Ejecutar el playbook de despliegue desde /mnt/carp_com/ASAN_TECH/zz_Pruebas-Ubuntu
    1. Ejecutar el deploy-remoto en cada equipo remoto que vayamos a gestionar con ansible.
        * Tendremos que cambiar la ip y el hostname dependiendo el equipo.
        chmod +x deploy-remoto.sh
        ./deploy-remoto.sh
    2. Ejecutar el deploy-ansible.
        chmod +x deploy-ansible.sh
        ./deploy-ansible.sh
    3. Ejecutar deploy.sh para generar todo el proyecto con ansible.
        chmod +x deploy.sh
        ./deploy.sh
    ----------------------
3. Una vez desplegado se debería ver la Página Web y los Servicios que se pueden desplegar.
    ----------------------
4. Integración con la Página Web
    Una vez que todo esté configurado, puedes usar los playbooks de /despliegue-dinamico-servicios 
    para desplegar servicios desde la página web.

-------------------------------------------------------------------------
    --- 1. Configuración Previa ---
*** Se han creado scripts para la configuración previa de los hosts remotos y de ansible,
a continuación se detallan los pasos a seguir en caso de duda.

*** En un paso posterior crearemos el usuario asan, a partir de 
entonces usaremos ese usuario para todo.
    ------------------------------------------------------------------
1. Maquinas virtuales
    - Ansible: 1
    - Master: 1
    - Workers: 1/2
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
5.  Nodo Ansible
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
# Fases del master-kubernetes.
cd /mnt/carp_com/ASAN-TECH/zz02_Pruebas-Ubuntu/
./deploy.sh 
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
----------- Flujo General de la aplicación  ----------
1. Usuario contrata un servicio:
    - El usuario accede a la aplicación web (Asan-tech)
    - En la web, elige un servicio (por ejemplo, Nextcloud o FacturaScript) y hace clic en "Contratar".
2. La aplicación web procesa la solicitud:
    - El backend de la aplicación web (PHP) recibe la elección del usuario.
    - El backend ejecuta un playbook de Ansible para desplegar el servicio en Kubernetes.
3. Ansible despliega el servicio:
    - Ansible usa las variables dinámicas para desplegar el servicio elegido.
    - El servicio se expone a través de un nuevo Ingress (por ejemplo, nextcloud.asan-tech.com o facturascript.asan-tech.com).
4. Usuario accede al servicio:
    - Una vez desplegado, el usuario puede acceder al servicio a través del dominio correspondiente.
----------- Integración Completa  ----------
1. El usuario accede a asan-tech.com:
 - El Ingress redirige el tráfico a la aplicación web.
2. El usuario contrata un servicio:
 - El formulario envía la solicitud a contratar.php.
3. El backend ejecuta Ansible:
 - contratar.php ejecuta el playbook de Ansible para desplegar el servicio.
4. El servicio se despliega:
 - Ansible crea el despliegue, servicio e Ingress para el servicio contratado.
5. El usuario accede al servicio:
- El servicio está disponible en nextcloud.asan-tech.com o facturascript.asan-tech.com.
-------------------------------------------------------
# Comandos útiles de kubernetes
# Ver los pods de todos los namespace
kubectl get pods --all-namespaces
--------------------------
# Ver los pods de ingresss
kubectl get pods -n ingress-nginx
--------------------------
# Ver la información del pod.
kubectl get svc
kubectl get svc -n ingress-nginx
--------------------------
# PAra ver el log de un pod 
kubectl logs -n ingress-nginx ingress-nginx-controller-
--------------------------
# Obtener la ip de los nodos
kubectl get nodes -o wide
---------------------------
# Ver puertos expuestos
kubectl get svc -n ingress-nginx
--------------------------------
# Ver la información de asantech
kubectl get ingress -n asantech
-------------------------------
kubectl get ingress -n asantech -o yaml
--------------------------
# Acceder al servicio
http://<IP-del-nodo>:<puerto-http>
http://192.168.1.13:30007
--------------------------
sudo ufw status
netstat -tuln

------------------------------------------------------------------
**&copy; 2025 [Asier García & Andrés Sierra]**