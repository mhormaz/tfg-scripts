# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail


# Creamos logs
LOG_DIR="/var/log/installk8sNode/"
mkdir -p $LOG_DIR

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S.%s")
LOG_FILE="instk8sNode_$TIMESTAMP.log"

#exec > >(tee -a ${LOG_DIR}/${LOG_FILE}) 2>&1
{
echo "================================================="
echo "SE HA CREADO UN REGISTRO DE LOGS EN: ${LOG_DIR}/${LOG_FILE}"

echo "================================================="
echo "ACTUALIZAMOS INDICES Y DESCARGAMOS GPG Y CA-CERTIFICATES"
# Actualizamos los índices de los repositorios para bajarnos las últimas versiones de los paquetes
apt-get update && apt-get -y install ca-certificates gpg ssh wget


echo "================================================="
echo "INSTALAMOS REPO DE ANSIBLE"
# Valido para debian e ubuntu
UBUNTU_CODENAME=noble
#Usamos --batch --yes para sobreescribir el certificado
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list

echo "================================================="
echo "ACTUALIZAMOS INDICES Y DESCARGAMOS ANSIBLE"
apt-get update && apt-get install -y ansible


echo "================================================="
echo "SE HA COMPLETADO LA INSTALACIÓN CORRECTAMENTE"
echo "Se puede utilizar aprovisionar este nodo para servir en el cluster"
} > ${LOG_DIR}/${LOG_FILE}