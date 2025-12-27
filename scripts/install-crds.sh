#!/bin/bash

set -e

echo "Installing Tekton CRDs..."
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
echo "Waiting for Tekton CRDs to be established..."
sleep 10
kubectl wait --for condition=established --timeout=120s crd/pipelines.tekton.dev || true
kubectl wait --for condition=established --timeout=120s crd/tasks.tekton.dev || true
echo "Tekton CRDs installed successfully!"

echo "Installing ArgoCD CRDs..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for condition=established --timeout=60s crd/applications.argoproj.io || true

echo "Installing Argo Rollouts CRDs..."
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl wait --for condition=established --timeout=60s crd/rollouts.argoproj.io || true

echo "Installing Istio CRDs..."
if command -v istioctl &> /dev/null; then
    istioctl install --set values.defaultRevision=default -y
    kubectl wait --for condition=established --timeout=60s crd/virtualservices.networking.istio.io || true
else
    echo "Warning: istioctl not found. Install Istio manually."
fi

echo "CRD installation complete!"
echo "Run scripts/verify-crds.sh to verify all CRDs are installed."

