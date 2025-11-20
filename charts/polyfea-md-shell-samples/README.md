# Polyfea MD Shell Samples

Sample applications and configurations for Polyfea, demonstrating the Material Design Shell with sample web components.

## Prerequisites

- Kubernetes cluster
- Helm 3+
- `polyfea-controller` (automatically installed via chart dependency by default, or can be installed separately)

## Installation

### From Helm Repository

Add the Polyfea Helm repository:

```bash
helm repo add polyfea https://polyfea.github.io/charts
helm repo update
```

### Install with controller dependency

```bash
# Install both controller and samples
helm install polyfea polyfea/polyfea-md-shell-samples \
  --namespace polyfea \
  --create-namespace
```

### Install samples only (controller already installed)

If the controller is already installed in a different namespace, disable the dependency:

```bash
helm install polyfea-md-shell-samples polyfea/polyfea-md-shell-samples \
  --namespace polyfea \
  --create-namespace \
  --set polyfea-controller.enabled=false
```

### Install in separate namespaces

```bash
# Install controller in polyfea-system namespace
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace

# Install samples in polyfea namespace (skip controller dependency)
helm install polyfea-samples polyfea/polyfea-md-shell-samples \
  --namespace polyfea \
  --create-namespace \
  --set polyfea-controller.enabled=false
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `polyfea-controller.enabled` | Install polyfea-controller dependency | `true` |
| `enabled` | Enable/disable sample deployment | `true` |
| `samples.earthSample` | Enable/disable Earth sample app | `true` |
| `mdShell.replicaCount` | Number of replicas | `1` |
| `mdShell.image.repository` | Image repository | `ghcr.io/polyfea/md-shell` |
| `mdShell.image.tag` | Image tag | `latest` |
| `mdShell.applicationHeadline` | Application title | `Polyfea Shell Application` |
| `microfrontendClass.baseUri` | Base URI for microfrontends | `/fea` |

### Example: Customize Application Name

```bash
helm install polyfea-md-shell-samples polyfea/polyfea-md-shell-samples \
  --namespace polyfea \
  --create-namespace \
  --set mdShell.applicationHeadline="My Custom App"
```

### Example: Disable Earth Sample

```bash
helm install polyfea-md-shell-samples polyfea/polyfea-md-shell-samples \
  --namespace polyfea \
  --create-namespace \
  --set samples.earthSample=false
```

## What's Included

This chart deploys:

- **MicroFrontendClass**: Configuration for the Polyfea MD Shell
- **MicroFrontends**: Material Design and MD Shell frontend modules
- **WebComponents**: Sample components including:
  - Shell application component
  - Home navigation link
  - Earth/Blue Marble sample application
  - Application tiles display
- **Deployment**: MD Shell application server
- **Service**: ClusterIP service for the MD Shell

## Uninstallation

```bash
helm uninstall polyfea-md-shell-samples --namespace polyfea
```

## Notes

- Helm hooks ensure resources are created in the correct order:
  1. MicroFrontendClass (weight 1)
  2. MicroFrontends (weight 5)
  3. WebComponents (weight 10)
- The controller must be running before samples can be deployed
- Samples are disabled by setting `enabled: false` in values
