Write-Host "=== GitHub Container Registry Setup ===" -ForegroundColor Cyan

Write-Host "`n1. Create GitHub Personal Access Token (PAT):" -ForegroundColor Yellow
Write-Host "   - Go to: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "   - Click 'Generate new token (classic)'" -ForegroundColor White
Write-Host "   - Name: 'Tekton Pipeline'" -ForegroundColor White
Write-Host "   - Scopes: Select 'write:packages' and 'read:packages'" -ForegroundColor White
Write-Host "   - Generate and copy the token" -ForegroundColor White

Write-Host "`n2. Create Kubernetes Secret for GitHub Registry:" -ForegroundColor Yellow
Write-Host "   kubectl create secret docker-registry ghcr-secret \" -ForegroundColor White
Write-Host "     --docker-server=ghcr.io \" -ForegroundColor White
Write-Host "     --docker-username=pozitp \" -ForegroundColor White
Write-Host "     --docker-password=<YOUR_GITHUB_TOKEN> \" -ForegroundColor White
Write-Host "     --docker-email=<YOUR_EMAIL> \" -ForegroundColor White
Write-Host "     --namespace=default" -ForegroundColor White

Write-Host "`n3. Update PipelineRun to use the secret:" -ForegroundColor Yellow
Write-Host "   The dockerconfig workspace should reference the secret:" -ForegroundColor White
Write-Host "   workspaces:" -ForegroundColor White
Write-Host "   - name: dockerconfig" -ForegroundColor White
Write-Host "     secret:" -ForegroundColor White
Write-Host "       secretName: ghcr-secret" -ForegroundColor White

Write-Host "`n4. Enable GitHub Packages for your repository:" -ForegroundColor Yellow
Write-Host "   - Go to your repository settings" -ForegroundColor White
Write-Host "   - Under 'Packages', ensure it's enabled" -ForegroundColor White

Write-Host "`n5. After pushing, images will be available at:" -ForegroundColor Green
Write-Host "   - ghcr.io/pozitp/web-lab4-backend:latest" -ForegroundColor Cyan
Write-Host "   - ghcr.io/pozitp/web-lab4-frontend:latest" -ForegroundColor Cyan

Write-Host "`n=== Quick Setup Command ===" -ForegroundColor Cyan
Write-Host "Replace <TOKEN> and <EMAIL> with your values:" -ForegroundColor Yellow
Write-Host @"
kubectl create secret docker-registry ghcr-secret `
  --docker-server=ghcr.io `
  --docker-username=pozitp `
  --docker-password=<YOUR_GITHUB_TOKEN> `
  --docker-email=<YOUR_EMAIL> `
  --namespace=default
"@ -ForegroundColor White

