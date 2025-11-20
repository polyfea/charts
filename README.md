# Polyfea Helm Repository

This repository contains the official Helm charts for Polyfea components.

## Available Charts

| Chart | Description |
|-------|-------------|
| **polyfea-controller** | Deploys the Polyfea microfrontend controller and its CRDs. |
| **polyfea-md-shell-samples** | Sample applications demonstrating the Polyfea Material Design Shell with web components. Includes dependency on polyfea-controller. |

## Adding the Repository

```bash
helm repo add polyfea https://polyfea.github.io/helm
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
# Update dependencies first
cd charts/polyfea-md-shell-samples
helm dependency update

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

## Development

Charts in this repository are packaged and published automatically to the
`gh-pages` branch using GitHub Actions, making them available as a Helm
repository served via GitHub Pages.

## License

Licensed under the Apache License 2.0.