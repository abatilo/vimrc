# Helm Command Reference

This reference provides comprehensive details on Helm operations for managing Kubernetes applications through charts.

## Overview

Helm is the package manager for Kubernetes that helps you manage Kubernetes applications. Helm charts define, install, and upgrade even the most complex Kubernetes applications.

**Key Concepts:**
- **Chart** - A Helm package containing Kubernetes resource definitions
- **Release** - An instance of a chart running in a Kubernetes cluster
- **Repository** - A collection of charts that can be shared
- **Values** - Configuration parameters for a chart

## Installing Charts

### Basic Installation

**Syntax:**
```bash
helm install <release-name> <chart> [flags]
```

**Common Options:**
- `-f <values-file>` or `--values <values-file>` - Specify values file
- `--set <key>=<value>` - Set values on command line
- `-n <namespace>` or `--namespace <namespace>` - Target namespace
- `--create-namespace` - Create namespace if it doesn't exist
- `--wait` - Wait for resources to be ready
- `--timeout <duration>` - Time to wait (default 5m)
- `--dry-run` - Simulate installation
- `--debug` - Enable verbose output
- `--version <version>` - Specify chart version

**Examples:**
```bash
# Install from repository
helm install my-release bitnami/nginx

# Install with custom values file
helm install my-release bitnami/nginx -f values.yaml

# Install with inline values
helm install my-release bitnami/nginx --set replicaCount=3

# Install in specific namespace
helm install my-release bitnami/nginx -n production --create-namespace

# Install and wait for readiness
helm install my-release bitnami/nginx --wait --timeout 10m

# Dry run to preview
helm install my-release bitnami/nginx --dry-run --debug

# Install specific version
helm install my-release bitnami/nginx --version 12.0.0

# Install from local chart
helm install my-release ./my-chart

# Install from URL
helm install my-release https://example.com/charts/mychart-1.0.0.tgz

# Generate name automatically
helm install bitnami/nginx --generate-name
```

### Setting Values

**Three Methods:**

1. **Values File (`-f` or `--values`):**
```bash
helm install my-release bitnami/nginx -f values.yaml -f values-prod.yaml
```
Multiple values files can be specified. Rightmost file takes precedence.

2. **Command Line (`--set`):**
```bash
helm install my-release bitnami/nginx --set replicaCount=3,service.type=LoadBalancer
```

3. **Set from File (`--set-file`):**
```bash
helm install my-release bitnami/nginx --set-file config=config.json
```

**Priority Order (highest to lowest):**
1. `--set` parameters
2. `--set-file` parameters
3. `-f` or `--values` files (rightmost wins)
4. Chart's default `values.yaml`

**Complex Value Examples:**
```bash
# Nested values
helm install my-release bitnami/nginx --set service.type=LoadBalancer

# Array values
helm install my-release bitnami/nginx --set ingress.hosts[0]=example.com

# Multiple values
helm install my-release bitnami/nginx \
  --set replicaCount=3 \
  --set image.tag=latest \
  --set service.type=ClusterIP
```

## Upgrading Releases

### Basic Upgrade

**Syntax:**
```bash
helm upgrade <release-name> <chart> [flags]
```

**Common Options:**
- `-f <values-file>` - Specify values file
- `--set <key>=<value>` - Set values
- `--reuse-values` - Reuse values from previous release
- `--reset-values` - Reset values to chart defaults (when not using `--reuse-values`)
- `--install` - Install if release doesn't exist (helm upgrade --install)
- `--wait` - Wait for resources to be ready
- `--atomic` - Rollback on failure
- `--force` - Force resource updates
- `--cleanup-on-fail` - Delete newly created resources on failure

**Examples:**
```bash
# Upgrade to new chart version
helm upgrade my-release bitnami/nginx

# Upgrade with new values
helm upgrade my-release bitnami/nginx -f values-v2.yaml

# Upgrade or install if doesn't exist
helm upgrade my-release bitnami/nginx --install

# Upgrade with inline values
helm upgrade my-release bitnami/nginx --set replicaCount=5

# Reuse existing values
helm upgrade my-release bitnami/nginx --reuse-values

# Atomic upgrade (rollback on failure)
helm upgrade my-release bitnami/nginx --atomic

# Force upgrade (recreate resources)
helm upgrade my-release bitnami/nginx --force

# Upgrade to specific version
helm upgrade my-release bitnami/nginx --version 13.0.0
```

### Upgrade Strategies

**Standard Upgrade:**
```bash
helm upgrade my-release bitnami/nginx -f new-values.yaml
```
New values override all previous values unless `--reuse-values` is used.

**Incremental Upgrade:**
```bash
helm upgrade my-release bitnami/nginx --reuse-values --set newFeature.enabled=true
```
Keeps existing values and only updates specified ones.

