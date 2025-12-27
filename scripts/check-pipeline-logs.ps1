$taskRunName = "web-lab4-pipelinerun-clone-repo"

Write-Host "=== TaskRun Status ===" -ForegroundColor Cyan
kubectl get taskrun $taskRunName

Write-Host "`n=== TaskRun Details ===" -ForegroundColor Cyan
kubectl describe taskrun $taskRunName

Write-Host "`n=== Finding Pod ===" -ForegroundColor Cyan
$podName = kubectl get pods -l tekton.dev/taskRun=$taskRunName -o jsonpath='{.items[0].metadata.name}' 2>$null
if ($podName) {
    Write-Host "Pod: $podName" -ForegroundColor Green
    Write-Host "`n=== Pod Logs ===" -ForegroundColor Cyan
    kubectl logs $podName
    Write-Host "`n=== Pod Description ===" -ForegroundColor Cyan
    kubectl describe pod $podName
} else {
    Write-Host "No pod found for TaskRun" -ForegroundColor Yellow
    Write-Host "Trying to find any pods with 'clone' in name..." -ForegroundColor Yellow
    kubectl get pods | Select-String "clone"
}

