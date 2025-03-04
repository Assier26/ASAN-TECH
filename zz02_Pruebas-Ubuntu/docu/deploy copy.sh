#!/bin/bash

# Ejecutamos el playbook de despliegue 
ansible-playbook -i ansible/inventory ansible/playbook-main.yml

# Verificar el estado del clúster
echo "Verificando el estado del clúster..."
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services