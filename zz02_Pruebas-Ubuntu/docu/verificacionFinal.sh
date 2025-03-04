#!/bin/bash

# Verificar conexión SSH a todos los hosts
echo "Verificando conexión SSH a los hosts..."
ansible all -i ../../ansible/inventory -m ping

# Verificar que el swap esté deshabilitado
echo "Verificando que el swap esté deshabilitado..."
ansible all -i ../../ansible/inventory -a "swapon --show"

# Verificar que los hostnames estén configurados
echo "Verificando hostnames..."
ansible all -i ../../ansible/inventory -a "hostnamectl"

# Verificar que los archivos YAML estén en su lugar
echo "Verificando archivos YAML..."
ls -l kubernetes/

# Verificar que la página web esté configurada
echo "Verificando archivos de la página web..."
ls -l web/