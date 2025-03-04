#!/bin/bash

# Generar claves SSH (si no existen)
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Generando claves SSH..."
  ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
else
  echo "Las claves SSH ya existen."
fi

# Copiar la clave pública a los hosts
echo "Copiando la clave pública a los hosts..."
ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.12  # Master
ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.13  # Worker1
ssh-copy-id -i ~/.ssh/id_rsa.pub asan@192.168.1.14  # Worker2

# Verificar la conexión SSH sin contraseña
echo "Verificando la conexión SSH sin contraseña..."
ansible all -i ansible/inventory -m ping

if [ $? -eq 0 ]; then
  echo "¡Las claves SSH se han configurado correctamente!"
else
  echo "Error: No se pudo conectar a todos los hosts sin contraseña."
  exit 1
fi