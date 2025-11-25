.PHONY: help k8s-apply k8s-clean k8s-smoke k8s-url k8s-policy-check k8stest-netpol

# Exportar HOME para encontrar configuracion de kubectl
export HOME := /c/Users/estcm

help: ## Muestra este mensaje de ayuda
	@bash -c "grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = \":.*?## \"}; {printf \"\033[36m%-30s\033[0m %s\n\", \$$1, \$$2}'"

k8s-apply: ## Aplica todos los recursos de Kubernetes
	bash scripts/k8s-apply.sh

k8s-clean: ## Elimina todos los recursos del cluster
	bash scripts/k8s-clean.sh

k8s-smoke: ## Ejecuta smoke test de conectividad interna
	bash scripts/k8s-smoke.sh

k8s-url: ## Obtiene la URL externa del servicio (Minikube)
	minikube service python-app -n secure-apps --url

k8s-policy-check: ## Ejecuta validacion de politicas sobre manifiestos
	bash scripts/run-policy-checks.sh

k8s-test-netpol: ## Verifica que la NetworkPolicy bloquee trafico no autorizado
	bash scripts/k8s-test-netpol.sh