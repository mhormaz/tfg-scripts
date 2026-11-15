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
    echo "ACTUALIZAMOS INDICES Y DESCARGAMOS SSH Y PYTHON3"
    echo "================================================="
    apt-get update && apt-get -y install ssh python3
}

func_install() {

    packages_debian
    echo "================================================="
    echo "SE HA COMPLETADO LA INSTALACIÓN CORRECTAMENTE"
    echo "Este nodo está listo para ser aprovisionado en el cluster"
    echo "================================================="
}

func_install > >(tee -a $LOG_FILE_FULL) 2>&1

echo "=============================================================================="
echo "SE HA CREADO UN REGISTRO DE LOGS EN: $LOG_FILE_FULL"
echo "=============================================================================="