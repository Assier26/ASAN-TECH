#!/bin/bash
#
# Este script tiene la función de instalar el contendor de FacturaScripts en Docker
# 
#
# Crear red personalizada para FacturaScripts
echo "Creando una red de Docker para FacturaScripts..."
sudo docker network create facturascripts-net

# Crear volúmenes persistentes
echo "Creando volúmenes para datos persistentes..."
sudo docker volume create facturascripts-data
sudo docker volume create facturascripts-db

# Desplegar la base de datos MySQL
echo "Desplegando el contenedor de MySQL..."
sudo docker run -d \
  --name facturascripts-db \
  --network facturascripts-net \
  -e MYSQL_ROOT_PASSWORD=mi_contraseña_segura \
  -e MYSQL_DATABASE=facturascripts \
  -e MYSQL_USER=facturascripts \
  -e MYSQL_PASSWORD=fs_password \
  -v facturascripts-db:/var/lib/mysql \
  mysql:8.0

# Verificar que el contenedor de MySQL esté corriendo
sudo docker ps | grep facturascripts-db || { echo "Error: El contenedor de MySQL no se inició correctamente"; exit 1; }

# Desplegar FacturaScripts
echo "Desplegando el contenedor de FacturaScripts..."
sudo docker run -d \
  --name facturascripts \
  --network facturascripts-net \
  -p 80:80 \
  -v facturascripts-data:/var/www/html \
  facturascripts/facturascripts

# Verificar que el contenedor de FacturaScripts esté corriendo
sudo docker ps | grep facturascripts || { echo "Error: El contenedor de FacturaScripts no se inició correctamente"; exit 1; }

# Información final
echo "FacturaScripts se está ejecutando. Accede a la aplicación en http://$(hostname -I | awk '{print $1}')"
echo "Base de datos MySQL:
- Usuario: facturascripts
- Contraseña: fs_password
- Nombre de la base de datos: facturascripts
"