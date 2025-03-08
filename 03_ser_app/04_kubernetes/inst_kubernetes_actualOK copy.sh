- name: Instalar y configurar Kubernetes
  hosts: all
  become: yes
  tasks:
    - name: Actualizar el sistema
      apt:
        update_cache: yes
        upgrade: yes

    - name: Instalar dependencias necesarias
      apt:
        name: 
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg2
          - software-properties-common
        state: present

    - name: Crear directorio de keyrings
      file:
        path: /etc/apt/keyrings
        state: directory
        mode: '0755'

    - name: Añadir clave GPG de Kubernetes
      shell: |
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    - name: Configurar permisos de keyring
      file:
        path: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        mode: '0644'

    - name: Añadir repositorio de Kubernetes
      shell: |
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

    - name: Configurar permisos de lista de repositorios
      file:
        path: /etc/apt/sources.list.d/kubernetes.list
        mode: '0644'

    - name: Instalar Kubernetes
      apt:
        update_cache: yes
        name: 
          - kubectl
          - kubelet
          - kubeadm
        state: present

    - name: Mantener versión actual de Kubernetes
      shell: apt-mark hold kubelet kubeadm kubectl

    - name: Habilitar kubelet
      systemd:
        name: kubelet
        enabled: yes
        state: started

    - name: Verificar instalación de Kubernetes (kubectl)
      shell: kubectl version --client

    - name: Verificar instalación de Kubernetes (kubeadm)
      shell: kubeadm version

    - name: Deshabilitar swap
      shell: |
        swapoff -a
        sed -i '/swap/ s/^/#/' /etc/fstab

    - name: Activar funciones del kernel
      modprobe:
        name: "{{ item }}"
      with_items:
        - overlay
        - br_netfilter

    - name: Añadir configuraciones de red
      copy:
        dest: /etc/sysctl.d/kubernetes.conf
        content: |
          net.bridge.bridge-nf-call-ip6tables = 1
          net.bridge.bridge-nf-call-iptables = 1
          net.ipv4.ip_forward = 1

    - name: Aplicar cambios de configuración
      command: sysctl --system

    - name: Configurar carga de módulos de manera persistente
      copy:
        dest: /etc/modules-load.d/containerd.conf
        content: |
          overlay
          br_netfilter

    - name: Añadir repositorio de Docker
      shell: |
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    - name: Instalar containerd.io
      apt:
        update_cache: yes
        name: containerd.io
        state: present

    - name: Configurar containerd
      shell: |
        mkdir -p /etc/containerd
        containerd config default | tee /etc/containerd/config.toml

    - name: Reiniciar y habilitar containerd
      systemd:
        name: containerd
        enabled: yes
        state: restarted
