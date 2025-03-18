## ASAN-TECH
 Repositorio creado para el desarrollo y la implementación 
 del TFG de Grado Superior de Administración de Sistemas en Red.
 Tutulo:       ASAN-TECH 
 Autores:      Asier García y Andrés Sierra
 
## CONCEPTO GENERALES DEL PROYECTO
La idea de proyecto es montar una empresa que proporciona servicios y soluciones sencillas 
en nube a pequeñas empresas que quieren sumarse a las nuevas tecnologías. 
Se ofrecen servicios de correo privado, Drive, suite Office, facturación y CRM.
Todo el software será OpenSource.

Para la arquitectura de los recursos necesarios vamos a contar con servidores alquilados a clouding,
en los cuales vamos a implementar nuestras tecnologías. 

La idea es tener una máquina que haga de firewall , por donde irá primero el cliente al introducir nuestra pagina web, de ahí queremos redirigir el tráfico a un servidor web con LAMP y PhpMyadmin, donde tendremos alojago nuestro sitio web y nuestra aplicación web para que nuestros clientes puedan contratar servicios o gestionar lo contratado. Luego, queremos tener otro servidor de aplicaciones en donde desplegaremos las aplicaciones con docker gestionado con kubernetes, terraform y ansible. 

Queremos que según el cliente rellene un formulario para contratarnos un servicio, se le cree o levante un contenedor 
con los datos del usuario pasado por variables y el software que quiere contratar. Todo automatizado a través de script y variables.

Además, para no guardar contraseñas vamos a usar un hash para verificar las credenciales de usuarios. 
Protegiéndonos ante fuga de contraseñas.
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
1. Desarrollo Web -->
    a. Pagina Web (Todo el mundo)
        1. Home, contacto, quienes somos, legalidad (politica coohies, politica privacidad), formulario de contratación de servicios, login.
    b. App Web (Usuarios - login)
        1. Login -> conexion.php, loging.php, etc...
2. Implementación de Arquitectura:
    a. 1º maquina: Firewall - con pfsense (nat, proxy, balancer, firewall)
    b. 2º maquina: Serv. Controler - con Ansible, ¿Servidor Web?, 
    c. 3º maquina: Serv. App - donde se crean los contenedores. 
3. Documentación del Proyecto

## RAMAS DEL PROYECTO
main:
- ramaAndres
- ramaAsier

**&copy; 2025 [Asier García & Andrés Sierra]**


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
|
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
    Una vez que todo esté configurado, puedes usar el playbook playbook-deploy.yml 
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

Pasos que áun faltan

1. conexión de worker al cluster
2. despliegue de la web
3. despliegue de aplicaciones.
4. Configuración de ingress Controles para exponer servicios.
5. Automatización de la contratación y levantamiento de servicios.

----------------------------------
2. Flujo de Trabajo Recomendado
El orden correcto para exponer un servicio con el Ingress Controller es:

1. Desplegar la aplicación:
    - Crea los pods que ejecutan tu aplicación.
    - Asegúrate de que los pods estén en estado Running.
2. Crear un servicio:
    - Define un servicio para exponer los pods internamente en el clúster.
    - El servicio debe tener un selector que coincida con las etiquetas de los pods.
3. Desplegar el Ingress Controller:
    - Instala el Ingress Controller (por ejemplo, Nginx Ingress Controller).
4. Crear un recurso Ingress:
    - Configura un recurso Ingress para enrutar el tráfico externo al servicio.
----------------------------------

1. Si usaste un Service de tipo NodePort
Cuando expones un servicio como NodePort, Kubernetes asigna un puerto en el rango 30000-32767 en cada nodo del clúster. Puedes acceder a la aplicación usando la IP de cualquier nodo y ese puerto.

Pasos:
Obtén la IP del nodo:

Si estás en un entorno local (por ejemplo, Minikube), usa:

bash
Copy
minikube ip
Si estás en un clúster en la nube o on-premise, obtén la IP de uno de los nodos.

Obtén el puerto asignado:

Verifica el puerto asignado al servicio:

bash
Copy
kubectl get svc mi-servicio
Verás algo como esto:

Copy
NAME         TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
mi-servicio  NodePort   10.96.123.45    <none>        80:30001/TCP   5m
Aquí, el puerto asignado es 30001.

Accede a la aplicación:

Abre un navegador web y visita:

Copy
http://<IP-del-nodo>:<Puerto-NodePort>
Por ejemplo:

Copy
http://192.168.1.100:30001
2. Si usaste un Ingress Controller
Si configuraste un Ingress Controller y un recurso Ingress, puedes acceder a la aplicación usando el dominio que definiste en el recurso Ingress.

