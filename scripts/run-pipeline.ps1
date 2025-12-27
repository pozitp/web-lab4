Write-Host "=== Running Tekton Pipeline ===" -ForegroundColor Cyan

Write-Host "`n1. Checking if secret exists..." -ForegroundColor Yellow
$secret = kubectl get secret ghcr-secret -n default 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Secret 'ghcr-secret' not found!" -ForegroundColor Red
    Write-Host "`nCreate it first:" -ForegroundColor Yellow
    Write-Host "kubectl create secret docker-registry ghcr-secret \" -ForegroundColor White
    Write-Host "  --docker-server=ghcr.io \" -ForegroundColor White
    Write-Host "  --docker-username=pozitp \" -ForegroundColor White
    Write-Host "  --docker-password=<YOUR_TOKEN> \" -ForegroundColor White
    Write-Host "  --docker-email=<YOUR_EMAIL> \" -ForegroundColor White
    Write-Host "  --namespace=default" -ForegroundColor White
    Write-Host "`nSee GITHUB_REGISTRY_SETUP.md for details" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Secret found" -ForegroundColor Green

Write-Host "`n2. Deleting existing PipelineRun (if exists)..." -ForegroundColor Yellow
kubectl delete pipelinerun web-lab4-pipelinerun --ignore-not-found=true

Write-Host "`n3. Creating new PipelineRun..." -ForegroundColor Yellow
kubectl apply -f tekton/pipelinerun.yaml

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PipelineRun created!" -ForegroundColor Green
    Write-Host "`n4. Monitoring pipeline..." -ForegroundColor Yellow
    Write-Host "Watch status with:" -ForegroundColor Cyan
    Write-Host "  kubectl get pipelinerun -w" -ForegroundColor White
    Write-Host "  kubectl get taskruns" -ForegroundColor White
    Write-Host "  kubectl get pods | Select-String 'web-lab4-pipelinerun'" -ForegroundColor White
} else {
    Write-Host "❌ Failed to create PipelineRun" -ForegroundColor Red
    exit 1
}

