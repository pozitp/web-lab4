Write-Host "=== Build Backend Pod Logs ===" -ForegroundColor Cyan
kubectl logs web-lab4-pipelinerun-build-backend-pod

Write-Host "`n=== Build Frontend Pod Logs ===" -ForegroundColor Cyan
kubectl logs web-lab4-pipelinerun-build-frontend-pod

Write-Host "`n=== Build Backend Pod Description ===" -ForegroundColor Cyan
kubectl describe pod web-lab4-pipelinerun-build-backend-pod | Select-String -Pattern "Status|Reason|Message|Error|Events" -Context 3

Write-Host "`n=== Build Frontend Pod Description ===" -ForegroundColor Cyan
kubectl describe pod web-lab4-pipelinerun-build-frontend-pod | Select-String -Pattern "Status|Reason|Message|Error|Events" -Context 3

