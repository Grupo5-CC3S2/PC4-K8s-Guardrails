# Risk Register

Riesgos que podrían ocurrir durante el desarrollo del proyecto

## 1. Manifiestos YAML mal configurados (errores de sintaxis)
- **Descripción:** Los manifiestos pueden estar mal escritos y causar despliegues fallidos o inconsistentes.
- **Probabilidad:** Media
- **Impacto:** Alto
- **Mitigación:**
    - Validación temprana con `kubectl apply --dry-run=client`
    - Uso de `check_policies.py` para validar reglas mínimas
- **Estado:** Abierto

## 2. Pods bloqueados por SecurityContext estricto
- **Descripción:** Configuraciones como `runAsNonRoot` o `readOnlyRootFilesystem` pueden romper la aplicación
- **Probabilidad:** Alta
- **Impacto:** Medio
- **Mitigación:**
    - Probar la app localmente
    - SecurityContext progresivo
- **Estado:** Abierto

## 3. NetworkPolicies demasiado restrictivas
- **Descripción:** La aplicación podría quedarse aislada y sin recibir tráfico.
- **Probabilidad:** Media
- **Impacto:** Alto
- **Mitigación:**
    - Crear un pod de prueba (“ingress-pod”)
    - Hacer smoke test después de aplicar políticas
- **Estado:** Abierto

## 4. Pipeline fallando por scripts inseguros o mal escritos
- **Descripción:** Los scripts Bash pueden fallar o no manejar errores críticos.
- **Probabilidad:** Media
- **Impacto:** Medio
- **Mitigación:**
    - Usar `set -euo pipefail`
    - Revisar en PR y probar local antes de subir
- **Estado:** Abierto
