Write-Host "=== PipelineRun Status ===" -ForegroundColor Cyan
kubectl get pipelinerun

Write-Host "`n=== TaskRuns ===" -ForegroundColor Cyan
kubectl get taskruns

Write-Host "`n=== Pods ===" -ForegroundColor Cyan
kubectl get pods | Select-String "web-lab4"

Write-Host "`n=== Recent PipelineRun Events ===" -ForegroundColor Cyan
kubectl describe pipelinerun web-lab4-pipelinerun | Select-String -Pattern "Reason|Message|Status" -Context 1

