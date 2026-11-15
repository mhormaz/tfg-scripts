# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail


# Creamos logs
LOG_DIR="/var/log/installBasick8sNode"
mkdir -p $LOG_DIR

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S.%s")
LOG_FILE="basick8sNode_$TIMESTAMP.log"
LOG_FILE_FULL=${LOG_DIR}/${LOG_FILE}

packages_debian() {
    echo "================================================="
    echo "ACTUALIZAMOS INDICES Y DESCARGAMOS SSH, PYTHON3 Y NMCLI"
    echo "================================================="
    apt-get update && apt-get -y install ssh python3 python3-debian python3-venv 
}

static_ip() {

    # "head -1" para el GATEWAY, "tail -1" para la ip
    CURRENT_IP=$(ip route show default | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -1)
    CURRENT_GATEWAY=$(ip route show default | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    CURRENT_DNS= $(cat /etc/resolv.conf | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | xargs)
    CURRENT_INTERFACE= $(ip route show default | grep -oP 'dev (.+?) ' | cut -d ' ' -f2)

    # Directorio de configuracion de las interfaces de red
    INTERFACE_DIR="/etc/network/interfaces"

    # Guardar configuración anterior
    cp "$INTERFACE_DIR" "${INTERFACE_DIR}.bak"

# Construir configuración
cat > /tmp/interfaces.static <<EOF
# Loopback
auto lo
iface lo inet loopback

# Interfaz principal
auto $CURRENT_INTERFACE
iface $CURRENT_INTERFACE inet static
    address $CURRENT_IP
    gateway $GATEWAY
    dns-nameservers $DNS
EOF

    # Guardar configuración anterior
    cp /tmp/interfaces.static "$INTERFACE_DIR"

    echo "================================================="
    echo "APLICADA LA SIGUIENTE CONFIGURACIÓN DE LA INTERFAZ DE RED"
    echo "================================================="
    echo "Se ha guardado la antigua configuración en ${INTERFACE_DIR}.bak"
}

func_install() {

    packages_debian

    static_ip
    
    echo "================================================="
    echo "SE HA COMPLETADO LA INSTALACIÓN CORRECTAMENTE"
    echo "Este nodo está listo para ser aprovisionado en el cluster"
    echo "================================================="
}

func_install > >(tee -a $LOG_FILE_FULL) 2>&1

echo "=============================================================================="
echo "SE HA CREADO UN REGISTRO DE LOGS EN: $LOG_FILE_FULL"
echo "=============================================================================="