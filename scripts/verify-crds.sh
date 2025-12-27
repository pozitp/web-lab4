#!/bin/bash

echo "Checking required CRDs..."

REQUIRED_CRDS=(
    "applications.argoproj.io"
    "rollouts.argoproj.io"
    "pipelines.tekton.dev"
    "tasks.tekton.dev"
    "virtualservices.networking.istio.io"
)

MISSING=0

for crd in "${REQUIRED_CRDS[@]}"; do
    if kubectl get crd "$crd" > /dev/null 2>&1; then
        echo "✓ $crd installed"
    else
        echo "✗ $crd MISSING"
        MISSING=1
    fi
done

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "Some CRDs are missing. Please install them using the steps in GITOPS_README.md"
    exit 1
else
    echo ""
    echo "All required CRDs are installed!"
    exit 0
fi

