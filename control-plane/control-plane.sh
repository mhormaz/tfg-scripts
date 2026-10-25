# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail

echo "================================================="
echo "VARIABLES PARA KUBEADM - CONTROL PLANE y CRI"

# "head -1" para el DNS, "tail -1" para la ip
IP=$(ip route show default | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -1)

# Poniendo 2>/dev/null mandamos la salida de CRIO a la consola de error para evitar los mensajes de 
# info que salen cada vez que ejecutas crio
CRIO_SOCKET=$(crio config --default 2>/dev/null | grep "^listen =" | grep -oE '\".+\"' | grep -oE '[^\"]+')
CRI_SOCKET="unix://$CRIO_SOCKET"

echo "Usaremos la ip $IP de la máquina, y el CRI $CRI_SOCKET"

echo "================================================="
echo "COMPROBAMOS CIDR DEL CLUSTER -> NECESARIO PARA CALICO"
# Comprobamos si está configurado CIDR para las ips de los pods
DEFAULT_CIDR="193.168.0.0/16"

CLUSTER_CIDR=
# Tenemos que comprobar que su rango no choca con la ip de la máquina
if [ -z "$CLUSTER_CIDR" ]; then
  CLUSTER_CIDR="$DEFAULT_CIDR"
fi

echo "EL cidr establecido es: $CLUSTER_CIDR"

echo "================================================="
echo "INICIALIZANDO CONTROL PLANE"

echo "Usando:"
echo "kubeadm init --cri-socket=${CRI_SOCKET} --pod-network-cidr=${CLUSTER_CIDR} --control-plane-endpoint=${IP} --apiserver-advertise-address=${IP} --apiserver-cert-extra-sans=${IP}"
echo ""

kubeadm init --cri-socket=${CRI_SOCKET} --pod-network-cidr=${CLUSTER_CIDR} #--control-plane-endpoint=${IP} --apiserver-advertise-address=${IP} #--apiserver-cert-extra-sans=${IP}  --node-ip=${IP}


# Configuramos el kubectl
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config