Pasos:
Obtén la IP del Ingress Controller:

Verifica la IP del servicio del Ingress Controller:

bash
Copy
kubectl get svc -n ingress-nginx
Verás algo como esto:

Copy
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller LoadBalancer   10.96.123.45    192.168.1.100   80:30001/TCP,443:30002/TCP   5m
Aquí, la IP externa es 192.168.1.100.

Configura el DNS:

Si estás en un entorno de producción, configura un registro DNS para que el dominio (por ejemplo, mi-app.com) apunte a la IP del Ingress Controller.

Si estás en un entorno de prueba, puedes editar el archivo /etc/hosts en tu máquina local para mapear el dominio a la IP:

Copy
192.168.1.100 mi-app.com
Accede a la aplicación:

Abre un navegador web y visita:

Copy
http://mi-app.com
Si configuraste SSL/TLS, visita:

Copy
https://mi-app.com



----------- Flujo General   ----------
1. Usuario contrata un servicio:
    - El usuario accede a la aplicación web (Asan-tech) a través del Ingress Controller.
    - En la web, elige un servicio (por ejemplo, Nextcloud o FacturaScript) y hace clic en "Contratar".

2. La aplicación web procesa la solicitud:
    - El backend de la aplicación web (PHP) recibe la elección del usuario.
    - El backend ejecuta un playbook de Ansible para desplegar el servicio en Kubernetes.

3. Ansible despliega el servicio:
    - Ansible usa las variables dinámicas para desplegar el servicio elegido.
    - El servicio se expone a través de un nuevo Ingress (por ejemplo, nextcloud.asan-tech.com o facturascript.asan-tech.com).

4. Usuario accede al servicio:
    - Una vez desplegado, el usuario puede acceder al servicio a través del dominio correspondiente.

mi-proyecto/
├── app/                          # Código PHP de la aplicación web
│   ├── index.php                 # Página principal
│   ├── contratar.php             # Lógica para contratar servicios
│   ├── ...
├── ansible/
│   ├── playbook.yml              # Playbook para desplegar servicios
│   ├── inventory                 # Inventario de Ansible
├── kubernetes/
│   ├── asan-tech-deployment.yaml # Despliegue de la aplicación web
│   ├── asan-tech-service.yaml    # Servicio de la aplicación web
│   ├── asan-tech-ingress.yaml    # Ingress de la aplicación web

Si la aplicación web está desplegada en Kubernetes, el código PHP debe estar en un volumen montado en el contenedor.

Esto es útil si la aplicación web es parte de tu clúster de Kubernetes.
Ejemplo en PHP
-------------------------
<?php
// contratar.php

// 1. Recibir la elección del usuario
$servicio_elegido = $_POST['servicio'];  // nextcloud o facturascript

// 2. Validar la elección
if ($servicio_elegido !== 'nextcloud' && $servicio_elegido !== 'facturascript') {
    die("Servicio no válido.");
}

// 3. Ejecutar el playbook de Ansible
$command = "ansible-playbook /ruta/al/playbook.yml -e 'servicio_elegido=$servicio_elegido'";
$output = shell_exec($command);

// 4. Mostrar el resultado al usuario
echo "<h1>Servicio contratado: $servicio_elegido</h1>";
echo "<pre>$output</pre>";  // Mostrar la salida de Ansible
echo "<p>Accede al servicio en: <a href='http://$servicio_elegido.asan-tech.com'>$servicio_elegido.asan-tech.com</a></p>";
?>
---------------------

Cómo Funciona el Código PHP
1. Recibe la elección del usuario:
    - El usuario elige un servicio en un formulario HTML y envía la solicitud a contratar.php.
    - El servicio elegido se recibe en $_POST['servicio'].

2. Valida la elección:
    - Asegúrate de que el servicio elegido sea válido (nextcloud o facturascript).

3. Ejecuta el playbook de Ansible:
    - Usa shell_exec para ejecutar el playbook de Ansible con la variable servicio_elegido.

4. Muestra el resultado al usuario:
    - Muestra un mensaje confirmando que el servicio ha sido contratado.
    - Proporciona un enlace para acceder al servicio.

Integración Completa
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




