Write-Host "=== Stopping port-forwarding ===" -ForegroundColor Cyan

if (Test-Path ".port-forward-frontend.pid") {
    $frontendId = Get-Content ".port-forward-frontend.pid"
    Write-Host "Stopping frontend port-forward (Job ID: $frontendId)..." -ForegroundColor Yellow
    Stop-Job -Id $frontendId -ErrorAction SilentlyContinue
    Remove-Job -Id $frontendId -ErrorAction SilentlyContinue
    Remove-Item ".port-forward-frontend.pid" -ErrorAction SilentlyContinue
}

if (Test-Path ".port-forward-backend.pid") {
    $backendId = Get-Content ".port-forward-backend.pid"
    Write-Host "Stopping backend port-forward (Job ID: $backendId)..." -ForegroundColor Yellow
    Stop-Job -Id $backendId -ErrorAction SilentlyContinue
    Remove-Job -Id $backendId -ErrorAction SilentlyContinue
    Remove-Item ".port-forward-backend.pid" -ErrorAction SilentlyContinue
}

$runningJobs = Get-Job | Where-Object { $_.Command -like "*port-forward*" }
if ($runningJobs) {
    Write-Host "Stopping remaining port-forward jobs..." -ForegroundColor Yellow
    Stop-Job $runningJobs -ErrorAction SilentlyContinue
    Remove-Job $runningJobs -ErrorAction SilentlyContinue
}

Write-Host "Port-forwarding stopped!" -ForegroundColor Green

