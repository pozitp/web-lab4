# Testing Guide - Lab 4 + Additional Requirements

## Prerequisites

1. **Application is deployed and running**
   ```powershell
   kubectl get pods -n web-lab4
   kubectl get svc -n web-lab4
   ```

2. **Access URLs**
   - Frontend: http://localhost:30000
   - Backend API: http://localhost:30080

## Part 1: Original Lab Requirements Testing

### 1.1 Start Page Testing

#### Test 1.1.1: Header Display
- [ ] Open http://localhost:30000
- [ ] Verify header shows:
  - Student name: "MUKHAMEDIAROV ARTUR ALBERTOVICH"
  - Group: "P3209"
  - Option: "641"

#### Test 1.1.2: Registration
- [ ] Click "Register" or navigate to registration
- [ ] Enter username (e.g., "testuser")
- [ ] Enter password (e.g., "testpass123")
- [ ] Submit registration
- [ ] Verify success message

#### Test 1.1.3: Login
- [ ] Enter registered username
- [ ] Enter password
- [ ] Click "Login"
- [ ] Verify redirect to main page

#### Test 1.1.4: Unauthorized Access Block
- [ ] Logout (if logged in)
- [ ] Try to access main page directly
- [ ] Verify redirect to login page
- [ ] Verify unauthorized users cannot access main page

### 1.2 Main Page Testing

#### Test 1.2.1: Input Fields
- [ ] **X coordinate**: Select from dropdown (-5 to 3)
  - Test: Select "-3"
  - Verify selection is highlighted
  
- [ ] **Y coordinate**: Text input (-5 to 3)
  - Test: Enter "2.5"
  - Test: Enter invalid value (e.g., "abc")
  - Verify validation error appears
  - Test: Enter out of range value (e.g., "10")
  - Verify validation error
  
- [ ] **R coordinate**: Select from dropdown (-5 to 3)
  - Test: Select "2"
  - Verify selection is highlighted

#### Test 1.2.2: Dynamic Canvas Image
- [ ] Verify canvas displays area shape (Option 641):
  - Rectangle in III quadrant: [-R/2, 0] x [-R, 0]
  - Triangle in IV quadrant: (0,0), (R,0), (0,-R/2)
  - Quarter circle in II quadrant: radius R/2
  
- [ ] **Click on canvas**:
  - Click at different coordinates
  - Verify point appears on canvas
  - Verify point color (green for hit, red for miss)
  
- [ ] **Change radius**:
  - Select different R value
  - Verify canvas redraws with new area
  - Verify existing points remain visible

#### Test 1.2.3: Results Table
- [ ] Submit several points (click canvas or use form)
- [ ] Verify table shows:
  - X, Y, R coordinates
  - Hit/Miss result
  - Timestamp
- [ ] Verify table updates with new results

#### Test 1.2.4: Logout
- [ ] Click "Logout" link
- [ ] Verify redirect to start page
- [ ] Verify session is closed

### 1.3 Responsive Design Testing

#### Test 1.3.1: Desktop (>= 1202px)
- [ ] Open browser DevTools
- [ ] Set viewport to 1202px or wider
- [ ] Verify layout is optimized for desktop
- [ ] Verify all elements are visible and properly spaced

#### Test 1.3.2: Tablet (744px - 1201px)
- [ ] Set viewport to 1000px (tablet size)
- [ ] Verify layout adapts for tablet
- [ ] Verify elements are readable and accessible

#### Test 1.3.3: Mobile (< 744px)
- [ ] Set viewport to 600px (mobile size)
- [ ] Verify layout adapts for mobile
- [ ] Verify touch-friendly interface
- [ ] Verify all functionality works on mobile

### 1.4 Database Testing

#### Test 1.4.1: User Storage
```powershell
kubectl exec -it -n web-lab4 deployment/postgres -- psql -U lab4user -d lab4db -c "SELECT username FROM users;"
```
- [ ] Verify registered users are stored
- [ ] Verify passwords are hashed (not plain text)

#### Test 1.4.2: Results Storage
```powershell
kubectl exec -it -n web-lab4 deployment/postgres -- psql -U lab4user -d lab4db -c "SELECT * FROM hits ORDER BY id DESC LIMIT 5;"
```
- [ ] Verify hit results are stored in database
- [ ] Verify coordinates are stored with precision (BigDecimal)

## Part 2: Additional Requirements Testing

### 2.1 GitOps Pipeline Testing

