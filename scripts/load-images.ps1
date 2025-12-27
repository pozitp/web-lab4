Write-Host "=== Loading Images for Local Testing ===" -ForegroundColor Cyan

Write-Host "`nNote: Images need to be loaded into your local Docker daemon." -ForegroundColor Yellow
Write-Host "The pipeline builds images using Buildah, which stores them separately." -ForegroundColor Yellow

Write-Host "`nOption 1: Build images locally" -ForegroundColor Green
Write-Host "  cd ." -ForegroundColor White
Write-Host "  docker build -t registry.example.com/web-lab4-backend:latest -f Dockerfile ." -ForegroundColor White
Write-Host "  cd frontend" -ForegroundColor White
Write-Host "  docker build -t registry.example.com/web-lab4-frontend:latest -f Dockerfile ." -ForegroundColor White

Write-Host "`nOption 2: Use images from Buildah (if available)" -ForegroundColor Green
Write-Host "  Buildah images are stored separately from Docker." -ForegroundColor Yellow
Write-Host "  You may need to export/import them or rebuild with Docker." -ForegroundColor Yellow

Write-Host "`nOption 3: Update rollout files to use local images" -ForegroundColor Green
Write-Host "  Change imagePullPolicy to 'Never' and use local image names" -ForegroundColor Yellow

Write-Host "`nAfter loading images, apply the updated rollouts:" -ForegroundColor Cyan
Write-Host "  kubectl apply -f k8s/rollout-backend.yaml" -ForegroundColor White
Write-Host "  kubectl apply -f k8s/rollout-frontend.yaml" -ForegroundColor White

