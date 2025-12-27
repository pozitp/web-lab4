$pipelineRunName = "web-lab4-pipelinerun"

Write-Host "=== PipelineRun Status ===" -ForegroundColor Cyan
kubectl get pipelinerun $pipelineRunName

Write-Host "`n=== PipelineRun Details ===" -ForegroundColor Cyan
kubectl describe pipelinerun $pipelineRunName

Write-Host "`n=== TaskRuns ===" -ForegroundColor Cyan
kubectl get taskruns

Write-Host "`n=== Pods ===" -ForegroundColor Cyan
kubectl get pods | Select-String "web-lab4|tekton"

Write-Host "`n=== Recent Events ===" -ForegroundColor Cyan
kubectl get events --sort-by='.lastTimestamp' --field-selector involvedObject.name=$pipelineRunName | Select-Object -Last 10

