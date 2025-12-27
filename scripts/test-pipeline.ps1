Write-Host "=== Cleaning up previous PipelineRun ===" -ForegroundColor Yellow
kubectl delete pipelinerun web-lab4-pipelinerun --ignore-not-found=true

Write-Host "`n=== Waiting for cleanup ===" -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host "`n=== Applying PipelineRun ===" -ForegroundColor Cyan
kubectl apply -f tekton/pipelinerun.yaml

Write-Host "`n=== Monitoring PipelineRun ===" -ForegroundColor Cyan
Write-Host "Watch status with: kubectl get pipelinerun -w" -ForegroundColor Yellow
Write-Host "Or check details: kubectl describe pipelinerun web-lab4-pipelinerun" -ForegroundColor Yellow

Write-Host "`n=== Current Status ===" -ForegroundColor Cyan
kubectl get pipelinerun web-lab4-pipelinerun

Write-Host "`n=== TaskRuns ===" -ForegroundColor Cyan
kubectl get taskruns


