#!/usr/bin/env bash
set -e  # Salir si hay algún error

# Configurar el contexto de minikube
export KUBECONFIG=~/.kube/config
kubectl config use-context minikube > /dev/null 2>&1 || true

# Cargar variables del .env si existe
if [ -f .env ]; then
    echo "Cargando variables de .env..."
    # Usar set -a para auto-exportar todas las variables
    set -a
    source .env
    set +a
else
    echo "No se encontró archivo .env"
    exit 1
fi

echo "Inyectando secretos para secret.yaml..."
envsubst < k8s/secret.yaml | kubectl apply -f -

echo "Aplicando configuración..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml