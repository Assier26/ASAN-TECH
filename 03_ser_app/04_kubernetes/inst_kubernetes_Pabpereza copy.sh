- name: Instalar Docker y Kubernetes
  hosts: all
  become: yes
  tasks:
    - name: Actualizar paquetes
      apt:
        update_cache: yes
        upgrade: full

    - name: Instalar Kubernetes
      apt:
        name:
          - kubelet
          - kubeadm
          - kubectl
        state: present

    - name: Mantener versión actual de Kubernetes
      shell: apt-mark hold kubelet kubeadm kubectl

    - name: Verificar instalación de Kubernetes (kubectl)
      shell: kubectl version --client

    - name: Verificar instalación de Kubernetes (kubeadm)
      shell: kubeadm version

    - name: Deshabilitar swap
      shell: |
        sed -i '/swap/ s/^/#/' /etc/fstab
        swapoff -a
        mount -a
        free -h

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



    - name: Instalar dependencias para containerd.io
      apt:
        name:
          - curl
          - gnupg2
          - software-properties-common
          - apt-transport-https
          - ca-certificates
        state: present

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


    - name: Descargar imágenes de Kubernetes
      shell: kubeadm config images pull

    - name: Inicializar el clúster
      shell: |
        kubeadm init --pod-network-cidr=172.24.0.0/16 --cri-socket=unix:///run/containerd/containerd.sock --upload-certs --control-plane-endpoint=master1
        mkdir -p $HOME/.kube
        cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        chown $(id -u):$(id -g) $HOME/.kube/config

    - name: Exportar variable de entorno KUBECONFIG
      shell: export KUBECONFIG=$HOME/.kube/config

    - name: Comprobar que el clúster está funcionando
      shell: kubectl cluster-info


    - name: Descargar y configurar plugin de red Calico
      shell: |
        curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
        curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
        kubectl create -f tigera-operator.yaml
        sed -ie 's/192.168.0.0/172.24.0.0/g' custom-resources.yaml
        kubectl create -f custom-resources.yaml
        kubectl get pods --all-namespaces -w

    - name: Desactivar ejecución de pods en el nodo maestro
      shell: kubectl taint nodes --all node-role.kubernetes.io/control-plane-

    - name: Confirmar el funcionamiento del nodo
      shell: kubectl get nodes -o wide

    - name: Generar token de acceso para workers
      shell: kubeadm token create
      register: token_output

    - name: Generar hash del token de descubrimiento
      shell: openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
      register: hash_output

    - name: Mostrar comando para unir workers al clúster
      debug:
        msg: |
          kubeadm join <control-plane-host>:<control-plane-port> --token {{ token_output.stdout }} --discovery-token-ca-cert-hash sha256:{{ hash_output.stdout }}
