# Visión

En entornos de DevOps (especialmente en empresas que manejan datos sensibles), es crucial garantizar que las aplicaciones que se despliegan en Kubernetes cumplan con un conjunto mínimo de estándares de seguridad.

Nos basamos en un escenario real comun donde un equipo necesita crear un "carril rápido" para aplicaciones. Por lo que estas deben demostrar un nivel de madurez en seguridad y configuración (como limitar privilegios) antes de ser promovidas a producción. La implementación de **guardrails** (o barreras de seguridad) es la solución para **automatizar** este cumplimiento.

## Problema que resuelve

El problema central es la falta de cumplimiento de seguridad y la ausencia de un proceso automatizado para validar manifiestos de Kubernetes antes o durante el despliegue.

El proyecto resuelve esto al:
1.  Imponer políticas de seguridad a nivel de pod (a través de `SecurityContext`) para reducir la superficie de ataque (ej. no correr como root)
2.  Restringir la comunicación de red de los pods (a través de `NetworkPolicies`) para asegurar el principio de mínimo privilegio de red
3.  Implementar una validación "shift-Left" (validación temprana) a través de *policy as code* ligero para rechazar manifiestos mal configurados **antes** de que intenten aplicarse al cluster, ahorrando tiempo y previniendo incidentes

## Alcance del Proyecto

El proyecto tiene un alcance local, centrado en un clúster de *Minikube*.

* **Infraestructura:** Creación de un **namespace dedicado** (`secure-apps`) que servirá como el entorno controlado
* **Aplicacion de Ejemplo:** Despliegue de una aplicación **Python simple** para demostrar el funcionamiento bajo las políticas de seguridad
* **Seguridad activa:** Aplicación de controles (`SecurityContext` y `NetworkPolicies`).
* **Validación Estática (policy as code):** Desarrollo de un **script** simple de validación (`check_policies.py`) que analiza archivos YAML sin interactuar con el cluster como tal
* **Automatización:** Scripts (`k8s-apply.sh`, `run-policy-checks.sh`, etc.) para automatizar el ciclo de vida de despliegue y la verificacion

## Objetivos Técnicos

* **Configuración Segura de Pods:** Configurar un *deployment* para usar *pod security* estricto (ej. `runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, `capabilities.drop: ALL`).
* **Segmentación de red:** Definir una **NetworkPolicy** que sólo permita el tráfico de entrada (`Ingress`) estrictamente necesario (ej. solo desde un pod/namespace específico para simular un *gateway* de entrada).
* **Policy as code ligero:** Crear una herramienta en Python/Bash capaz de **parsear manifiestos YAML** de Kubernetes y verificar reglas esenciales (ej. no usar el tag `:latest`, presencia de `resources.limits`, y que `privileged` no sea `true`)
* **Automatización:** Crear *scripts* para el despliegue, la comprobación de salud (*smoke test*) y la ejecución de las validaciones

## Objetivos de Aprendizaje

* Aprender sobre los controles de seguridad nativos de Kubernetes (especialmente `SecurityContext` y `NetworkPolicies`)
* Comprender y aplicar el concepto de validación "shift-Left" de la configuración
* Comprender la **automatización y cumplimiento (seguridad)** en el despliegue de aplicaciones en K8s