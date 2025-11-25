#!/usr/bin/env bash
set -euo pipefail

# Configurar contexto de minikube
export KUBECONFIG=~/.kube/config
kubectl config use-context minikube > /dev/null 2>&1 || true

echo "Esperando que el pod de la aplicacion este listo"
kubectl wait --for=condition=ready pod -l app=python-app -n secure-apps --timeout=300s > /dev/null || {
    echo "ERROR: El pod de la aplicacion no esta listo"
    echo "Estado del pod:"
    kubectl get pods -n secure-apps
    echo "Eventos recientes:"
    kubectl get events -n secure-apps --sort-by='.lastTimestamp' | tail -n 10
    exit 1
}

echo "Iniciando smoke test interno"
echo "Lanzando pod temporal 'curl-test' para verificar conectividad interna"

# Pod temporal con curl que conecta al servicio http://python-app:5000/health
# Esto valida DNS, Service y Pod sin depender del networking de Windows
if kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl --labels="app=ingress-pod" -n secure-apps -- -s --max-time 10 --connect-timeout 5 http://python-app:5000/health > smoke_output.txt 2> smoke_error.txt; then
    RESPONSE=$(cat smoke_output.txt)
    # Limpieza de archivos temporales
    rm -f smoke_output.txt smoke_error.txt
    
    # Validar contenido de la respuesta
    if echo "$RESPONSE" | grep -q '"status":"ok"' || echo "$RESPONSE" | grep -q '"status": "ok"'; then
        echo "Smoke test exitoso: $RESPONSE"
        exit 0
    else
        echo "ERROR: Respuesta inesperada del servicio:"
        echo "$RESPONSE"
        exit 1
    fi
else
    echo "ERROR: Fallo la conexion al servicio."
    echo "Detalles del error:"
    cat smoke_error.txt
    rm -f smoke_output.txt smoke_error.txt
    exit 1
fi
