# A/B Testing Guide - How to Test and Change Colors

## Quick Test (Ready Now!)

### Step 1: Open Browser
```
http://localhost:30000
```

### Step 2: Test Variant A (Cyan)
1. **Login with**: `user_a` / `test123`
2. **You should see**:
   - ✅ Cyan box borders (#00ffff)
   - ✅ Cyan active buttons (cyan background, black text)
   - ✅ Cyan area shapes on canvas
   - ✅ Dark cyan box backgrounds

### Step 3: Test Variant B (Yellow)
1. **Logout**
2. **Login with**: `user_b` / `test123`
3. **You should see**:
   - ✅ Yellow box borders (#ffff00)
   - ✅ Yellow active buttons (yellow background, black text)
   - ✅ Yellow area shapes on canvas
   - ✅ Dark yellow box backgrounds

### Step 4: Verify in Browser Console
Press **F12** → **Console** tab:
- Look for: `Variant: variant-a` or `Variant: variant-b`
- Check **Network** tab → API requests include `x-feature-flag` header

## Current Colors

### Variant A (Cyan Theme)
- Box border: `#00ffff` (bright cyan)
- Box background: `#001122` (dark cyan)
- Active choice button: `#00ffff` background, black text
- Area shape: Cyan fill and stroke

### Variant B (Yellow Theme)
- Box border: `#ffff00` (bright yellow)
- Box background: `#221100` (dark yellow)
- Active choice button: `#ffff00` background, black text
- Area shape: Yellow fill and stroke

## How to Change Colors

### Edit CSS File

Edit `frontend/src/assets/app.css` (around line 322):

**To change Variant A to Red:**
```css
[data-variant="variant-a"] .box {
    border-color: #ff0000;  /* Red */
    background: #1a0000;    /* Dark red */
}

[data-variant="variant-a"] .choice.active {
    background: #ff0000;    /* Red button */
    color: #000000;
}

[data-variant="variant-a"] .area-shape {
    fill: rgba(255, 0, 0, 0.2);  /* Red fill */
    stroke: #ff0000;              /* Red stroke */
}
```

**To change Variant B to Green:**
```css
[data-variant="variant-b"] .box {
    border-color: #00ff00;  /* Green */
    background: #001a00;    /* Dark green */
}

[data-variant="variant-b"] .choice.active {
    background: #00ff00;    /* Green button */
    color: #000000;
}

[data-variant="variant-b"] .area-shape {
    fill: rgba(0, 255, 0, 0.2);  /* Green fill */
    stroke: #00ff00;              /* Green stroke */
}
```

### After Changing Colors

1. **Rebuild frontend**:
   ```powershell
   cd frontend
   npm run build
   cd ..
   ```

2. **Rebuild Docker image**:
   ```powershell
   docker build -t ghcr.io/pozitp/web-lab4-frontend:latest -f frontend/Dockerfile frontend/
   ```

3. **Update rollout**:
   ```powershell
   kubectl set image rollout/web-lab4-frontend frontend=ghcr.io/pozitp/web-lab4-frontend:latest -n web-lab4
   ```

4. **Wait for rollout**:
   ```powershell
   kubectl rollout status rollout/web-lab4-frontend -n web-lab4
   ```

5. **Refresh browser** (Ctrl+F5)

## Change Variant Percentages

### Make Variant A More Common (80% A, 20% B)

```powershell
$body = @{
    enabled = $true
    variantAPercentage = 80
    variantBPercentage = 20
} | ConvertTo-Json

# First login to get session
$login = @{
    username = "testuser"
    password = "testpass123"
} | ConvertTo-Json

$session = $null
Invoke-RestMethod -Uri "http://localhost:30080/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $login `
    -SessionVariable session | Out-Null

# Update feature flag
Invoke-RestMethod -Uri "http://localhost:30080/api/feature-flags/ui-variant" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body `
    -WebSession $session
```

### Make Variant B More Common (20% A, 80% B)

Change to: `variantAPercentage = 20`, `variantBPercentage = 80`

## Verify Variant Assignment

### Check Database

```powershell
kubectl exec -it -n web-lab4 deployment/postgres -- psql -U lab4user -d lab4db -c "SELECT * FROM feature_flags WHERE name='ui-variant';"
```

### Test Multiple Users

Different users get different variants based on username hash:
- Same user always gets same variant (consistent)
- Different users get variants based on percentage split

## Quick Test Script

```powershell
.\scripts\quick-test-ab.ps1
```

This shows you:
- Test users
- What colors to expect
- How to verify

## Troubleshooting

### Colors Not Changing?

1. **Hard refresh browser**: Ctrl+F5
2. **Check browser console** for variant value
3. **Inspect element** → Check if `<html>` has `data-variant` attribute
4. **Verify feature flag is enabled** in database

### Variant Not Assigned?

- Make sure feature flag is enabled
- Check user is logged in
- Verify API endpoint returns variant
