#!/usr/bin/env bash
set -euo pipefail

# Start timing
START_TIME=$(date +%s)

# Configurar contexto de minikube
export KUBECONFIG=~/.kube/config
kubectl config use-context minikube > /dev/null 2>&1 || true

# Cargar variables del archivo .env
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

echo "Aplicando NetworkPolicy"
kubectl apply -f k8s/networkpolicy.yaml && echo "NetworkPolicy aplicada" || { echo "Error aplicando NetworkPolicy"; exit 1; }

echo "Aplicando Service"
kubectl apply -f k8s/service.yaml && echo "Service aplicado" || { echo "Error aplicando Service"; exit 1; }

# Calcular tiempo de despliegue
END_TIME=$(date +%s)
DEPLOY_DURATION=$((END_TIME - START_TIME))

echo "Todos los recursos aplicados correctamente"
echo "Tiempo de despliegue: ${DEPLOY_DURATION} segundos"

cat >> metrics-deploy.txt <<EOF
[$(date -u +%Y-%m-%d/%H:%M:%S)]
    Tiempo de despliegue: $DEPLOY_DURATION segundos
    
EOF

echo "Metricas en metrics-deploy.txt"