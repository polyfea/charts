# Polyfea Helm Repository

This repository contains the official Helm charts for Polyfea components.

## Available Charts

| Chart | Description |
|-------|-------------|
| **polyfea-controller** | Deploys the Polyfea microfrontend controller and its CRDs. |

## Adding the Repository

```bash
helm repo add polyfea https://polyfea.github.io/helm
helm repo update
```

## Installing a Chart

Example: install the Polyfea Controller:

```bash
helm install polyfea-controller polyfea/polyfea-controller \
  --namespace polyfea-system \
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