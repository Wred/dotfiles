#!/usr/bin/env bash

# Use all configs in Kubernetes config folder, only if KUBECONFIG is not already set
if [ -z "${KUBECONFIG}" ] && [ -d "${HOME}/.kube" ]; then
	export KUBECONFIG=$(ls ~/.kube/*config | paste -sd ":" -)
fi