# Comandos útiles de kubernetes
# Ver los pods de todos los namespace
kubectl get pods --all-namespaces
--------------------------
NAMESPACE       NAME                                        READY   STATUS    RESTARTS   AGE
asantech        asan-tech-deployment-765456958d-nvx9k       1/1     Running   0          110s
asantech        mi-db-deployment-5759df87c9-6d8hn           1/1     Running   0          111s
ingress-nginx   ingress-nginx-controller-6844bf55c7-qd54x   1/1     Running   0          2m20s
kube-system     calico-kube-controllers-7498b9bb4c-zkhc6    1/1     Running   0          3m5s
kube-system     calico-node-m8wjw                           0/1     Running   0          3m5s
kube-system     calico-node-ws9nn                           0/1     Running   0          2m25s
kube-system     coredns-668d6bf9bc-mvrjv                    1/1     Running   0          3m5s
kube-system     coredns-668d6bf9bc-tg4j7                    1/1     Running   0          3m5s
kube-system     etcd-master1                                1/1     Running   0          3m12s
kube-system     kube-apiserver-master1                      1/1     Running   0          3m13s
kube-system     kube-controller-manager-master1             1/1     Running   0          3m12s
kube-system     kube-proxy-5ntw8                            1/1     Running   0          2m25s
kube-system     kube-proxy-g66qb                            1/1     Running   0          3m5s
kube-system     kube-scheduler-master1                      1/1     Running   0          3m12s
--------------------------
# Ver los pods de ingresss
kubectl get pods -n ingress-nginx

# Ver la información del pod.
kubectl get svc
kubectl get svc -n ingress-nginx
# PAra ver el log de un pod 
kubectl logs -n ingress-nginx ingress-nginx-controller-

# Obtener la ip de los nodos
kubectl get nodes -o wide
---------------------------
NAME      STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
master1   Ready    control-plane   7m17s   v1.32.3   192.168.1.12   <none>        Ubuntu 24.04.2 LTS   6.8.0-55-generic   containerd://1.7.24
worker1   Ready    <none>          6m28s   v1.32.3   192.168.1.13   <none>        Ubuntu 24.04.2 LTS   6.8.0-55-generic   containerd://1.7.24
---------------------------

# Ver puertos expuestos
kubectl get svc -n ingress-nginx
---------------------------
NAME                       TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                                     AGE
ingress-nginx-controller   NodePort   10.103.142.247   <none>        80:32162/TCP,443:32706/TCP,8443:31155/TCP   7m1s
--------------------------------

# Ver la información de asantech
kubectl get ingress -n asantech
--------------------------------
asan@master1:~$ kubectl get ingress -n asantech
NAME                CLASS   HOSTS               ADDRESS   PORTS     AGE
asan-tech-ingress   nginx   home.asantech.com             80, 443   2m11s
-------------------------------
kubectl get ingress -n asantech -o yaml
-------------------------------
apiVersion: v1
items:
- apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
    creationTimestamp: "2025-03-14T23:53:26Z"
    generation: 1
    name: asan-tech-ingress
    namespace: asantech
    resourceVersion: "790"
    uid: 7097541c-2ee5-4767-b1ba-ca3de5d5ba16
  spec:
    ingressClassName: nginx
    rules:
    - host: home.asantech.com
      http:
        paths:
        - backend:
            service:
              name: asan-tech-service
              port:
                number: 80
          path: /
          pathType: Prefix
    tls:
    - hosts:
      - home.asantech.com
      secretName: wildcard-asantech
  status:
    loadBalancer: {}
kind: List
metadata:
  resourceVersion: ""

-------------------------------
kubectl describe clusterrole ingress-nginx




# Comprobar el secret
kubectl get secret -n asantech

# Verificar el contenido del secret
kubectl describe secret wildcard-asantech -n asantech

# a. Obtener el certificado (tls.crt):
kubectl get secret wildcard-asantech -n asantech -o jsonpath="{.data.tls\.crt}" | base64 --decode

# b. Obtener la clave privada (tls.key):
kubectl get secret wildcard-asantech -n asantech -o jsonpath="{.data.tls\.key}" | base64 --decode

# Verificar que el certificado sea valido
kubectl get secret wildcard-asantech -n asantech -o jsonpath="{.data.tls\.crt}" | base64 --decode | openssl x509 -noout -text

# Verificar que la clave sea valido

kubectl get secret wildcard-asantech -n asantech -o jsonpath="{.data.tls\.key}" | base64 --decode | openssl rsa -check



# Acceder al servicio
http://<IP-del-nodo>:<puerto-http>
http://192.168.1.12:32162


sudo ufw status
netstat -tuln


kubectl describe clusterrolebinding ingress-nginx
asan@master1:~$ kubectl describe clusterrolebinding ingress-nginx
Name:         ingress-nginx
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  ingress-nginx
Subjects:
  Kind            Name           Namespace
  ----            ----           ---------
  ServiceAccount  ingress-nginx  ingress-nginx
