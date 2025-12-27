Write-Host "=== Setting up web-lab4 namespace ===" -ForegroundColor Cyan

$namespace = "web-lab4"

Write-Host "`n1. Creating namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

Write-Host "`n2. Applying all Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f k8s/

Write-Host "`n3. Checking deployed resources..." -ForegroundColor Yellow
kubectl get all -n $namespace

Write-Host "`n4. Checking services..." -ForegroundColor Yellow
kubectl get svc -n $namespace

Write-Host "`n5. Checking rollouts..." -ForegroundColor Yellow
kubectl get rollouts -n $namespace

Write-Host "`n=== Setup complete! ===" -ForegroundColor Green
Write-Host "`nTo access locally:" -ForegroundColor Cyan
Write-Host "  .\scripts\start-local-access.ps1" -ForegroundColor Yellow
Write-Host "  OR" -ForegroundColor Yellow
Write-Host "  .\scripts\port-forward.ps1" -ForegroundColor Yellow

