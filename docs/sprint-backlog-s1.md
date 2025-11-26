## Crear namespace.yaml (secure-apps) (#1)

- **Descripción**: Crear manifiesto YAML para el namespace secure-apps.
- **Criterios de aceptación**
    - Archivo ubicado en k8s/namespace.yaml.
- **Responsable**: Jhon Cruz (JECT-02) 

## Crear deployment.yaml de app en python (#2)

- **Descripción**: Crear deployment para aplicación python simple con endpoint /health. Sin securityContext todavía (eso va en Sprint 2).
- **Criterio de aceptación**
    - No usar latest.
    - `ReplicaSet` mínimo de 1.
- **Responsable**: Daren Herrera (scptx0)

## Implementar aplicación python con endpoint /health (#3)

- **Descripción**: Desarrollar una aplicación simple en Python con endpoint /health.
- **Criterios de aceptación**
    - La aplicación expone el endpoint /health mediante HTTP.
    - El endpoint /health retorna:

        ```json
        { "status": "ok" }
        con código HTTP 200.
        ```

    - Se usa Flask
- **Responsable**: Daren Herrera (scptx0)

## Crear service.yaml para exponer /health (#4)

- **Descripción**: Crear service tipo ClusterIP para exponer el deployment de la app.
- **Criterios de aceptación**
    - Puerto definido correctamente.
    - Se asocia al deployment creado para la aplicación de python.
- **Responsable**: Jhon Cruz (JECT-02)

## Crear ConfigMap y Secret (#5)

- **Descripción**: Agregar configmap.yaml y secret.yaml con configuración mínima para la app.
- **Criterios de aceptación**:
    - `Secret` usa base64.
    - `ConfigMap` y `Secret` montados en el deployment.
- **Responsable**: Daren Herrera (scptx0)

## Implementar scripts k8s-apply.sh y k8s-clean.sh (#6)

- **Descripción**: Crear scripts Bash para aplicar y destruir manifiestos.
- **Criterios de aceptación**
    - Shebang correcto.
    - k8s-apply aplica namespace, configmap, secret, deployment, service
- **Responsable**: Jhon Cruz (JECT-02)

## Implementar k8s-smoke.sh para probar /health vía port-forward (#7)

- **Descripción**: Script que usa port-forward y curl para validar la disponibilidad del endpoint /health.
- **Criterios de aceptación**
    - Prueba devuelve HTTP 200.
    - Maneja errores (app caída, pod no listo).
- **Responsable**: Jhon Cruz (JECT-02)

## Documentación inicial del proyecto (#12)

- **Descripción**: Escribir documentación de visión, metricas (normas), definition of done y registro de posibles riesgos durante el desarrollo.
- **Responsable**: Daren Herrera (scptx0)