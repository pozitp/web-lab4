Write-Host "=== Check Deployment Status ===" -ForegroundColor Cyan
Write-Host "`n1. Pipeline Status:" -ForegroundColor Yellow
kubectl get pipelinerun

Write-Host "`n2. All Resources in web-lab4 namespace:" -ForegroundColor Yellow
kubectl get all -n web-lab4

Write-Host "`n3. Deployments:" -ForegroundColor Yellow
kubectl get deployments -n web-lab4

Write-Host "`n4. Rollouts (Argo Rollouts):" -ForegroundColor Yellow
kubectl get rollouts -n web-lab4

Write-Host "`n5. Services:" -ForegroundColor Yellow
kubectl get svc -n web-lab4

Write-Host "`n6. Pods:" -ForegroundColor Yellow
kubectl get pods -n web-lab4

Write-Host "`n=== To Access Locally ===" -ForegroundColor Cyan
Write-Host "`nFrontend (port 3000):" -ForegroundColor Green
Write-Host "kubectl port-forward -n web-lab4 svc/web-lab4-frontend 3000:80" -ForegroundColor White

Write-Host "`nBackend (port 8080):" -ForegroundColor Green
Write-Host "kubectl port-forward -n web-lab4 svc/web-lab4-backend 8080:8080" -ForegroundColor White

Write-Host "`nThen open: http://localhost:3000" -ForegroundColor Yellow

