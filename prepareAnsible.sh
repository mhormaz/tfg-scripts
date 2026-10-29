# Deja de ejecutarse si falla un comando (-e), se comprueban que existen todas las variables utilizadas (-u)
# y todas las ejecuciones de comandos (-x) y errores (-o) se muestran por consola
set -euo pipefail

echo "================================================="
echo "ACTUALIZAMOS INDICES Y DESCARGAMOS GPG Y CA-CERTIFICATES"
# Actualizamos los índices de los repositorios para bajarnos las últimas versiones de los paquetes
sudo apt update && sudo apt install ca-certificates gpg


echo "================================================="
echo "INSTALAMOS REPO DE ANSIBLE"
# Valido para debian e ubuntu
UBUNTU_CODENAME=noble
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmor -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list

echo "================================================="
echo "ACTUALIZAMOS INDICES Y DESCARGAMOS ANSIBLE"
sudo apt update && sudo apt install ansible