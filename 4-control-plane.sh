# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail

# Versión compatible con la versión v1.37 de kubernetes
CALICO_VERSION="v3.33.0"

echo "================================================="
echo "INSTALAMOS LAS DEFINICIONES Y EL OPERADOR DE CALICO"

# Instalamos las definiciones propias para Calico
kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/v3_projectcalico_org.yaml"

# Creamos el operador Tigera, para el CNI de Calico
kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml"

#Esperamos a que se instalen correctamente las cosas
#sleep 30

echo "================================================="
echo "COMPROBAMOS CIDR DEL CLUSTER"
# Comprobamos si está configurado CIDR para las ips de los pods

DEFAULT_CIDR="192.168.0.0/16" #Valor por defecto que usa cálico

# Recuperamos el valor CIDR del cluster (este debería estar configurado ya)
CLUSTER_CIDR=$(kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep -E "cluster-cidr" | grep -oP "\d+\.\d+\.\d+\.\d+/\d+")
# Tenemos que comprobar que su rango no choca con la ip de la máquina
if [ -z "$CLUSTER_CIDR" ]; then
  CLUSTER_CIDR="$DEFAULT_CIDR"
fi

echo "EL cidr establecido para los pods es: $CLUSTER_CIDR"


echo "================================================="
echo "INSTALACIÓN FINAL DE LOS SERVICIOS Y PODS"

# Instalamos los recursos necesarios para Calico, usando iptables para la red
curl -O https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml

# Podemos modificar este archivo para cambiar la configuración de calico. Por ejemplo para el rango de ips de los pods
sed -i "s|cidr: 192.168.0.0/16|cidr: $CLUSTER_CIDR|g" custom-resources.yaml

kubectl apply -f custom-resources.yaml

# Esperamos un poco para que tigerastatus esté disponible
sleep 10

echo "Esperando a que se configure Calico"
kubectl wait tigerastatus --all --for=jsonpath='{.status.conditions[?(@.type=="Available")].status}'=True --timeout=300s


rm ./custom-resources.yaml

echo "================================================="
echo "INSTALACIÓN DE CALICO COMPLETADA CON ÉXITO"
echo "================================================="