# GitHub Container Registry Setup

## Quick Setup

### 1. Create GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: `Tekton Pipeline`
4. Scopes: Select `write:packages` and `read:packages`
5. Generate and **copy the token** (you won't see it again!)

### 2. Create Kubernetes Secret

```powershell
kubectl create secret docker-registry ghcr-secret `
  --docker-server=ghcr.io `
  --docker-username=pozitp `
  --docker-password=<YOUR_GITHUB_TOKEN> `
  --docker-email=<YOUR_EMAIL> `
  --namespace=default
```

Replace:
- `<YOUR_GITHUB_TOKEN>` - The token you just created
- `<YOUR_EMAIL>` - Your GitHub email

### 3. Verify Secret

```powershell
kubectl get secret ghcr-secret -n default
```

### 4. Run Pipeline

The pipeline is already configured to use GitHub Container Registry:

```powershell
kubectl apply -f tekton/pipelinerun.yaml
```

### 5. Check Images

After the pipeline completes, your images will be at:
- `ghcr.io/pozitp/web-lab4-backend:latest`
- `ghcr.io/pozitp/web-lab4-frontend:latest`

View them at: https://github.com/pozitp?tab=packages

## Update Rollouts

The rollouts are already configured to pull from GitHub Container Registry. After the pipeline pushes images, update the rollouts:

```powershell
kubectl rollout restart rollout/web-lab4-backend -n web-lab4
kubectl rollout restart rollout/web-lab4-frontend -n web-lab4
```

## Troubleshooting

### If push fails with "unauthorized"

1. Check the secret exists:
   ```powershell
   kubectl get secret ghcr-secret -n default
   ```

2. Verify token has correct permissions (write:packages)

3. Make sure repository has GitHub Packages enabled

### If pull fails with "ImagePullBackOff"

1. Make sure images were pushed successfully
2. Check image name matches: `ghcr.io/pozitp/web-lab4-*:latest`
3. For private repositories, you may need to add imagePullSecrets to the rollout

