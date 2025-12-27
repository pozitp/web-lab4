$ErrorActionPreference = "Stop"

Write-Host "Installing Tekton CRDs..." -ForegroundColor Cyan
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
Write-Host "Waiting for Tekton CRDs to be established..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
kubectl wait --for condition=established --timeout=120s crd/pipelines.tekton.dev 2>&1 | Out-Null
kubectl wait --for condition=established --timeout=120s crd/tasks.tekton.dev 2>&1 | Out-Null
Write-Host "Tekton CRDs installed successfully!" -ForegroundColor Green

Write-Host "Installing ArgoCD CRDs..." -ForegroundColor Cyan
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
Start-Sleep -Seconds 5
kubectl wait --for condition=established --timeout=60s crd/applications.argoproj.io 2>&1 | Out-Null

Write-Host "Installing Argo Rollouts CRDs..." -ForegroundColor Cyan
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
Start-Sleep -Seconds 5
kubectl wait --for condition=established --timeout=60s crd/rollouts.argoproj.io 2>&1 | Out-Null

Write-Host "Installing Istio CRDs..." -ForegroundColor Cyan
if (Get-Command istioctl -ErrorAction SilentlyContinue) {
    istioctl install --set values.defaultRevision=default -y
    Start-Sleep -Seconds 5
    kubectl wait --for condition=established --timeout=60s crd/virtualservices.networking.istio.io 2>&1 | Out-Null
} else {
    Write-Host "Warning: istioctl not found. Install Istio manually." -ForegroundColor Yellow
}

Write-Host "CRD installation complete!" -ForegroundColor Green
Write-Host "Run scripts/verify-crds.ps1 to verify all CRDs are installed." -ForegroundColor Cyan

