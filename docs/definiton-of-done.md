# Definition of Done (DoD)

Para que cualquier issue o historia pase a **Done**, debe cumplir *todos* los siguientes criterios:

## Calidad de código
- Código legible, comentado y sin basura
- Sin uso de `latest` en imagenes

## Scripts y Makefile
- Todos los `make <target>` funcionan sin pasos manuales adicionales
- Scripts Bash contienen `set -euo pipefail` y `#!/usr/env bash`
- Los scripts corren correctamente en Linux

## Seguridad (pipeline)

Una vez implementadas las acciones de seguridad (en makefile o actions) se debe tener:

- Evidencias generadas:  
  - SBOM (Software Bill of Materials)  
  - Reporte del checker (`policy-checker/report.json`)  