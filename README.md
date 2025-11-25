# Proyecto 5 - K8S Guardtrails

Aplicación de "barreras de seguridad" para una aplicación simple de python en Flask.

## Requisitos

Estar en windows y tener instalado `minikube`, `docker` y `syft`

## ¿Cómo reproducir el proyecto?

Antes de ejecutar cualquier comando, se debe cambiar la linea:

```Makefile
export HOME := /c/Users/User
``` 

en el `Makefile`. Se debe reemplazar por la carpeta en la que se encuentra la configuración de minikube (`.kube/config`)

Ejecutar:

```bash
# 1. Iniciar cluster de kubernetes con CNI calico y driver de docker
minikube start --driver=docker --cni=calico

# 2. Aplicación de manifestos
make k8s-apply
```

> `k8s-apply` automáticamente realiza todos los escaneos de vulnerabilidades (análisis estático)

Luego, en modo administrador:

```bash
make k8s-url
```

Esto generará un tunel entre nuestra máquina y el contenedor de minikube. La salida será el puerto en el `localhost` donde se encuentre dicho túnel. Si hacemos `curl http://localhost:puerto/health`, se debe obtener:

```
{"status". "ok"}
``` 

### Otras funciones

- Para construir imagen de la aplicacion y generar reporte SBOM de esta:

    ```bash
    make build
    make sbom # En modo administrador
    ``` 

- Para eliminar cluster

    ```bash
    make k8s-clean
    ```

- Para ejecutar prueba de humo de endpoint `health/`

    ```bash
    make k8s-smoke
    ```

- Para hacer el análisis estático de vulnerabilidades

    ```bash
    make scan
    ```

- Para verificar el bloqueo de tráfico no autorizado

    ```bash
    make k8s-test-netpol
    ```