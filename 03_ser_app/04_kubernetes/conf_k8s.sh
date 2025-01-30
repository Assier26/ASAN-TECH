#!/bin/bash
#
# Este script tiene la función de configurar kubernetes en la máquina
# 
#
# Inicializar un Kluster de Kubernetes
sudo kubeadm init 


sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config