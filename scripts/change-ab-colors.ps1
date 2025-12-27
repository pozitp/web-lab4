Write-Host "=== Change A/B Test Colors ===" -ForegroundColor Cyan

Write-Host "`nCurrent colors:" -ForegroundColor Yellow
Write-Host "Variant A: Cyan (#00ffff)" -ForegroundColor Cyan
Write-Host "Variant B: Yellow (#ffff00)" -ForegroundColor Yellow

Write-Host "`nTo change colors, edit: frontend/src/assets/app.css" -ForegroundColor Cyan
Write-Host "`nLook for these sections:" -ForegroundColor Yellow
Write-Host "[data-variant='variant-a'] .box" -ForegroundColor White
Write-Host "[data-variant='variant-b'] .box" -ForegroundColor White

Write-Host "`nExample - Change Variant A to Red:" -ForegroundColor Cyan
Write-Host @"
[data-variant='variant-a'] .box {
    border-color: #ff0000;
    background: #1a0000;
}
[data-variant='variant-a'] .choice.active {
    background: #ff0000;
    color: #000000;
}
"@ -ForegroundColor Gray

Write-Host "`nExample - Change Variant B to Green:" -ForegroundColor Cyan
Write-Host @"
[data-variant='variant-b'] .box {
    border-color: #00ff00;
    background: #001a00;
}
[data-variant='variant-b'] .choice.active {
    background: #00ff00;
    color: #000000;
}
"@ -ForegroundColor Gray

Write-Host "`nAfter changing CSS:" -ForegroundColor Yellow
Write-Host "1. Rebuild frontend: cd frontend && npm run build" -ForegroundColor White
Write-Host "2. Rebuild Docker image: .\scripts\build-local-images.ps1" -ForegroundColor White
Write-Host "3. Restart rollout: kubectl rollout restart rollout/web-lab4-frontend -n web-lab4" -ForegroundColor White

