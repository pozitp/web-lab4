# GitOps Pipeline Setup

This project implements a multi-stage GitOps pipeline using ArgoCD and Tekton with automatic canary deployments and feature flags for A/B testing.

## Architecture

- **Tekton**: CI/CD pipeline automation
- **ArgoCD**: GitOps continuous deployment
- **Argo Rollouts**: Canary deployment strategy
- **Feature Flags**: A/B testing support

## Prerequisites

1. Kubernetes cluster (1.24+)
2. `kubectl` configured to access your cluster
3. `istioctl` (optional, for Istio installation)

## Quick Start

### Automated CRD Installation

**Linux/Mac:**
```bash
chmod +x scripts/install-crds.sh
./scripts/install-crds.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\install-crds.ps1
```

### Verify CRDs

**Linux/Mac:**
```bash
chmod +x scripts/verify-crds.sh
./scripts/verify-crds.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\verify-crds.ps1
```

## Setup

### 0. Verify CRDs Installation

Before applying any manifests, verify that the required CRDs are installed:

```bash
kubectl get crd | grep -E "(tekton|argoproj|istio)"
```

Required CRDs:
- `pipelines.tekton.dev` (Tekton)
- `tasks.tekton.dev` (Tekton)
- `applications.argoproj.io` (ArgoCD)
- `rollouts.argoproj.io` (Argo Rollouts)
- `virtualservices.networking.istio.io` (Istio)

**Note:** This setup uses regular `Task` resources instead of `ClusterTask` for better compatibility.

If CRDs are missing, install them using the steps below.

### 1. Install Tekton (includes CRDs)

```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Wait for CRDs to be ready:
```bash
kubectl wait --for condition=established --timeout=120s crd/pipelines.tekton.dev
kubectl wait --for condition=established --timeout=120s crd/tasks.tekton.dev
```

**Important:** Wait for all Tekton CRDs to be established before creating Tasks. This may take 30-60 seconds.

### 2. Install ArgoCD (includes CRDs)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait for CRD to be ready:
```bash
kubectl wait --for condition=established --timeout=60s crd/applications.argoproj.io
```

### 3. Install Argo Rollouts (includes CRDs)

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

Wait for CRD to be ready:
```bash
kubectl wait --for condition=established --timeout=60s crd/rollouts.argoproj.io
```

### 4. Install Istio (includes CRDs)

```bash
istioctl install --set values.defaultRevision=default
```

Wait for CRD to be ready:
```bash
kubectl wait --for condition=established --timeout=60s crd/virtualservices.networking.istio.io
```

### 5. Verify Tekton is Ready

Before creating Tasks, verify Tekton is fully installed:

```bash
kubectl get crd tasks.tekton.dev
```

If it exists, proceed. If not, wait a bit longer and check again.

### 6. Create Tekton Tasks

```bash
kubectl apply -f tekton/git-clone-task.yaml
kubectl apply -f tekton/buildah-task.yaml
kubectl apply -f tekton/gradle-task.yaml
kubectl apply -f tekton/kubectl-task.yaml
```

### 7. Create Tekton Pipeline

```bash
kubectl apply -f tekton/pipeline.yaml
```

### 8. Create ArgoCD Application

```bash
kubectl apply -f argocd/application.yaml
```

## Pipeline Stages

1. **Clone**: Git repository checkout
2. **Build Backend**: Docker image build for Spring Boot
3. **Build Frontend**: Docker image build for Vue.js
4. **Test Backend**: Run Gradle tests
5. **Push Backend**: Push backend image to registry
6. **Push Frontend**: Push frontend image to registry
7. **Deploy**: Apply Kubernetes manifests

## Canary Deployment

The application uses Argo Rollouts for canary deployments:

- **Step 1**: 10% traffic to canary, pause 30s
- **Step 2**: 25% traffic to canary, pause 30s
- **Step 3**: 50% traffic to canary, pause 30s
- **Step 4**: 100% traffic to canary (promotion)

## Feature Flags

Feature flags are managed via `/api/feature-flags/{flagName}` endpoint.

### Create/Update Feature Flag

```bash
curl -X POST http://localhost:8080/api/feature-flags/ui-variant \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "variantAPercentage": 50,
    "variantBPercentage": 50
  }'
