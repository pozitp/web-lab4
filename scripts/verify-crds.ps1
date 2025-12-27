$requiredCrds = @(
    "applications.argoproj.io",
    "rollouts.argoproj.io",
    "pipelines.tekton.dev",
    "tasks.tekton.dev",
    "virtualservices.networking.istio.io"
)

Write-Host "Checking required CRDs..." -ForegroundColor Cyan

$missing = $false

foreach ($crd in $requiredCrds) {
    $result = kubectl get crd $crd 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $crd installed" -ForegroundColor Green
    } else {
        Write-Host "✗ $crd MISSING" -ForegroundColor Red
        $missing = $true
    }
}

if ($missing) {
    Write-Host ""
    Write-Host "Some CRDs are missing. Please install them using the steps in GITOPS_README.md" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ""
    Write-Host "All required CRDs are installed!" -ForegroundColor Green
    exit 0
}

