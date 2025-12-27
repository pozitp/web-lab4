Write-Host "=== Pipeline Status ===" -ForegroundColor Cyan
kubectl get pipelinerun

Write-Host "`n=== TaskRuns ===" -ForegroundColor Cyan
kubectl get taskruns

Write-Host "`n=== Deployed Resources in web-lab4 namespace ===" -ForegroundColor Cyan
kubectl get all -n web-lab4

Write-Host "`n=== Services ===" -ForegroundColor Cyan
kubectl get svc -n web-lab4

Write-Host "`n=== Deployments ===" -ForegroundColor Cyan
kubectl get deployments -n web-lab4

Write-Host "`n=== Pods ===" -ForegroundColor Cyan
kubectl get pods -n web-lab4

Write-Host "`n=== To access locally, use port-forward:" -ForegroundColor Yellow
Write-Host "Frontend: kubectl port-forward -n web-lab4 svc/web-lab4-frontend 3000:80" -ForegroundColor Green
Write-Host "Backend: kubectl port-forward -n web-lab4 svc/web-lab4-backend 8080:8080" -ForegroundColor Green

