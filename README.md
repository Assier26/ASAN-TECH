## ASAN-TECH
 Repositorio creado para el desarrollo y la implementación 
 del TFG de Grado Superior de Administración de Sistemas en Red.
 Tutulo:       ASAN-TECH 
 Autores:      Asier García y Andrés Sierra
 
## CONCEPTO GENERALES DEL PROYECTO
La idea de proyecto es montar una empresa que proporciona servicios y soluciones sencillas 
en nube a pequeñas empresas que quieren sumarse a las nuevas tecnologías. 
Se ofrecen servicios de correo privado, Drive, suite Office, facturación y CRM.

Para la arquitectura o disposición de los recursos necesarios vamos a contar con servidores alquilados a clou¡ding,
en los cuales vamos a implementar nuestras tecnologías. La idea es tener una máquina que haga de firewall , 
por donde irá primero el cliente al introducir nuestra pagina web, de ahí queremos redirigir el tráfico a un servidor web 
con LAMP y PhpMyadmin, donde tendremos alojago nuestro sitio web y nuestra aplicación web para que nuestros clientes puedan 
contratar servicios o gestionar lo contratado. Luego, queremos tener otro servidor de aplicaciones en donde 
desplegaremos las aplicaciones con docker gestionado con kubernetes, terraform y ansible. 

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

**&copy; 202 [Asier García & Andrés Sierra]**