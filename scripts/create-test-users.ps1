Write-Host "=== Creating Test Users for A/B Testing ===" -ForegroundColor Cyan

$backendUrl = "http://localhost:30080"

$users = @(
    @{username = "user_a"; password = "test123"},
    @{username = "user_b"; password = "test123"},
    @{username = "testuser1"; password = "test123"},
    @{username = "testuser2"; password = "test123"}
)

Write-Host "`nCreating test users..." -ForegroundColor Yellow

foreach ($user in $users) {
    try {
        $body = @{
            username = $user.username
            password = $user.password
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$backendUrl/api/auth/register" `
            -Method POST `
            -ContentType "application/json" `
            -Body $body
        
        Write-Host "✅ Created: $($user.username) / $($user.password)" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 409 -or $_.Exception.Message -like "*already exists*") {
            Write-Host "⚠️  User $($user.username) already exists" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Failed to create $($user.username): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== Test Users Ready ===" -ForegroundColor Green
Write-Host "User A: user_a / test123" -ForegroundColor Cyan
Write-Host "User B: user_b / test123" -ForegroundColor Yellow
Write-Host "User 1: testuser1 / test123" -ForegroundColor White
Write-Host "User 2: testuser2 / test123" -ForegroundColor White

Write-Host "`nNow test A/B:" -ForegroundColor Yellow
Write-Host "1. Login with user_a → Should get variant-a (Cyan)" -ForegroundColor Cyan
Write-Host "2. Logout" -ForegroundColor White
Write-Host "3. Login with user_b → Should get variant-b (Yellow)" -ForegroundColor Yellow

