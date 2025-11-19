# Polyfea Controller Helm Chart

A Helm chart for deploying the Polyfea microfrontend controller and its Custom Resource Definitions (CRDs).

## Installation

### From Helm Repository

Add the Polyfea Helm repository:

```bash
helm repo add polyfea https://polyfea.github.io/charts
helm repo update
```

Install the controller:

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace
```

### From Source

```bash
git clone https://github.com/polyfea/charts.git
cd charts
helm install polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace
```

## What This Chart Deploys

### Core Components
* **Deployment** - Polyfea controller manager with configurable replicas
* **Service Account** - Dedicated service account with optional custom name
* **ClusterRole** - Manager role with permissions for Polyfea CRDs and core resources
* **ClusterRoleBinding** - Binds manager role to service account
* **Role** - Leader election role for controller HA
* **RoleBinding** - Binds leader election role to service account

### Custom Resource Definitions (CRDs)
* `microfrontends.polyfea.github.io`
* `microfrontendclasses.polyfea.github.io`
* `webcomponents.polyfea.github.io`

### Optional User Management Roles
These roles are provided to help cluster admins delegate permissions but are **not used** by the controller itself:
* **Admin Role** - Full permissions (`*`) over Polyfea resources
* **Editor Roles** - CRUD permissions for microfrontends, microfrontendclasses, and webcomponents
* **Viewer Roles** - Read-only access to Polyfea resources

## CRDs

This chart includes CRDs under the `crds/` directory.

⚠️ **Important**: Helm installs CRDs **once** and does **not** upgrade or remove them during chart upgrades or uninstallation. 

If CRDs change between versions, update them manually:

```bash
kubectl apply -f charts/polyfea-controller/crds/
```

To remove CRDs (will delete all custom resources):

```bash
kubectl delete crd microfrontends.polyfea.github.io
kubectl delete crd microfrontendclasses.polyfea.github.io
kubectl delete crd webcomponents.polyfea.github.io
```

## Configuration

### View Default Values

```bash
helm show values polyfea/polyfea-controller
```

### Common Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of controller replicas | `1` |
| `image.repository` | Controller image repository | `ghcr.io/polyfea/polyfea-controller` |
| `image.tag` | Controller image tag (overrides appVersion) | `""` (uses chart appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets for private registries | `[]` |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name (auto-generated if empty) | `""` |
| `serviceAccount.annotations` | Annotations for service account | `{}` |
| `podAnnotations` | Annotations for controller pods | `kubectl.kubernetes.io/default-container: polyfea-controller` |
| `podSecurityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `manager.args` | Controller manager arguments | `["--leader-elect", "--health-probe-bind-address=:8081"]` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `resources.requests.cpu` | CPU request | `10m` |
| `resources.requests.memory` | Memory request | `64Mi` |
| `nodeSelector` | Node selector for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity rules for pod assignment | `{}` |
| `rbacRoles.createAdminRole` | Create admin role for user management | `false` |
| `rbacRoles.createEditorRoles` | Create editor roles for user management | `false` |
| `rbacRoles.createViewerRoles` | Create viewer roles for user management | `false` |

### Health Probes

The controller exposes health endpoints on port 8081:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.httpGet.path` | Liveness probe path | `/healthz` |
| `livenessProbe.httpGet.port` | Liveness probe port | `8081` |
| `livenessProbe.initialDelaySeconds` | Initial delay | `15` |
| `livenessProbe.periodSeconds` | Check period | `20` |
| `readinessProbe.httpGet.path` | Readiness probe path | `/readyz` |
| `readinessProbe.httpGet.port` | Readiness probe port | `8081` |
| `readinessProbe.initialDelaySeconds` | Initial delay | `5` |
| `readinessProbe.periodSeconds` | Check period | `10` |

## Usage Examples

### Install with Specific Image Tag

```bash
helm install polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set image.tag=v1.0.0
```

### Install with Custom Resources

```bash
helm install polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=256Mi \
  --set replicaCount=2
```

### Install with User Management Roles

```bash
helm install polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set rbacRoles.createEditorRoles=true \
  --set rbacRoles.createViewerRoles=true
```

### Install with Custom Values File

Create `custom-values.yaml`:

```yaml
replicaCount: 2

image:
  tag: v1.0.0

resources:
  limits:
    cpu: 1000m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 128Mi

rbacRoles:
  createEditorRoles: true
  createViewerRoles: true

nodeSelector:
  kubernetes.io/os: linux
```

Install:

```bash
helm install polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --values custom-values.yaml
```

### Install with Image Pull Secret (Private Registry)

```bash
# Create image pull secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<username> \
  --docker-password=<token> \
  --namespace polyfea-system

# Install with secret
helm install polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set imagePullSecrets[0].name=ghcr-secret
```

## Upgrade

```bash
helm upgrade polyfea-controller ./charts/polyfea-controller \
  --namespace polyfea-system
```

## Uninstall

```bash
helm uninstall polyfea-controller --namespace polyfea-system
```

⚠️ **Note**: This will not remove CRDs or any custom resources. See the [CRDs section](#crds) for manual cleanup.

## Troubleshooting

### Check Controller Logs

```bash
kubectl logs -n polyfea-system deployment/polyfea-controller
```

### Check Controller Status

```bash
kubectl get pods -n polyfea-system
kubectl describe deployment polyfea-controller -n polyfea-system
```

### Verify CRDs

```bash
kubectl get crds | grep polyfea.github.io
```

### Test Health Endpoints

```bash
kubectl port-forward -n polyfea-system deployment/polyfea-controller 8081:8081
curl http://localhost:8081/healthz
curl http://localhost:8081/readyz
```

## Security

This chart adheres to Pod Security Standards "restricted" policy:
- Runs as non-root user
- Drops all capabilities
- Uses seccomp RuntimeDefault profile
- Disables privilege escalation

## 📄 License

Apache License 2.0

```
