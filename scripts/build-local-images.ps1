Write-Host "=== Building Images Locally ===" -ForegroundColor Cyan

$registry = "ghcr.io/pozitp"
$tag = "latest"

Write-Host "`n1. Building backend image..." -ForegroundColor Yellow
docker build -t "$registry/web-lab4-backend:$tag" -f Dockerfile .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Backend build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Building frontend image..." -ForegroundColor Yellow
docker build -t "$registry/web-lab4-frontend:$tag" -f frontend/Dockerfile frontend/

if ($LASTEXITCODE -ne 0) {
    Write-Host "Frontend build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n3. Verifying images..." -ForegroundColor Yellow
docker images | Select-String "web-lab4"

Write-Host "`n=== Images built successfully! ===" -ForegroundColor Green
Write-Host "`nNow apply the rollouts:" -ForegroundColor Cyan
Write-Host "  kubectl apply -f k8s/rollout-backend.yaml" -ForegroundColor White
Write-Host "  kubectl apply -f k8s/rollout-frontend.yaml" -ForegroundColor White

