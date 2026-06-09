---
name: kubernetes
description: Comprehensive Kubernetes (k8s) cluster management skill. Use when working with kubectl, Helm, kustomize, pods, deployments, services, configmaps, secrets, or any Kubernetes operations. Triggers on "k8s", "kubectl get", "helm install", "debug pod", "scale deployment", or cluster troubleshooting questions.
context: fork
allowed-tools:
  - Bash(kubectl:*)
  - Bash(helm:*)
  - Bash(kustomize:*)
  - Read
---

# Kubernetes Management Skill

This skill provides comprehensive capabilities for managing Kubernetes clusters, resources, and workloads using kubectl, Helm, and Kustomize.

## When to Use This Skill

Use this skill when working with:
- Kubernetes resources (pods, deployments, services, configmaps, secrets, etc.)
- Debugging containerized applications and troubleshooting cluster issues
- Helm chart installation, upgrades, and management
- kubectl operations (get, describe, apply, create, delete, logs, exec, scale, rollout)
- Context and namespace management
- Deployment strategies (rolling updates, blue-green, canary)
- Configuration management and resource optimization

## How to Use This Skill

### 1. Verify Context and Namespace

Start by verifying your current context and namespace:
```bash
kubectl config current-context
kubectl config view --minify
```

Set namespace if needed:
```bash
kubectl config set-context --current --namespace=<namespace>
```

### 2. Load Appropriate Reference Files

The detailed command and workflow documentation lives in the reference files, so load only the ones the task needs:

**For kubectl Operations:**
Load [kubectl Reference](./references/kubectl_reference.md) when you need detailed information about:
- Getting, describing, creating, updating, or deleting resources
- Viewing logs or executing commands in containers
- Port forwarding and debugging
- Scaling deployments
- Managing rollouts and rollbacks
- Context and namespace operations
- Output formats and filtering

**For Helm Operations:**
Load [Helm Reference](./references/helm_reference.md) when you need detailed information about:
- Installing or upgrading Helm charts
- Managing releases (list, status, uninstall, rollback)
- Repository management
- Chart development and inspection
- Values configuration and overrides
- Troubleshooting Helm issues

**For Common Workflows:**
Load [Workflows Reference](./references/workflows.md) when you need guidance on:
- Debugging failing pods or services
- Deploying applications
- Updating deployments with different strategies
- Blue-green and canary deployments
- Configuration management (ConfigMaps and Secrets)
- Maintenance operations (draining nodes, backup/restore)
- Cluster inspection and cleanup

**For Best Practices:**
Load [Best Practices Reference](./references/best_practices.md) when you need guidance on:
- Safety and validation before operations
- Efficiency and optimization
- Debugging approaches
- YAML and manifest management
- High availability patterns
- Error handling and troubleshooting
- Integration with other tools
- Environment-specific practices

## Key Principles

### Safety First
- Verify context and namespace before operations
- Use `--dry-run=client` or `--dry-run=server` to validate changes
- Use `kubectl diff` to preview changes before applying
- Be cautious with destructive operations (delete, force, drain)

### Declarative Over Imperative
- Prefer `kubectl apply -f file.yaml` over imperative commands
- Store manifests in version control
- Use Kustomize for environment-specific overlays
- Make infrastructure reproducible and auditable

### Efficient Resource Usage
- Use label selectors to operate on groups of resources
- Use output formats (`-o json|yaml`) for automation and parsing
- Filter with `--field-selector` and sort with `--sort-by`
- Watch resources in real-time with `-w` flag

### Systematic Debugging
- Follow the debugging workflow: status → describe → logs → events → exec
- Use timestamps in logs for correlation
- Check recent events with `kubectl get events --sort-by='.lastTimestamp'`
- Test connectivity with temporary debug pods

## Notes

- Use namespaces for resource isolation
- Set resource requests and limits for all containers
- Implement health checks (liveness, readiness, startup probes)
- Use PodDisruptionBudgets for high availability
- Store sensitive data in Secrets, not ConfigMaps
- Tag images with specific versions, avoid `:latest` in production
