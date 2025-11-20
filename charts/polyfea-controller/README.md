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
* **Service** - ClusterIP service exposing the controller's web server
* **Service Account** - Dedicated service account with optional custom name
* **ClusterRole** - Manager role with permissions for Polyfea CRDs and core resources
* **ClusterRoleBinding** - Binds manager role to service account
* **Role** - Leader election role for controller HA
* **RoleBinding** - Binds leader election role to service account

### Optional External Access
* **Ingress** - Standard Kubernetes Ingress (works with Nginx, Traefik, etc.)
* **HTTPRoute** - Gateway API HTTPRoute (modern successor to Ingress)
* **Traefik IngressRoute** - Native Traefik CRD for advanced Traefik features
* **Custom Ingress** - Support for any custom CRD (Istio, Contour, etc.)
* **LoadBalancer/NodePort** - Direct service exposure via cloud LB or node ports

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

## Accessing the Controller

The controller's web server can be accessed in several ways:

| Method | Use Case | Prerequisites |
|--------|----------|---------------|
| **ClusterIP** (default) | Internal cluster access only | None |
| **Ingress** | Production HTTP/HTTPS via domain name | Ingress controller (Nginx, Traefik, etc.) |
| **Gateway API** | Modern routing with advanced features | Gateway API CRDs + Gateway resource |
| **Traefik IngressRoute** | Native Traefik features (middlewares, etc.) | Traefik with CRDs |
| **Custom Ingress** | Any custom CRD (Istio, Contour, etc.) | Respective controller + CRDs |
| **LoadBalancer** | Cloud environments with LB support | Cloud provider integration |
| **NodePort** | Development/testing on bare metal | Direct node access |

**Recommendations:**
- **Production**: Use **Ingress** (most common) or **Gateway API** (modern) with TLS
- **Development**: Use **port-forward** or **NodePort**
- **Cloud**: Use **LoadBalancer** for simple setups
- **Internal only**: Keep default **ClusterIP**

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

### Service Configuration

The controller's web server can be exposed via a Kubernetes Service:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type (ClusterIP, NodePort, LoadBalancer) | `ClusterIP` |
| `service.port` | Service port | `8082` |
| `service.nodePort` | Static node port (30000-32767, for NodePort type) | `nil` |
| `service.clusterIP` | Specific cluster IP or "None" for headless service | `nil` |
| `service.loadBalancerIP` | Specific IP for LoadBalancer type | `nil` |
| `service.loadBalancerSourceRanges` | CIDR ranges allowed to access LoadBalancer | `nil` |
| `service.externalTrafficPolicy` | Traffic routing policy (Cluster or Local) | `nil` |

### Ingress Configuration

Expose the controller via Ingress (works with Nginx, Traefik, and other ingress controllers):

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress resource | `false` |
| `ingress.className` | Ingress class name (nginx, traefik, etc.) | `nil` |
| `ingress.annotations` | Ingress annotations (cert-manager, etc.) | `{}` |
| `ingress.hosts` | Array of host configurations | See values.yaml |
| `ingress.hosts[].host` | Hostname for the ingress rule | `polyfea-controller.example.com` |
| `ingress.hosts[].paths` | Array of path configurations | `[{path: /, pathType: Prefix}]` |
| `ingress.tls` | TLS configuration for HTTPS | `[]` |

### Gateway API Configuration

Expose the controller via Gateway API HTTPRoute (requires Gateway API CRDs):

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gateway.enabled` | Enable Gateway API HTTPRoute resource | `false` |
| `gateway.annotations` | HTTPRoute annotations | `{}` |
| `gateway.parentRefs` | Array of Gateway references to attach to | `[{name: gateway}]` |
| `gateway.parentRefs[].name` | Name of the Gateway resource | `gateway` |
| `gateway.parentRefs[].namespace` | Namespace of the Gateway (if different) | `nil` |
| `gateway.parentRefs[].sectionName` | Specific listener section name | `nil` |
| `gateway.hostnames` | Array of hostnames for routing | `[polyfea-controller.example.com]` |
| `gateway.rules` | Array of routing rules with matches and filters | See values.yaml |

### Traefik IngressRoute Configuration

Expose the controller via Traefik's native CRD (requires Traefik with CRDs):

| Parameter | Description | Default |
|-----------|-------------|---------|
| `traefik.enabled` | Enable Traefik IngressRoute resource | `false` |
| `traefik.annotations` | IngressRoute annotations | `{}` |
| `traefik.entryPoints` | Array of Traefik entrypoints (web, websecure, etc.) | `[websecure]` |
| `traefik.routes` | Array of routing rules | See values.yaml |
| `traefik.routes[].match` | Traefik routing rule (e.g., Host(`example.com`)) | Required |
| `traefik.routes[].priority` | Route priority (higher = higher priority) | `nil` |
| `traefik.routes[].middlewares` | Array of middleware references | `nil` |
| `traefik.tls` | TLS configuration with secretName and certResolver | `nil` |

### Custom Ingress Configuration

For any other ingress solution with custom CRDs (Istio, Contour, etc.):

| Parameter | Description | Default |
|-----------|-------------|---------|
| `customIngress.enabled` | Enable custom manifest rendering | `false` |
| `customIngress.manifests` | Array of raw Kubernetes manifests | `[]` |

The manifests are templated with full access to chart values and helper functions. See values.yaml for examples.

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
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set image.tag=v1.0.0
```

