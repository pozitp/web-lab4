Write-Host "=== Deployment Status Check ===" -ForegroundColor Cyan

Write-Host "`n1. Pods Status:" -ForegroundColor Yellow
kubectl get pods -n web-lab4

Write-Host "`n2. Rollouts Status:" -ForegroundColor Yellow
kubectl get rollouts -n web-lab4

Write-Host "`n3. Services:" -ForegroundColor Yellow
kubectl get svc -n web-lab4

Write-Host "`n4. Database:" -ForegroundColor Yellow
kubectl get pods -n web-lab4 -l app=postgres

Write-Host "`n=== Access URLs ===" -ForegroundColor Green
Write-Host "Frontend: http://localhost:30000" -ForegroundColor Cyan
Write-Host "Backend API: http://localhost:30080" -ForegroundColor Cyan

Write-Host "`n=== Health Check ===" -ForegroundColor Yellow
$frontendReady = (kubectl get pods -n web-lab4 -l app=web-lab4-frontend --no-headers | Select-String "Running" | Measure-Object).Count
$backendReady = (kubectl get pods -n web-lab4 -l app=web-lab4-backend --no-headers | Select-String "Running" | Measure-Object).Count
$postgresReady = (kubectl get pods -n web-lab4 -l app=postgres --no-headers | Select-String "Running" | Measure-Object).Count

if ($frontendReady -ge 2 -and $backendReady -ge 3 -and $postgresReady -eq 1) {
    Write-Host "✅ All services are running!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services may not be ready" -ForegroundColor Yellow
}

