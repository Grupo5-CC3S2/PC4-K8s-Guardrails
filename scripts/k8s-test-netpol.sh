#!/usr/bin/env bash
set -u

echo "Iniciando prueba de acceso NO autorizado (Hacker Pod)..."
echo "Intentando conectar desde un pod sin etiquetas permitidas..."

# Curl con timeout corto (5s), esperamos que falle
if kubectl run hacker-pod --rm -i --restart=Never --image=curlimages/curl -n secure-apps -- -s -m 5 http://python-app:5000/health > /dev/null 2>&1; then
    echo "FALLO: El hacker pod pudo conectarse."
    echo "Esto significa que la NetworkPolicy NO se esta aplicando."
    echo "(Probablemente falta un plugin CNI como Calico en Minikube)"
    exit 1
else
    # Si fallo, asumimos que fue bloqueado (conexion rechazada o timeout)
    echo "EXITO: El hacker pod fue bloqueado (conexion rechazada o timeout)."
    exit 0
fi
