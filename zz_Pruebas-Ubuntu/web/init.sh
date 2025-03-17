#!/bin/bash

# Modificar la configuración de Apache para que use las variables de entorno
echo "Configurando Apache con las variables de entorno..."

# Configurar SERVER_NAME en el archivo de configuración de Apache
echo "ServerName ${SERVER_NAME}" >> /etc/apache2/apache2.conf

# Configurar DOCUMENT_ROOT en el archivo de configuración de Apache (ajusta si es necesario)
echo "DocumentRoot ${DOCUMENT_ROOT}" >> /etc/apache2/sites-available/000-default.conf

# Si tienes algún otro archivo de configuración para Apache, puedes agregarlo aquí.

# Reiniciar Apache para aplicar las configuraciones
echo "Reiniciando Apache..."
apachectl -D FOREGROUND
