# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail

KUBERNETES_VERSION="v1.37"
CRIO_VERSION="v1.37"
#CRICTL_VERSION="v1.36.0"
#KUBERNETES_INSTALL_VERSION="1.36.0-1.1"

echo "================================================="
echo "ACTUALIZAMOS INDICES Y NOS BAJAMOS CURL"
# Actualizamos los índices de los repositorios para bajarnos las últimas versiones de los paquetes
apt-get update
apt-get install -y software-properties-common curl

echo "================================================="
echo "ASEGURAMOS EL KEYRING"
# Aseguramos que existe la carepta keyring para las claves
#sudo install -m 0755 -d /etc/apt/keyrings

echo "================================================="
echo "INSTALAMOS EL CERTIFICADO DEL REPO DE KUBERNETES AL KEYRING"
# Añadimos el repo de kubernetes
# Se ha añadido --batch --yes para sobreescribir los certificados
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list
 
echo "================================================="
echo "INSTALAMOS EL CERTIFICADO DEL REPO DE CRI-O AL KEYRING"
# Añadimos el repo de CRI-O
# Se ha añadido --batch --yes para sobreescribir los certificados
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor --batch --yes -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list
 
echo "================================================="
echo "INSTALAMOS CRI-O, KUBELET, KUBEADM, KUBECTL"
# Actualizamos los repos (ya que hemos añadido dos nuevos) e instalamos las herramientas
apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl

echo "================================================="
echo "EVITAMOS QUE SE PUEDAN ACTUALIZAR CRI-O, KUBELET, KUBEADM, KUBECTL"
#Evitamos que se actualicen las dependencias necesarias
apt-mark hold cri-o kubelet kubeadm kubectl


# Inicializamos los servicios de CRI-O y kubeadm
#systemctl enable --now kubelet
systemctl start crio.service

#KUBE_EXTRA_ARGS+='--cri-socket "unix:///var/run/crio/crio.sock"'

#echo KUBELET_EXTRA_ARGS=$KUBE_EXTRA_ARGS | sudo tee /etc/default/kubelet