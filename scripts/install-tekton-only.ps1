$ErrorActionPreference = "Stop"

Write-Host "Installing Tekton Pipelines..." -ForegroundColor Cyan
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

Write-Host "Waiting for Tekton CRDs to be established (this may take 30-60 seconds)..." -ForegroundColor Yellow

$maxAttempts = 12
$attempt = 0
$allReady = $false

while ($attempt -lt $maxAttempts -and -not $allReady) {
    Start-Sleep -Seconds 5
    $attempt++
    
    $pipelines = kubectl get crd pipelines.tekton.dev 2>&1
    $tasks = kubectl get crd tasks.tekton.dev 2>&1
    $clustertasks = kubectl get crd clustertasks.tekton.dev 2>&1
    
    if ($LASTEXITCODE -eq 0 -and $pipelines -and $tasks -and $clustertasks) {
        Write-Host "All Tekton CRDs are ready!" -ForegroundColor Green
        $allReady = $true
    } else {
        Write-Host "Waiting... (attempt $attempt/$maxAttempts)" -ForegroundColor Yellow
    }
}

if (-not $allReady) {
    Write-Host "Warning: Some CRDs may not be ready yet. Check with:" -ForegroundColor Yellow
    Write-Host "  kubectl get crd | grep tekton" -ForegroundColor Cyan
} else {
    Write-Host "Tekton installation complete! You can now create ClusterTasks." -ForegroundColor Green
}

