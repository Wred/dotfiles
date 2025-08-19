#!/usr/bin/env bash

# Use all configs in Kubernetes config folder
if [ -d "${HOME}/.kube" ]; then
	export KUBECONFIG=$(ls ~/.kube/*config | paste -sd ":" -)
fi
