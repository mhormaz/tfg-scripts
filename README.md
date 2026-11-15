# tfg-scripts
Repositorio con scripts y herramientas para la instalación del cluster


Para preparar un nodo para el control plane ejecuta el script

```sh
curl -H "Cache-Control: no-cache, no-store" -H "Pragma: no-cache" "https://raw.githubusercontent.com/mhormaz/tfg-scripts/refs/heads/main/prepareAnsibleNode.sh"
```

Para preparar un nodo worker, ejecuta el siguiente script:
```sh
curl -H "Cache-Control: no-cache, no-store" -H "Pragma: no-cache" "https://raw.githubusercontent.com/mhormaz/tfg-scripts/refs/heads/main/prepareBasicNode.sh"
```
