Write-Host "=== Quick Debug Info ===" -ForegroundColor Cyan

Write-Host "`n1. TaskRun Status:" -ForegroundColor Yellow
kubectl get taskrun web-lab4-pipelinerun-clone-repo

Write-Host "`n2. Pods:" -ForegroundColor Yellow
kubectl get pods | Select-String "clone"

Write-Host "`n3. Getting pod name and logs..." -ForegroundColor Yellow
$pods = kubectl get pods -o json | ConvertFrom-Json
$clonePod = $pods.items | Where-Object { $_.metadata.name -like "*clone*" } | Select-Object -First 1

if ($clonePod) {
    $podName = $clonePod.metadata.name
    Write-Host "Pod found: $podName" -ForegroundColor Green
    Write-Host "`n=== LOGS ===" -ForegroundColor Cyan
    kubectl logs $podName
    Write-Host "`n=== POD STATUS ===" -ForegroundColor Cyan
    kubectl describe pod $podName | Select-String -Pattern "Status|Reason|Message|Error" -Context 2
} else {
    Write-Host "No clone pod found. Checking all pods:" -ForegroundColor Yellow
    kubectl get pods
}

