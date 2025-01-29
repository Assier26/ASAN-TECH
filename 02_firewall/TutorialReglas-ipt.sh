#!/bin/bash
#Este script realiza las siguiente operaciones:
	#1. Borra todas las reglas de las tablas filter y nat
	#2. establece las políticas por defecto a Denegar todo el tráfico en las tres cadenas.

#Eliminar relgas en las tablas filter y nat:
iptables -t filter -F
iptables -t nat -F

#Reiniciar los contadores en las tablas filter y nat
iptables -t filter -Z
iptables -t nat -Z

#Política por defecto
#Denegar todo el tráfico en las tres cadenas de filter (INPUT, OUTPUT, FORWARD)
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#Peticiones y Respuestas al ping
iptables -A OUTPUT -o enp0s3 -p icmp -j ACCEPT
iptables -A INPUT -i enp0s3 -p icmp -j ACCEPT

#Consultas y respuestas DNS
iptables -A OUTPUT -o enp0s3 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i enp0s3 -p udp --sport 53 -j ACCEPT

iptables -A OUTPUT -o enp0s3 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -i enp0s3 -p tcp --sport 53 -j ACCEPT

#Habilitar interfaz loopback en systemd-resolve
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I OUTPUT 1 -o lo -j ACCEPT


#Tráfico HTTP
iptables -A OUTPUT -o enp0s3 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i enp0s3 -p tcp --sport 80 -j ACCEPT

#Trafico HTTPs
iptables -A OUTPUT -o enp0s3 -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -i enp0s3 -p tcp --sport 443 -j ACCEPT