```

### Get User Variant

```bash
curl http://localhost:8080/api/feature-flags/ui-variant
```

## A/B Testing

The frontend automatically loads the user's variant and applies CSS classes:
- `variant-a`: Cyan theme
- `variant-b`: Yellow theme
- `default`: Green theme (original)

Traffic routing is handled by Istio VirtualService based on the `x-feature-flag` header.

## Running Pipeline

### Before Running

1. **Update Git URL**: Edit `tekton/pipelinerun.yaml` and set your actual git repository URL:
   ```yaml
   - name: git-url
     value: https://github.com/YOUR_USERNAME/YOUR_REPO.git
   ```

2. **Create Docker Registry Secret** (if pushing images):
   ```powershell
   kubectl create secret docker-registry docker-registry-secret `
     --docker-server=your-registry.com `
     --docker-username=your-username `
     --docker-password=your-password `
     --docker-email=your-email@example.com
   ```

   Or make it optional by removing the dockerconfig workspace from the pipeline.

3. **Run the Pipeline**:
   ```powershell
   kubectl delete pipelinerun web-lab4-pipelinerun --ignore-not-found=true
   kubectl apply -f tekton/pipelinerun.yaml
   ```
   
   Or use the test script:
   ```powershell
   .\scripts\test-pipeline.ps1
   ```

### Check Pipeline Status

```powershell
kubectl get pipelineruns
kubectl describe pipelinerun web-lab4-pipelinerun
kubectl get taskruns
```

### Check Logs

```powershell
kubectl logs <pod-name>
```

Or use the debug script:
```powershell
.\scripts\check-pipeline-logs.ps1
```

## Troubleshooting

### CRD Not Installed Error

If you see errors like:
```
error: unable to recognize "file.yaml": no matches for kind "Application" in version "argoproj.io/v1alpha1"
```

This means the CRD is not installed. Run:

```bash
kubectl get crd applications.argoproj.io
```

If it doesn't exist, install ArgoCD (step 2 above).

For Rollout CRD:
```bash
kubectl get crd rollouts.argoproj.io
```

If missing, install Argo Rollouts (step 3 above).

For Tekton CRDs:
```bash
kubectl get crd pipelines.tekton.dev tasks.tekton.dev
```

If missing, install Tekton (step 1 above).

### Check All Required CRDs

```bash
kubectl get crd | grep -E "(tekton|argoproj|istio)" | awk '{print $1}'
```

Expected output should include:
- `applications.argoproj.io`
- `rollouts.argoproj.io`
- `pipelines.tekton.dev`
- `tasks.tekton.dev`
- `virtualservices.networking.istio.io`

### Tekton Task Not Found

If you see:
```
error: no matches for kind "Task" in version "tekton.dev/v1beta1"
```

Run the installation script first:
```powershell
.\scripts\install-crds.ps1
```

Or manually install Tekton:
```powershell
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Then wait for the CRD:
```powershell
kubectl wait --for condition=established --timeout=120s crd/tasks.tekton.dev
```

## Monitoring

- Tekton: `kubectl get pipelineruns`
- ArgoCD: Access UI at `http://localhost:8080` (port-forward)
- Rollouts: `kubectl get rollouts -n web-lab4`

## Debugging Pipeline Issues

### Check PipelineRun Status

```powershell
kubectl describe pipelinerun web-lab4-pipelinerun
```

### Check TaskRuns

```powershell
kubectl get taskruns
kubectl describe taskrun <taskrun-name>
```

### Check Pod Logs

```powershell
kubectl get pods | Select-String "web-lab4"
kubectl logs <pod-name>
```

### Check PipelineRun Events

```powershell
kubectl get events --sort-by='.lastTimestamp' | Select-String "web-lab4"
```

### Common Issues

**PipelineRun stuck in "Unknown" or "Running":**
- Check if TaskRuns are created: `kubectl get taskruns`
- Check if pods are running: `kubectl get pods`
- Check for image pull errors or workspace issues

**Rollouts not found:**
- Rollouts are created by the pipeline's deploy step
- Or apply manually: `kubectl apply -f k8s/rollout-backend.yaml -f k8s/rollout-frontend.yaml`
- Ensure namespace exists: `kubectl create namespace web-lab4`

