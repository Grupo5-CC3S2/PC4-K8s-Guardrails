.PHONY: help k8s-apply k8s-clean k8s-smoke k8s-url k8s-policy-check k8s-test-netpol scan build sbom

GIT_SHA := $(shell git rev-parse --short HEAD)
IMAGE_NAME := python-app:$(GIT_SHA)

# Exportar HOME para encontrar configuracion de kubectl
export HOME := /c/Users/User

help: ## Muestra este mensaje de ayuda
	@bash -c "grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = \":.*?## \"}; {printf \"\033[36m%-30s\033[0m %s\n\", $$1, $$2}'"

k8s-apply: ## Aplica todos los recursos de Kubernetes (con metricas de tiempo)
	bash scripts/k8s-apply.sh

k8s-clean: ## Elimina todos los recursos del cluster
	bash scripts/k8s-clean.sh

k8s-url: ## Obtiene la URL externa del servicio (Minikube)
	minikube service python-app -n secure-apps --url

k8s-smoke: ## Ejecuta smoke test de conectividad interna
	bash scripts/k8s-smoke.sh

k8s-policy-check: ## Ejecuta validacion de politicas (con metricas)
	bash scripts/run-policy-checks.sh

k8s-test-netpol: ## Verifica que la NetworkPolicy bloquee trafico no autorizado
	bash scripts/k8s-test-netpol.sh

scan: ## Ejecuta validacion de politicas, smoke test y test de NetworkPolicy
	$(MAKE) k8s-policy-check
	$(MAKE) k8s-test-netpol
	$(MAKE) k8s-smoke

build:
	@echo "Construyendo imagen Docker con tag $(IMAGE_NAME)"
	docker build -t $(IMAGE_NAME) .

sbom:
	@echo "Generando SBOM para $(IMAGE_NAME)"
	syft $(IMAGE_NAME) -o cyclonedx > sbom-$(GIT_SHA).xml