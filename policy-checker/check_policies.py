import os
import sys
import yaml
import json

def check_policies(directory):
    violations = []
    
    # Recorrer directorios recursivamente
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith((".yaml", ".yml")):
                file_path = os.path.join(root, file)
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
                                            violations.append(f"{source}: Container '{c_name}' image '{c_image}' has no tag")
                                        elif c_image.endswith(':latest'):
                                            violations.append(f"{source}: Container '{c_name}' uses image '{c_image}' with latest tag")

                                    # 2. Resource Limits
                                    resources = container.get('resources', {})
                                    if not resources.get('limits'):
                                        violations.append(f"{source}: Container '{c_name}' missing resources.limits")

                                    # 3. allowPrivilegeEscalation = false (nivel de contenedor)
                                    if c_sec_ctx.get('allowPrivilegeEscalation') is not False:
                                        violations.append(f"{source}: Container '{c_name}' allowPrivilegeEscalation is not set to false")

                                    # 4. runAsNonRoot = true (nivel de Pod o contenedor)
                                    # Valor efectivo: valor del contenedor sobreescribe al del pod
                                    c_run_as_non_root = c_sec_ctx.get('runAsNonRoot')
                                    p_run_as_non_root = pod_sec_ctx.get('runAsNonRoot')
                                    
                                    effective_run_as_non_root = c_run_as_non_root if c_run_as_non_root is not None else p_run_as_non_root
                                    
                                    if effective_run_as_non_root is not True:
                                        violations.append(f"{source}: Container '{c_name}' runAsNonRoot is not set to true")

                except Exception as e:
                    violations.append(f"{file_path}: Error parsing YAML - {str(e)}")

    return violations

def main():
    dirs_to_check = ['k8s', 'sample-manifests']
    all_violations = []
    
    for d in dirs_to_check:
        if os.path.exists(d):
            all_violations.extend(check_policies(d))
            
    report = {
        "pass": len(all_violations) == 0,
        "violations": all_violations
    }
    
    with open('report.json', 'w') as f:
        json.dump(report, f, indent=2)
        
    if not report["pass"]:
        sys.exit(1)
    sys.exit(0)

if __name__ == "__main__":
    main()
