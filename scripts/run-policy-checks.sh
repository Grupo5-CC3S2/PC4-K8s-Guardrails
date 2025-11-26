#!/usr/bin/env bash
set -euo pipefail

START_TIME=$(date +%s)

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

END_TIME=$(date +%s)
CHECK_DURATION=$((END_TIME - START_TIME))

echo "Tiempo de validación: ${CHECK_DURATION} segundos"

$PYTHON_CMD -c "
import json
with open('report.json', 'r') as f:
    data = json.load(f)
data['check_duration_seconds'] = $CHECK_DURATION
with open('report.json', 'w') as f:
    json.dump(data, f, indent=2)
"

echo "Reporte detallado en report.json"

# Salir con el estado del check
if grep -q '"pass": true' report.json; then
    exit 0
else
    exit 1
fi
