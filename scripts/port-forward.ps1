$ErrorActionPreference = "Stop"

Write-Host "=== Setting up port-forwarding ===" -ForegroundColor Cyan

$namespace = "web-lab4"

Write-Host "`nChecking if namespace exists..." -ForegroundColor Yellow
$ns = kubectl get namespace $namespace 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Namespace $namespace does not exist. Creating it..." -ForegroundColor Yellow
    kubectl create namespace $namespace
}

Write-Host "`nWaiting for services to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $frontendSvc = kubectl get svc -n $namespace web-lab4-frontend 2>&1
    $backendSvc = kubectl get svc -n $namespace web-lab4-backend 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Services found!" -ForegroundColor Green
        break
    }
    
    $attempt++
    Write-Host "Waiting for services... ($attempt/$maxAttempts)" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

if ($attempt -eq $maxAttempts) {
    Write-Host "Services not found. Make sure the pipeline has deployed them." -ForegroundColor Red
    exit 1
}

Write-Host "`nStarting port-forwarding..." -ForegroundColor Green

$frontendJob = Start-Job -ScriptBlock {
    param($namespace)
    kubectl port-forward -n $namespace svc/web-lab4-frontend 3000:80
} -ArgumentList $namespace

$backendJob = Start-Job -ScriptBlock {
    param($namespace)
    kubectl port-forward -n $namespace svc/web-lab4-backend 8080:8080
} -ArgumentList $namespace

Write-Host "Port-forwarding started in background!" -ForegroundColor Green
Write-Host "`nFrontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:8080" -ForegroundColor Cyan
Write-Host "`nTo stop port-forwarding, run:" -ForegroundColor Yellow
Write-Host "  Stop-Job -Id $($frontendJob.Id), $($backendJob.Id)" -ForegroundColor White
Write-Host "  Remove-Job -Id $($frontendJob.Id), $($backendJob.Id)" -ForegroundColor White
Write-Host "`nOr use: .\scripts\stop-port-forward.ps1" -ForegroundColor Yellow

$frontendJob.Id | Out-File -FilePath ".port-forward-frontend.pid" -Encoding ASCII
$backendJob.Id | Out-File -FilePath ".port-forward-backend.pid" -Encoding ASCII

Write-Host "`nPort-forwarding is running. Press Ctrl+C to stop..." -ForegroundColor Yellow

try {
    while ($true) {
        Start-Sleep -Seconds 1
        if (-not (Get-Job -Id $frontendJob.Id -ErrorAction SilentlyContinue)) {
            Write-Host "Frontend port-forward stopped." -ForegroundColor Yellow
        }
        if (-not (Get-Job -Id $backendJob.Id -ErrorAction SilentlyContinue)) {
            Write-Host "Backend port-forward stopped." -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "`nStopping port-forwarding..." -ForegroundColor Yellow
    Stop-Job -Id $frontendJob.Id, $backendJob.Id -ErrorAction SilentlyContinue
    Remove-Job -Id $frontendJob.Id, $backendJob.Id -ErrorAction SilentlyContinue
    Remove-Item ".port-forward-frontend.pid" -ErrorAction SilentlyContinue
    Remove-Item ".port-forward-backend.pid" -ErrorAction SilentlyContinue
}

