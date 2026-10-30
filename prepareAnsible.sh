# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail


# Creamos logs
LOG_DIR="/var/log/installk8sNode"
mkdir -p $LOG_DIR

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S.%s")
LOG_FILE="instk8sNode_$TIMESTAMP.log"
LOG_FILE_FULL=${LOG_DIR}/${LOG_FILE}

func_install() {

    echo "================================================="
    echo "ACTUALIZAMOS INDICES Y DESCARGAMOS GPG Y CA-CERTIFICATES"
    echo "================================================="
    # Actualizamos los índices de los repositorios para bajarnos las últimas versiones de los paquetes
    apt-get update && apt-get -y install ca-certificates gpg ssh wget

    echo "================================================="
    echo "INSTALAMOS REPO DE ANSIBLE"
    echo "================================================="
    # Valido para debian e ubuntu
    UBUNTU_CODENAME='noble'
    FINGERPRINT='6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367'

    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x${FINGERPRINT}" | gpg --dearmor -o /usr/share/keyrings/ansible-archive-keyring.gpg

cat <<EOF | tee /etc/apt/sources.list.d/ansible.sources > /dev/null
    Types: deb
    URIs: https://ppa.launchpadcontent.net/ansible/ansible/ubuntu/
    Suites: ${UBUNTU_CODENAME}
    Components: main
    Trusted: yes
    Signed-By: /usr/share/keyrings/ansible-archive-keyring.gpg
EOF
    
    echo "================================================="
    echo "ACTUALIZAMOS INDICES Y DESCARGAMOS ANSIBLE"
    echo "================================================="
    apt-get update && apt-get install -y ansible

    echo "================================================="
    echo "SE HA COMPLETADO LA INSTALACIÓN CORRECTAMENTE"
    echo "Se puede utilizar aprovisionar este nodo para servir en el cluster"
    echo "================================================="
}

echo "=============================================================================="
echo "SE HA CREADO UN REGISTRO DE LOGS EN: $LOG_FILE_FULL"
echo "=============================================================================="

func_install > >(tee -a $LOG_FILE_FULL) 2>&1