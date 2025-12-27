Write-Host "=== Starting Local Access ===" -ForegroundColor Cyan

$namespace = "web-lab4"

Write-Host "`nChecking services..." -ForegroundColor Yellow
$frontendSvc = kubectl get svc -n $namespace web-lab4-frontend -o jsonpath='{.spec.type}' 2>&1
$backendSvc = kubectl get svc -n $namespace web-lab4-backend -o jsonpath='{.spec.type}' 2>&1

if ($frontendSvc -eq "NodePort") {
    $frontendPort = kubectl get svc -n $namespace web-lab4-frontend -o jsonpath='{.spec.ports[0].nodePort}'
    Write-Host "`nFrontend (NodePort): http://localhost:$frontendPort" -ForegroundColor Green
} else {
    Write-Host "`nFrontend service is not NodePort. Starting port-forward..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward -n $namespace svc/web-lab4-frontend 3000:80"
    Write-Host "Frontend (port-forward): http://localhost:3000" -ForegroundColor Green
}

if ($backendSvc -eq "NodePort") {
    $backendPort = kubectl get svc -n $namespace web-lab4-backend -o jsonpath='{.spec.ports[0].nodePort}'
    Write-Host "Backend (NodePort): http://localhost:$backendPort" -ForegroundColor Green
} else {
    Write-Host "`nBackend service is not NodePort. Starting port-forward..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward -n $namespace svc/web-lab4-backend 8080:8080"
    Write-Host "Backend (port-forward): http://localhost:8080" -ForegroundColor Green
}

Write-Host "`n=== Access URLs ===" -ForegroundColor Cyan
if ($frontendSvc -eq "NodePort") {
    Write-Host "Frontend: http://localhost:$frontendPort" -ForegroundColor Green
} else {
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Green
}

if ($backendSvc -eq "NodePort") {
    Write-Host "Backend: http://localhost:$backendPort" -ForegroundColor Green
} else {
    Write-Host "Backend: http://localhost:8080" -ForegroundColor Green
}

