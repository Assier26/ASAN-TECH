#!/bin/bash

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

# # --- Verificación del estado del clúster ---
# echo "Verificando el estado del clúster..."

# # Verificar nodos
# echo "Nodos del clúster:"
# kubectl get nodes

# # Verificar pods
# echo "Pods en todos los namespaces:"
# kubectl get pods --all-namespaces

# # Verificar servicios
# echo "Servicios:"
# kubectl get services

# # Verificar que la página web esté funcionando
# echo "Verificando que la página web esté funcionando..."
# WEB_SERVICE_IP=$(kubectl get service web-service -o jsonpath='{.spec.clusterIP}')
# WEB_SERVICE_PORT=$(kubectl get service web-service -o jsonpath='{.spec.ports[0].port}')

# if curl -s "http://${WEB_SERVICE_IP}:${WEB_SERVICE_PORT}" > /dev/null; then
#   echo "La página web está funcionando correctamente."
# else
#   echo "Error: No se pudo acceder a la página web."
#   exit 1
# fi

# echo "Despliegue completado exitosamente."