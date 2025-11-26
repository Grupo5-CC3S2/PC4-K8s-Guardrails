import os
import sys
import yaml
import json

def check_policies(directory):
    violations = []
    manifest_stats = {}
    
    # Recorrer directorios recursivamente
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith((".yaml", ".yml")):
                file_path = os.path.join(root, file)
                manifest_stats[file_path] = []  # Lista de violaciones de reglas de esta archivo
                
                try:
                    with open(file_path, 'r') as f:
                        # Cargar todos los documentos del archivo
                        docs = yaml.safe_load_all(f)
                        for doc in docs:
                            if not doc:
                                continue
                                
                            # Chequear solo Pods o Deployments/StatefulSets/DaemonSets/Jobs/CronJobs
                            kind = doc.get('kind', '')
                            
                            # Extraer pod spec segun el kind
                            pod_spec = None
                            metadata = doc.get('metadata', {})
                            obj_name = metadata.get('name', 'unknown')
                            source = f"{file_path} ({kind}/{obj_name})"

                            if kind == 'Pod':
                                pod_spec = doc.get('spec', {})
                            elif kind in ['Deployment', 'ReplicaSet', 'StatefulSet', 'DaemonSet', 'Job']:
                                pod_spec = doc.get('spec', {}).get('template', {}).get('spec', {})
                            elif kind == 'CronJob':
                                pod_spec = doc.get('spec', {}).get('jobTemplate', {}).get('spec', {}).get('template', {}).get('spec', {})
                            
                            if pod_spec:
                                containers = pod_spec.get('containers', [])
                                pod_sec_ctx = pod_spec.get('securityContext', {})
                                
                                for container in containers:
                                    c_name = container.get('name', 'unknown')
                                    c_image = container.get('image', '')
                                    c_sec_ctx = container.get('securityContext', {})
                                    
                                    # 1. Tag de imagen
                                    if c_image.endswith(':latest') or ':' not in c_image.split('/')[-1]:
                                        # Heuristica simple para presencia de tag
                                        if ':' not in c_image:
                                            violation = f"{source}: Imagen '{c_image}' de contenedor no tiene tag"
                                            violations.append(violation)
                                            manifest_stats[file_path].append(violation)
                                        elif c_image.endswith(':latest'):
                                            violation = f"{source}: El contenedor '{c_name}' usa la imagen '{c_image}' con el tag 'latest'"
                                            violations.append(violation)
                                            manifest_stats[file_path].append(violation)

                                    # 2. Limites de recursos
                                    resources = container.get('resources', {})
                                    if not resources.get('limits'):
                                        violation = f"{source}: El contenedor '{c_name}' no tiene limites de recursos"
                                        violations.append(violation)
                                        manifest_stats[file_path].append(violation)

                                    # 3. allowPrivilegeEscalation = false (nivel de contenedor)
                                    if c_sec_ctx.get('allowPrivilegeEscalation') is not False:
                                        violation = f"{source}: El contenedor '{c_name}' no tiene allowPrivilegeEscalation = false"
                                        violations.append(violation)
                                        manifest_stats[file_path].append(violation)

                                    # 4. runAsNonRoot = true (nivel de Pod o contenedor)
                                    # Valor efectivo: valor del contenedor sobreescribe al del pod
                                    c_run_as_non_root = c_sec_ctx.get('runAsNonRoot')
                                    p_run_as_non_root = pod_sec_ctx.get('runAsNonRoot')
                                    
                                    effective_run_as_non_root = c_run_as_non_root if c_run_as_non_root is not None else p_run_as_non_root
                                    
                                    if effective_run_as_non_root is not True:
                                        violation = f"{source}: El contenedor '{c_name}' no tiene runAsNonRoot = true"
                                        violations.append(violation)
                                        manifest_stats[file_path].append(violation)

                except Exception as e:
                    violation = f"{file_path}: Error parsing YAML - {str(e)}"
                    violations.append(violation)
                    manifest_stats[file_path].append(violation)

    return violations, manifest_stats

def main():
    dirs_to_check = ['k8s', 'sample-manifests']
    all_violations = []
    all_manifest_stats = {}
    
    for d in dirs_to_check:
        if os.path.exists(d):
            violations, manifest_stats = check_policies(d)
            all_violations.extend(violations)
            all_manifest_stats.update(manifest_stats)
    
    # Calcular estadisticas de manifest
    total_manifests = len(all_manifest_stats)
    manifests_passed = sum(1 for v in all_manifest_stats.values() if len(v) == 0)
    manifests_failed = total_manifests - manifests_passed
    
    # Construir violaciones por archivo
    violations_by_file = {}
    for file_path, file_violations in all_manifest_stats.items():
        if len(file_violations) > 0:
            violations_by_file[file_path] = file_violations
            
    report = {
        "pass": len(all_violations) == 0,
        "total_manifests": total_manifests,
        "manifests_passed": manifests_passed,
        "manifests_failed": manifests_failed,
        "total_violations": len(all_violations),
        "violations": all_violations,
        "violations_by_file": violations_by_file
    }
    
    with open('report.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    # Resumen
    print(f"Resumen de politicas:")
    print(f"Total de manifest analizados: {total_manifests}")
    print(f"Manifests Aprobados: {manifests_passed}")
    print(f"Manifests Fallidos: {manifests_failed}")
    print(f"Total de Violaciones: {len(all_violations)}")
        
    if not report["pass"]:
        sys.exit(1)
    sys.exit(0)

if __name__ == "__main__":
    main()