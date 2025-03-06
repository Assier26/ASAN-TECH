#!/bin/bash

# --- Configuración de permisos ---
echo "Configurando permisos de los archivos..."

# Playbooks de Ansible
sudo chmod 644 ansible/*.yml

# Scripts de Shell
sudo chmod 755 *.sh

# Archivos YAML de Kubernetes
sudo chmod 644 kubernetes/*.yaml

# Archivos de la página web
sudo chmod 644 web/*

# Archivos de configuración
sudo chmod 644 ansible/inventory

# Archivos de base de datos
sudo chmod 644 database/init.sql

# Directorios
sudo chmod 755 ansible/ kubernetes/ web/ database/

echo "Permisos configurados correctamente."

# --- Verificación de conectividad SSH ---
echo "Verificando conexión SSH a los hosts..."
ansible all -i ansible/inventory -m ping

if [ $? -ne 0 ]; then
  echo "Error: No se pudo conectar a todos los hosts por SSH."
  exit 1
fi

echo "Conexión SSH verificada correctamente."

# --- Ejecución del playbook principal ---
echo "Ejecutando el playbook de despliegue..."
ansible-playbook -i ansible/inventory ansible/playbook-main.yml

if [ $? -ne 0 ]; then
  echo "Error: Fallo durante la ejecución del playbook."
  exit 1
fi

echo "Playbook ejecutado correctamente."

# --- Verificación del estado del clúster ---
echo "Verificando el estado del clúster..."

# Verificar nodos
echo "Nodos del clúster:"
kubectl get nodes

# Verificar pods
echo "Pods en todos los namespaces:"
kubectl get pods --all-namespaces

# Verificar servicios
echo "Servicios:"
kubectl get services

# Verificar que la página web esté funcionando
echo "Verificando que la página web esté funcionando..."
WEB_SERVICE_IP=$(kubectl get service web-service -o jsonpath='{.spec.clusterIP}')
WEB_SERVICE_PORT=$(kubectl get service web-service -o jsonpath='{.spec.ports[0].port}')

if curl -s "http://${WEB_SERVICE_IP}:${WEB_SERVICE_PORT}" > /dev/null; then
  echo "La página web está funcionando correctamente."
else
  echo "Error: No se pudo acceder a la página web."
  exit 1
fi

echo "Despliegue completado exitosamente."