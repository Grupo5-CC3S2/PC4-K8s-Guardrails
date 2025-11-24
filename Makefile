.PHONY: k8s-apply k8s-clean k8s-smoke

# Exportar HOME para que kubectl encuentre la configuración
export HOME := /c/Users/estcm

.PHONY: k8s-apply k8s-clean k8s-smoke

k8s-apply:
	bash scripts/k8s-apply.sh

k8s-clean:
	bash scripts/k8s-clean.sh

k8s-smoke:
	bash scripts/k8s-smoke.sh

k8s-url:
	minikube service python-app -n secure-apps --url