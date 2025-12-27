Write-Host "=== Quick A/B Test ===" -ForegroundColor Cyan

Write-Host "`n1. Feature flag is already created (50/50 split)" -ForegroundColor Green

Write-Host "`n2. Test Users:" -ForegroundColor Yellow
Write-Host "   User A: user_a / test123" -ForegroundColor Cyan
Write-Host "   User B: user_b / test123" -ForegroundColor Yellow
Write-Host "   (Or use: testuser1 / test123 and testuser2 / test123)" -ForegroundColor Gray

Write-Host "`n3. Open browser: http://localhost:30000" -ForegroundColor Cyan

Write-Host "`n4. Test Steps:" -ForegroundColor Yellow
Write-Host "   a) Login with User A → Should see CYAN theme" -ForegroundColor White
Write-Host "      - Cyan box borders" -ForegroundColor Cyan
Write-Host "      - Cyan active buttons" -ForegroundColor Cyan
Write-Host "      - Cyan area shapes" -ForegroundColor Cyan
Write-Host "   b) Logout" -ForegroundColor White
Write-Host "   c) Login with User B → Should see YELLOW theme" -ForegroundColor White
Write-Host "      - Yellow box borders" -ForegroundColor Yellow
Write-Host "      - Yellow active buttons" -ForegroundColor Yellow
Write-Host "      - Yellow area shapes" -ForegroundColor Yellow

Write-Host "`n5. Check Browser Console (F12):" -ForegroundColor Yellow
Write-Host "   - Look for 'Variant: variant-a' or 'Variant: variant-b'" -ForegroundColor White
Write-Host "   - Check Network tab → API requests include 'x-feature-flag' header" -ForegroundColor White

Write-Host "`n6. Visual Differences:" -ForegroundColor Yellow
Write-Host "   Variant A (Cyan):" -ForegroundColor Cyan
Write-Host "   - Boxes have bright cyan borders (#00ffff)" -ForegroundColor Gray
Write-Host "   - Active buttons are cyan with black text" -ForegroundColor Gray
Write-Host "   - Area shapes are cyan" -ForegroundColor Gray
Write-Host "`n   Variant B (Yellow):" -ForegroundColor Yellow
Write-Host "   - Boxes have bright yellow borders (#ffff00)" -ForegroundColor Gray
Write-Host "   - Active buttons are yellow with black text" -ForegroundColor Gray
Write-Host "   - Area shapes are yellow" -ForegroundColor Gray

Write-Host "`n✅ Ready to test! Open http://localhost:30000" -ForegroundColor Green