### Install with Custom Resources

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=256Mi \
  --set replicaCount=2
```

### Install with User Management Roles

```bash
helm install polyfea-controller polyfea/polyfea-controller \
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
helm install polyfea-controller polyfea/polyfea-controller \
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
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set imagePullSecrets[0].name=ghcr-secret
```

### Expose Controller as NodePort

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set service.type=NodePort \
  --set service.nodePort=30082
```

### Expose Controller as LoadBalancer

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set service.type=LoadBalancer \
  --set service.loadBalancerSourceRanges[0]=10.0.0.0/8
```

### Expose Controller via Ingress (Nginx)

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=polyfea.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

### Expose Controller via Ingress with TLS (cert-manager)

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"=letsencrypt-prod \
  --set ingress.hosts[0].host=polyfea.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.tls[0].secretName=polyfea-controller-tls \
  --set ingress.tls[0].hosts[0]=polyfea.example.com
```

### Expose Controller via Traefik (Standard Ingress)

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.className=traefik \
  --set ingress.hosts[0].host=polyfea.example.com \
  --set ingress.hosts[0].paths[0].path=/
```

### Expose Controller via Traefik IngressRoute (Native CRD)

For advanced Traefik features like middlewares:

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set traefik.enabled=true \
  --set traefik.entryPoints[0]=websecure \
  --set traefik.routes[0].match="Host(\`polyfea.example.com\`)"
```

Or with a values file for more complex configuration:

```yaml
traefik:
  enabled: true
  entryPoints:
    - websecure
  routes:
    - match: Host(`polyfea.example.com`) && PathPrefix(`/`)
      middlewares:
        - name: rate-limit
        - name: auth
          namespace: default
  tls:
    secretName: polyfea-controller-tls
    # certResolver: letsencrypt  # For automatic cert generation
```

### Expose Controller via Gateway API

```bash
# Requires Gateway API CRDs and a Gateway resource installed
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --set gateway.enabled=true \
  --set gateway.parentRefs[0].name=my-gateway \
  --set gateway.parentRefs[0].namespace=default \
  --set gateway.hostnames[0]=polyfea.example.com
```

### Gateway API with Custom Values File

For more complex Gateway API configurations, use a values file:

```yaml
gateway:
  enabled: true
  parentRefs:
    - name: my-gateway
      namespace: default
      sectionName: https
  hostnames:
    - polyfea.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      filters:
        - type: RequestHeaderModifier
          requestHeaderModifier:
            add:
              - name: X-Forwarded-Proto
                value: https
```

Then install:

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace \
  --values custom-gateway-values.yaml
```

### Expose Controller via Custom CRD (Istio Example)

For Istio VirtualService or any other custom CRD:

```yaml
customIngress:
  enabled: true
  manifests:
    - apiVersion: networking.istio.io/v1beta1
      kind: VirtualService
      metadata:
        name: "{{ include \"polyfea-controller.fullname\" . }}"
        labels:
          {{- include "polyfea-controller.labels" . | nindent 10 }}
      spec:
        hosts:
          - polyfea.example.com
        gateways:
          - istio-gateway
        http:
          - route:
              - destination:
                  host: "{{ include \"polyfea-controller.fullname\" . }}"
                  port:
                    number: {{ .Values.service.port }}
```

### Expose Controller via Custom CRD (Contour Example)

For Contour HTTPProxy:

```yaml
customIngress:
  enabled: true
  manifests:
    - apiVersion: projectcontour.io/v1
      kind: HTTPProxy
      metadata:
        name: "{{ include \"polyfea-controller.fullname\" . }}"
        namespace: "{{ .Release.Namespace }}"
      spec:
        virtualhost:
          fqdn: polyfea.example.com
          tls:
            secretName: polyfea-controller-tls
        routes:
          - conditions:
              - prefix: /
            services:
              - name: "{{ include \"polyfea-controller.fullname\" . }}"
                port: {{ .Values.service.port }}
```

## Upgrade

```bash
helm upgrade polyfea-controller polyfea/polyfea-controller \
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

### Access Controller Web Server

If the service is installed, you can access the controller's web server:

```bash
# Port-forward the service
kubectl port-forward -n polyfea-system service/polyfea-controller 8082:8082

# For NodePort service, get the node port
kubectl get svc -n polyfea-system polyfea-controller

# For LoadBalancer service, get the external IP
kubectl get svc -n polyfea-system polyfea-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
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
