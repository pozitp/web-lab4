Write-Host "=== Application Testing Script ===" -ForegroundColor Cyan

$frontendUrl = "http://localhost:30000"
$backendUrl = "http://localhost:30080"
$testUser = "testuser_$(Get-Random)"
$testPass = "testpass123"

Write-Host "`n=== Part 1: Backend API Testing ===" -ForegroundColor Yellow

Write-Host "`n1. Testing Registration..." -ForegroundColor Cyan
$registerBody = @{
    username = $testUser
    password = $testPass
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$backendUrl/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerBody
    Write-Host "✅ Registration successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Testing Login..." -ForegroundColor Cyan
$loginBody = @{
    username = $testUser
    password = $testPass
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$backendUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -SessionVariable session
    Write-Host "✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n3. Testing Session Check..." -ForegroundColor Cyan
try {
    $checkResponse = Invoke-RestMethod -Uri "$backendUrl/api/auth/check" `
        -WebSession $session
    Write-Host "✅ Session valid: $($checkResponse.username)" -ForegroundColor Green
} catch {
    Write-Host "❌ Session check failed" -ForegroundColor Red
}

Write-Host "`n4. Testing Point Submission..." -ForegroundColor Cyan
$pointBody = @{
    x = "-3"
    y = "2.5"
    r = "2"
} | ConvertTo-Json

try {
    $pointResponse = Invoke-RestMethod -Uri "$backendUrl/api/points" `
        -Method POST `
        -ContentType "application/json" `
        -Body $pointBody `
        -WebSession $session
    Write-Host "✅ Point submitted: Hit=$($pointResponse.hit)" -ForegroundColor Green
} catch {
    Write-Host "❌ Point submission failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n5. Testing Points Retrieval..." -ForegroundColor Cyan
try {
    $pointsResponse = Invoke-RestMethod -Uri "$backendUrl/api/points" `
        -WebSession $session
    Write-Host "✅ Retrieved $($pointsResponse.Count) points" -ForegroundColor Green
    if ($pointsResponse.Count -gt 0) {
        Write-Host "   Latest: X=$($pointsResponse[0].x), Y=$($pointsResponse[0].y), R=$($pointsResponse[0].r), Hit=$($pointsResponse[0].hit)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Points retrieval failed" -ForegroundColor Red
}

Write-Host "`n6. Testing Feature Flags..." -ForegroundColor Cyan
try {
    $flagResponse = Invoke-RestMethod -Uri "$backendUrl/api/feature-flags/ui-variant" `
        -Headers @{"x-feature-flag" = "variant-a"} `
        -WebSession $session
    Write-Host "✅ Feature flag retrieved: Variant=$($flagResponse.variant), Enabled=$($flagResponse.enabled)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Feature flag not found (may need to create it first)" -ForegroundColor Yellow
}

Write-Host "`n7. Testing Logout..." -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "$backendUrl/api/auth/logout" `
        -Method POST `
        -WebSession $session | Out-Null
    Write-Host "✅ Logout successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Logout failed" -ForegroundColor Red
}

Write-Host "`n=== Part 2: Kubernetes Deployment Testing ===" -ForegroundColor Yellow

Write-Host "`n1. Checking Pods..." -ForegroundColor Cyan
$pods = kubectl get pods -n web-lab4 --no-headers 2>&1
if ($LASTEXITCODE -eq 0) {
    $runningPods = ($pods | Select-String "Running").Count
    $totalPods = ($pods | Measure-Object -Line).Lines
    Write-Host "✅ Pods: $runningPods/$totalPods running" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to get pods" -ForegroundColor Red
}

Write-Host "`n2. Checking Services..." -ForegroundColor Cyan
$svc = kubectl get svc -n web-lab4 --no-headers 2>&1
if ($LASTEXITCODE -eq 0) {
    $svcCount = ($svc | Measure-Object -Line).Lines
    Write-Host "✅ Services: $svcCount found" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to get services" -ForegroundColor Red
}

Write-Host "`n3. Checking Rollouts..." -ForegroundColor Cyan
$rollouts = kubectl get rollouts -n web-lab4 --no-headers 2>&1
if ($LASTEXITCODE -eq 0) {
    $rolloutCount = ($rollouts | Measure-Object -Line).Lines
    Write-Host "✅ Rollouts: $rolloutCount found" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to get rollouts" -ForegroundColor Red
}

Write-Host "`n=== Part 3: Database Testing ===" -ForegroundColor Yellow

Write-Host "`n1. Checking Database Connection..." -ForegroundColor Cyan
$dbPod = kubectl get pods -n web-lab4 -l app=postgres -o jsonpath='{.items[0].metadata.name}' 2>&1
if ($dbPod -and $LASTEXITCODE -eq 0) {
    Write-Host "✅ Database pod: $dbPod" -ForegroundColor Green
    
    Write-Host "`n2. Checking Users Table..." -ForegroundColor Cyan
    $users = kubectl exec -n web-lab4 $dbPod -- psql -U lab4user -d lab4db -t -c "SELECT COUNT(*) FROM users;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Users in database: $($users.Trim())" -ForegroundColor Green
    }
    
    Write-Host "`n3. Checking Hits Table..." -ForegroundColor Cyan
    $hits = kubectl exec -n web-lab4 $dbPod -- psql -U lab4user -d lab4db -t -c "SELECT COUNT(*) FROM hits;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Hits in database: $($hits.Trim())" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Database pod not found" -ForegroundColor Yellow
}

Write-Host "`n=== Testing Complete ===" -ForegroundColor Cyan
Write-Host "`nManual Testing:" -ForegroundColor Yellow
Write-Host "1. Open browser: $frontendUrl" -ForegroundColor White
Write-Host "2. Test responsive design (Desktop/Tablet/Mobile)" -ForegroundColor White
Write-Host "3. Test canvas interaction" -ForegroundColor White
Write-Host "4. Test feature flags A/B variants" -ForegroundColor White

Write-Host "`n✅ Automated tests completed!" -ForegroundColor Green

