#!/usr/bin/env bash
set -euo pipefail

# Configurar el contexto de minikube
export KUBECONFIG=~/.kube/config
kubectl config use-context minikube > /dev/null 2>&1 || true

echo "Limpiando recursos en orden inverso"

echo "Borrando Service"
kubectl delete -f k8s/service.yaml --ignore-not-found=true && echo "Service eliminado" || echo "Service no existia"

echo "Borrando Deployment"
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true && echo "Deployment eliminado" || echo "Deployment no existia"

echo "Borrando Secret"
kubectl delete -f k8s/secret.yaml --ignore-not-found=true && echo "Secret eliminado" || echo "Secret no existia"

echo "Borrando ConfigMap"
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true && echo "ConfigMap eliminado" || echo "ConfigMap no existia"

echo "Borrando Namespace"
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true && echo "Namespace eliminado" || echo "Namespace no existia"

echo ""
echo "Limpieza completada"
