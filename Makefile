.PHONY: k8s-apply

# Exportar HOME para que kubectl encuentre la configuración
export HOME := /c/Users/User

k8s-apply:
	bash scripts/k8s-apply.sh