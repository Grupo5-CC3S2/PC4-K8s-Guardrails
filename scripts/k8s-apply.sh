#!/usr/bin/env bash
set -euo pipefail

# Configurar el contexto de minikube
export KUBECONFIG=~/.kube/config
kubectl config use-context minikube > /dev/null 2>&1 || true

# Cargar variables del .env si existe
if [ -f .env ]; then
    echo "Cargando variables de .env"
    set -a
    source .env
    set +a
else
    echo "ERROR: No se encontro archivo .env"
    exit 1
fi

echo "Aplicando namespace"
kubectl apply -f k8s/namespace.yaml && echo "Namespace aplicado" || { echo "Error aplicando namespace"; exit 1; }

echo "Aplicando ConfigMap"
kubectl apply -f k8s/configmap.yaml && echo "ConfigMap aplicado" || { echo "Error aplicando ConfigMap"; exit 1; }

echo "Inyectando y aplicando Secret"
envsubst < k8s/secret.yaml | kubectl apply -f - && echo "Secret aplicado" || { echo "Error aplicando Secret"; exit 1; }

echo "Aplicando Deployment"
kubectl apply -f k8s/deployment.yaml && echo "Deployment aplicado" || { echo "Error aplicando Deployment"; exit 1; }

echo "Aplicando Service"
kubectl apply -f k8s/service.yaml && echo "Service aplicado" || { echo "Error aplicando Service"; exit 1; }

echo ""
echo "Todos los recursos aplicados correctamente"