**Safe Upgrade:**
```bash
helm upgrade my-release bitnami/nginx -f values.yaml --atomic --wait --timeout 5m
```
Automatically rolls back if upgrade fails or times out.

## Managing Releases

### Listing Releases

**Syntax:**
```bash
helm list [flags]
```

**Common Options:**
- `-n <namespace>` - List releases in specific namespace
- `-A` or `--all-namespaces` - List releases across all namespaces
- `-a` or `--all` - Show all releases (including failed/deleted)
- `--deployed` - Show deployed releases only
- `--failed` - Show failed releases only
- `--pending` - Show pending releases
- `-o json|yaml|table` - Output format

**Examples:**
```bash
# List releases in current namespace
helm list

# List releases in specific namespace
helm list -n production

# List all releases in all namespaces
helm list --all-namespaces

# List including failed/uninstalled
helm list --all

# JSON output
helm list -o json

# Filter by status
helm list --deployed
helm list --failed
```

### Viewing Release Status

**Show Release Status:**
```bash
helm status <release-name> [-n <namespace>]
```

**Show Release Values:**
```bash
helm get values <release-name> [-n <namespace>]
```

**Show All Release Information:**
```bash
helm get all <release-name> [-n <namespace>]
```

**Show Release Manifest:**
```bash
helm get manifest <release-name> [-n <namespace>]
```

**Show Release Notes:**
```bash
helm get notes <release-name> [-n <namespace>]
```

**Examples:**
```bash
# Check release status
helm status my-release

# Get current values
helm get values my-release

# Get values with defaults
helm get values my-release --all

# Get manifests
helm get manifest my-release

# Get everything
helm get all my-release

# Output as YAML
helm get values my-release -o yaml
```

### Uninstalling Releases

**Syntax:**
```bash
helm uninstall <release-name> [flags]
```

**Common Options:**
- `-n <namespace>` - Namespace of release
- `--keep-history` - Keep release history
- `--dry-run` - Simulate uninstall
- `--wait` - Wait for deletion to complete

**Examples:**
```bash
# Uninstall release
helm uninstall my-release

# Uninstall from specific namespace
helm uninstall my-release -n production

# Keep history for rollback
helm uninstall my-release --keep-history

# Dry run
helm uninstall my-release --dry-run
```

## Rollback

### Rolling Back Releases

**Syntax:**
```bash
helm rollback <release-name> [revision] [flags]
```

**Common Options:**
- `--wait` - Wait for rollback to complete
- `--cleanup-on-fail` - Clean up new resources on failure
- `--force` - Force resource updates
- `--recreate-pods` - Recreate pods for deployment rollback

**Examples:**
```bash
# Rollback to previous version
helm rollback my-release

# Rollback to specific revision
helm rollback my-release 3

# Rollback with wait
helm rollback my-release --wait

# Force rollback
helm rollback my-release --force
```

### Viewing Rollback History

**Syntax:**
```bash
helm history <release-name> [flags]
```

**Examples:**
```bash
# View release history
helm history my-release

# View history with output
helm history my-release -o yaml

# Limit history entries
helm history my-release --max 10
```

## Repository Management

### Adding Repositories

**Syntax:**
```bash
helm repo add <name> <url> [flags]
```

**Examples:**
```bash
# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Add with authentication
helm repo add private https://charts.example.com --username user --password pass

# Add with TLS certificate
helm repo add secure https://charts.example.com --ca-file ca.crt --cert-file cert.crt --key-file key.key
```

### Managing Repositories

**List Repositories:**
```bash
helm repo list
```

**Update Repositories:**
```bash
helm repo update
```

**Remove Repository:**
```bash
helm repo remove <name>
```

**Examples:**
```bash
# List all repositories
helm repo list

# Update all repositories
helm repo update

# Update specific repository
helm repo update bitnami

# Remove repository
helm repo remove bitnami
```

### Searching Charts

**Search in Repositories:**
```bash
helm search repo <keyword> [flags]
```

**Search Helm Hub:**
```bash
helm search hub <keyword> [flags]
```

**Options:**
- `--versions` - Show all versions
- `--version <constraint>` - Show versions matching constraint
- `-l` - Show long output

**Examples:**
```bash
# Search in configured repositories
helm search repo nginx

# Show all versions
helm search repo nginx --versions

# Search Helm Hub
helm search hub nginx

# Filter by version
helm search repo nginx --version "^1.0.0"
```

## Chart Development & Inspection

### Inspecting Charts

**Show Chart Details:**
```bash
helm show chart <chart>
```

**Show Chart Values:**
```bash
helm show values <chart>
```

**Show Chart README:**
```bash
helm show readme <chart>
```

**Show Everything:**
```bash
helm show all <chart>
```

**Examples:**
```bash
# Show chart metadata
helm show chart bitnami/nginx

# Show default values
helm show values bitnami/nginx

# Show README
helm show readme bitnami/nginx

# Show all info
helm show all bitnami/nginx

# Show specific version
helm show values bitnami/nginx --version 12.0.0
```

