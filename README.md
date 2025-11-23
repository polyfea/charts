# Polyfea Helm Repository

This repository contains the official Helm charts for Polyfea components.

## Available Charts

| Chart | Description |
|-------|-------------|
| **polyfea-controller** | Deploys the Polyfea microfrontend controller and its CRDs. |
| **polyfea-md-shell-samples** | Sample applications demonstrating the Polyfea Material Design Shell with web components. Includes dependency on polyfea-controller. |

## Adding the Repository

```bash
helm repo add polyfea https://polyfea.github.io/charts
helm repo update
```

## Installing a Chart

### Install the Polyfea Controller

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
  --create-namespace
```

### Install Sample Applications

The samples chart includes a dependency on the controller, so it can be installed standalone:

```bash
# Install both controller and samples
helm install polyfea polyfea/polyfea-md-shell-samples \
  --namespace polyfea \
  --create-namespace
```

You can customize the samples installation:

```bash
# Disable the Earth sample application
helm install polyfea polyfea/polyfea-md-shell-samples \
  --set samples.earthSample=false \
  --namespace polyfea \
  --create-namespace
```

## Documentation

Each chart includes its own `README.md` found inside:

```
charts/<chart-name>/README.md
```

## Uninstalling

Custom resources (MicroFrontendClass, MicroFrontend, WebComponent) are **not** automatically deleted when uninstalling the chart.

### Clean Uninstall

```bash
# 1. Delete all custom resources first
kubectl delete microfrontendclass,microfrontend,webcomponent --all-namespaces --all

# 2. Uninstall the chart
helm uninstall <release-name> --namespace <namespace>
```

### If CRs are Stuck in Terminating State

If you uninstalled the controller before deleting CRs, remove finalizers manually:

```bash
kubectl patch microfrontendclass <name> -n <namespace> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch microfrontend <name> -n <namespace> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch webcomponent <name> -n <namespace> -p '{"metadata":{"finalizers":null}}' --type=merge
```

## Development

Charts in this repository are packaged and published automatically to the
`gh-pages` branch using GitHub Actions, making them available as a Helm
repository served via GitHub Pages.

## License

Licensed under the Apache License 2.0.