#### Test 2.1.1: Pipeline Execution
```powershell
kubectl get pipelinerun
kubectl get taskruns
```
- [ ] Verify pipeline runs successfully
- [ ] Verify all stages complete:
  - Clone repository
  - Build backend
  - Build frontend
  - Test backend
  - Push images
  - Deploy

#### Test 2.1.2: ArgoCD Sync
```powershell
kubectl get application -n argocd
```
- [ ] Verify ArgoCD application exists
- [ ] Verify sync status is "Synced"
- [ ] Verify auto-sync is enabled

### 2.2 Canary Deployment Testing

#### Test 2.2.1: Rollout Status
```powershell
kubectl get rollouts -n web-lab4
kubectl describe rollout web-lab4-backend -n web-lab4
```
- [ ] Verify rollouts exist for backend and frontend
- [ ] Verify canary strategy is configured
- [ ] Verify traffic splitting (10% → 25% → 50% → 100%)

#### Test 2.2.2: Canary Progression
```powershell
kubectl get pods -n web-lab4 -l app=web-lab4-backend
kubectl get svc -n web-lab4
```
- [ ] Verify canary pods are created
- [ ] Verify stable and canary services exist
- [ ] Monitor rollout progression

#### Test 2.2.3: Istio Traffic Routing
```powershell
kubectl get virtualservice -n web-lab4
kubectl describe virtualservice web-lab4-backend-vs -n web-lab4
```
- [ ] Verify VirtualService exists
- [ ] Verify traffic routing rules
- [ ] Verify feature flag header routing

### 2.3 Feature Flags & A/B Testing

#### Test 2.3.1: Create Feature Flag
```powershell
curl -X POST http://localhost:30080/api/feature-flags/ui-variant `
  -H "Content-Type: application/json" `
  -u testuser:testpass123 `
  -d '{"enabled": true, "variantAPercentage": 50, "variantBPercentage": 50}'
```
- [ ] Verify feature flag is created
- [ ] Verify response contains flag configuration

#### Test 2.3.2: Get User Variant
```powershell
curl http://localhost:30080/api/feature-flags/ui-variant `
  -H "x-feature-flag: variant-a" `
  -u testuser:testpass123
```
- [ ] Verify variant is returned
- [ ] Verify variant assignment is consistent for same user

#### Test 2.3.3: Frontend A/B Testing
- [ ] Open http://localhost:30000
- [ ] Login
- [ ] Check browser console for feature flag variant
- [ ] Verify CSS classes are applied:
  - `variant-a` → Cyan theme
  - `variant-b` → Yellow theme
- [ ] Verify variant persists across page reloads

#### Test 2.3.4: API Request with Feature Flag
- [ ] Open browser DevTools → Network tab
- [ ] Submit a point check
- [ ] Verify request includes `x-feature-flag` header
- [ ] Verify backend receives and processes the header

## Part 3: Integration Testing

### Test 3.1: Complete User Flow
1. [ ] Register new user
2. [ ] Login
3. [ ] Select X, Y, R coordinates
4. [ ] Click on canvas to add point
5. [ ] Verify point appears with correct color
6. [ ] Verify result appears in table
7. [ ] Submit multiple points
8. [ ] Verify all results in table
9. [ ] Logout
10. [ ] Login again
11. [ ] Verify previous results are still visible

### Test 3.2: Error Handling
- [ ] Submit point with invalid Y coordinate
- [ ] Verify error message appears
- [ ] Verify point is not added
- [ ] Try to access API without authentication
- [ ] Verify 401 Unauthorized response

### Test 3.3: Performance
- [ ] Submit 10+ points quickly
- [ ] Verify all are processed
- [ ] Verify table updates correctly
- [ ] Verify no performance degradation

## Quick Test Script

Run this PowerShell script for automated testing:

```powershell
.\scripts\test-application.ps1
```

## Manual Testing Checklist

Print this checklist and test each item:

- [ ] Start page displays correctly
- [ ] Registration works
- [ ] Login works
- [ ] Unauthorized access is blocked
- [ ] X coordinate selection works
- [ ] Y coordinate validation works
- [ ] R coordinate selection works
- [ ] Canvas displays area correctly
- [ ] Canvas click adds point
- [ ] Point colors are correct (hit/miss)
- [ ] Radius change redraws canvas
- [ ] Results table displays correctly
- [ ] Logout works
- [ ] Desktop layout (>= 1202px)
- [ ] Tablet layout (744-1201px)
- [ ] Mobile layout (< 744px)
- [ ] Database stores users
- [ ] Database stores results
- [ ] Pipeline runs successfully
- [ ] Canary deployment works
- [ ] Feature flags work
- [ ] A/B testing applies variants