### Pulling Charts

**Syntax:**
```bash
helm pull <chart> [flags]
```

**Common Options:**
- `--untar` - Untar the chart after download
- `--version <version>` - Specify version
- `-d <destination>` - Destination directory

**Examples:**
```bash
# Pull chart
helm pull bitnami/nginx

# Pull and untar
helm pull bitnami/nginx --untar

# Pull specific version
helm pull bitnami/nginx --version 12.0.0

# Pull to directory
helm pull bitnami/nginx -d ./charts
```

### Creating Charts

**Create New Chart:**
```bash
helm create <chart-name>
```

**Lint Chart:**
```bash
helm lint <chart-path>
```

**Package Chart:**
```bash
helm package <chart-path>
```

**Examples:**
```bash
# Create new chart scaffold
helm create mychart

# Lint chart for issues
helm lint ./mychart

# Package chart
helm package ./mychart

# Package with version
helm package ./mychart --version 1.0.0
```

### Template Rendering

**Render Templates Locally:**
```bash
helm template <release-name> <chart> [flags]
```

**Common Options:**
- `-f <values-file>` - Values file
- `--set <key>=<value>` - Set values
- `-s <template>` - Only show specific template
- `--debug` - Enable debug output
- `--validate` - Validate against Kubernetes

**Examples:**
```bash
# Render templates
helm template my-release bitnami/nginx

# Render with values
helm template my-release bitnami/nginx -f values.yaml

# Render specific template
helm template my-release bitnami/nginx -s templates/deployment.yaml

# Debug template rendering
helm template my-release bitnami/nginx --debug

# Validate against cluster
helm template my-release bitnami/nginx --validate
```

## Advanced Operations

### Testing Releases

**Run Chart Tests:**
```bash
helm test <release-name> [flags]
```

Chart tests are pods with special annotations that run tests against the release.

**Examples:**
```bash
# Run tests
helm test my-release

# Show test logs
helm test my-release --logs
```

### Dependency Management

**Update Chart Dependencies:**
```bash
helm dependency update <chart-path>
```

**Build Dependency Lock:**
```bash
helm dependency build <chart-path>
```

**List Dependencies:**
```bash
helm dependency list <chart-path>
```

### Plugin Management

**List Plugins:**
```bash
helm plugin list
```

**Install Plugin:**
```bash
helm plugin install <url>
```

**Uninstall Plugin:**
```bash
helm plugin uninstall <plugin-name>
```

**Update Plugin:**
```bash
helm plugin update <plugin-name>
```

## Helm with Kustomize

While Helm and Kustomize serve different purposes, they can be used together:

**Post-Rendering with Kustomize:**
```bash
helm install my-release bitnami/nginx --post-renderer kustomize
```

This allows Kustomize to modify Helm-generated manifests before applying them.

## Common Patterns

### Install or Upgrade Pattern

```bash
helm upgrade my-release bitnami/nginx --install --wait --atomic
```

This pattern:
- Installs if release doesn't exist
- Upgrades if it exists
- Waits for resources to be ready
- Rolls back automatically on failure

### Blue-Green Deployment Pattern

```bash
# Install new version (green)
helm install my-release-green bitnami/nginx --set service.name=nginx-green

# Test...

# Switch traffic by updating service
kubectl patch service nginx -p '{"spec":{"selector":{"app":"nginx-green"}}}'

# Remove old version (blue)
helm uninstall my-release-blue
```

### Values Override Pattern

```bash
# Base values
helm upgrade my-release bitnami/nginx \
  -f values-base.yaml \
  -f values-environment.yaml \
  -f values-custom.yaml \
  --set image.tag=v2.0.0
```

Priority: `--set` > `values-custom.yaml` > `values-environment.yaml` > `values-base.yaml`

## Troubleshooting

### Debug Installation Issues

```bash
# Dry run with debug
helm install my-release bitnami/nginx --dry-run --debug

# Template with debug
helm template my-release bitnami/nginx --debug

# Check release status
helm status my-release

# View release history
helm history my-release
```

### Common Issues

**Issue: Release not found**
```bash
# List all releases including failed
helm list --all

# Check in other namespaces
helm list --all-namespaces
```

**Issue: Values not applying**
```bash
# Check what values are set
helm get values my-release

# Check with defaults
helm get values my-release --all

# Re-render templates to debug
helm template my-release bitnami/nginx -f values.yaml --debug
```

**Issue: Upgrade stuck**
```bash
# Check release status
helm status my-release

# Check pods
kubectl get pods -l app.kubernetes.io/instance=my-release

# Rollback if needed
helm rollback my-release
```

**Issue: Cannot delete release**
```bash
# Force delete
helm uninstall my-release --no-hooks

# If still stuck, manually delete release secret
kubectl delete secret -l owner=helm,name=my-release
```
