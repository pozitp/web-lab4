Write-Host "=== A/B Testing Color Test ===" -ForegroundColor Cyan

$backendUrl = "http://localhost:30080"
$testUser1 = "user_a_$(Get-Random)"
$testUser2 = "user_b_$(Get-Random)"
$testPass = "testpass123"

Write-Host "`n=== Step 1: Create Feature Flag ===" -ForegroundColor Yellow

$flagBody = @{
    enabled = $true
    variantAPercentage = 50
    variantBPercentage = 50
} | ConvertTo-Json

Write-Host "Creating feature flag 'ui-variant' with 50/50 split..." -ForegroundColor Cyan

try {
    $cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$testUser1`:$testPass"))
    
    $register1 = @{
        username = $testUser1
        password = $testPass
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$backendUrl/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $register1 | Out-Null
    
    $login1 = @{
        username = $testUser1
        password = $testPass
    } | ConvertTo-Json
    
    $loginResponse1 = Invoke-RestMethod -Uri "$backendUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $login1 `
        -SessionVariable session1
    
    $flagResponse = Invoke-RestMethod -Uri "$backendUrl/api/feature-flags/ui-variant" `
        -Method POST `
        -ContentType "application/json" `
        -Body $flagBody `
        -WebSession $session1
    
    Write-Host "✅ Feature flag created!" -ForegroundColor Green
    Write-Host "   Enabled: $($flagResponse.enabled)" -ForegroundColor Gray
    Write-Host "   Variant A: $($flagResponse.variantAPercentage)%" -ForegroundColor Gray
    Write-Host "   Variant B: $($flagResponse.variantBPercentage)%" -ForegroundColor Gray
} catch {
    Write-Host "⚠️  Feature flag may already exist, trying to update..." -ForegroundColor Yellow
    try {
        $flagResponse = Invoke-RestMethod -Uri "$backendUrl/api/feature-flags/ui-variant" `
            -Method POST `
            -ContentType "application/json" `
            -Body $flagBody `
            -WebSession $session1
        Write-Host "✅ Feature flag updated!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n=== Step 2: Test Variant Assignment ===" -ForegroundColor Yellow

Write-Host "`nTesting User 1: $testUser1" -ForegroundColor Cyan
$variant1 = Invoke-RestMethod -Uri "$backendUrl/api/feature-flags/ui-variant" `
    -Headers @{"x-feature-flag" = "variant-a"} `
    -WebSession $session1
Write-Host "   Variant: $($variant1.variant)" -ForegroundColor $(if ($variant1.variant -eq "variant-a") { "Cyan" } elseif ($variant1.variant -eq "variant-b") { "Yellow" } else { "White" })

Write-Host "`nTesting User 2: $testUser2" -ForegroundColor Cyan
$register2 = @{
    username = $testUser2
    password = $testPass
} | ConvertTo-Json

Invoke-RestMethod -Uri "$backendUrl/api/auth/register" `
    -Method POST `
    -ContentType "application/json" `
    -Body $register2 | Out-Null

$login2 = @{
    username = $testUser2
    password = $testPass
} | ConvertTo-Json

$loginResponse2 = Invoke-RestMethod -Uri "$backendUrl/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $login2 `
    -SessionVariable session2

$variant2 = Invoke-RestMethod -Uri "$backendUrl/api/feature-flags/ui-variant" `
    -Headers @{"x-feature-flag" = "variant-b"} `
    -WebSession $session2
Write-Host "   Variant: $($variant2.variant)" -ForegroundColor $(if ($variant2.variant -eq "variant-a") { "Cyan" } elseif ($variant2.variant -eq "variant-b") { "Yellow" } else { "White" })

Write-Host "`n=== Step 3: Manual Testing Instructions ===" -ForegroundColor Yellow
Write-Host "`n1. Open browser: http://localhost:30000" -ForegroundColor Cyan
Write-Host "2. Login with user: $testUser1" -ForegroundColor White
Write-Host "   Password: $testPass" -ForegroundColor White
Write-Host "3. Check browser console (F12) for variant" -ForegroundColor White
Write-Host "4. Check page colors:" -ForegroundColor White
Write-Host "   - Variant A: Cyan borders/backgrounds" -ForegroundColor Cyan
Write-Host "   - Variant B: Yellow borders/backgrounds" -ForegroundColor Yellow
Write-Host "5. Logout and login with: $testUser2" -ForegroundColor White
Write-Host "6. Compare colors - should be different variant!" -ForegroundColor White

Write-Host "`n=== Current CSS Colors ===" -ForegroundColor Yellow
Write-Host "Variant A (Cyan):" -ForegroundColor Cyan
Write-Host "  - Box border: #00ffff" -ForegroundColor Gray
Write-Host "  - Active choice: #00ffff background" -ForegroundColor Gray
Write-Host "`nVariant B (Yellow):" -ForegroundColor Yellow
Write-Host "  - Box border: #ffff00" -ForegroundColor Gray
Write-Host "  - Active choice: #ffff00 background" -ForegroundColor Gray
Write-Host "  - Area shape: #ffff00" -ForegroundColor Gray

Write-Host "`n✅ Setup complete! Test in browser now." -ForegroundColor Green

