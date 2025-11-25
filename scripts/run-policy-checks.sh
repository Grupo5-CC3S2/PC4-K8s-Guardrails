#!/usr/bin/env bash
set -euo pipefail

# Detectar comando de python disponible
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
elif command -v python &> /dev/null; then
    PYTHON_CMD=python
else
    echo "ERROR: No se encontro python ni python3"
    exit 1
fi

# Ejecutar checker (si falla, el script se detiene por set -e)
$PYTHON_CMD policy-checker/check_policies.py

# Mostrar reporte
cat report.json

# Salir con el estado del check
if grep -q '"pass": true' report.json; then
    exit 0
else
    exit 1
fi
