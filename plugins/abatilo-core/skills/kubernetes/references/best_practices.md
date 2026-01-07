# Kubernetes Best Practices

This reference provides best practices, tips, troubleshooting guidelines, and integration patterns for working with Kubernetes.

## Safety Best Practices

### Pre-Deployment Validation

**Always Validate Before Applying:**
```bash
# Client-side validation (checks syntax)
kubectl apply -f deployment.yaml --dry-run=client

# Server-side validation (checks against cluster)
kubectl apply -f deployment.yaml --dry-run=server

# Preview changes before applying
kubectl diff -f deployment.yaml
```

**Verify Context and Namespace:**
```bash
# Check current context
kubectl config current-context

# Check current namespace
kubectl config view --minify --output 'jsonpath={..namespace}'

# Explicitly set namespace
kubectl apply -f deployment.yaml -n production
```

### Destructive Operations

**Be Cautious With:**
- `kubectl delete` - Removes resources permanently
- `kubectl delete --all` - Deletes everything of a type
- `kubectl delete namespace` - Removes namespace and all resources in it
- `--force` flag - Bypasses graceful termination
- `kubectl drain` - Evicts all pods from a node
- `kubectl replace --force` - Deletes and recreates resources

**Safe Patterns:**
```bash
# List before deleting
kubectl get pods
kubectl delete pod specific-pod-name

# Use labels to target specific resources
kubectl delete pods -l app=myapp,env=dev

# Dry run first
kubectl delete -f deployment.yaml --dry-run=client
```

### Resource Management Safety

**Set Resource Limits:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

This prevents:
- Resource exhaustion on nodes
- OOM kills affecting other pods
- Runaway processes consuming all CPU

**Use PodDisruptionBudgets:**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: myapp
```

Protects against:
- Too many pods being evicted during node maintenance
- Service downtime during voluntary disruptions

### Configuration Safety

**Never Store Secrets in ConfigMaps:**
```bash
# Wrong
kubectl create configmap app-config --from-literal=password=secret123

# Right
kubectl create secret generic app-secret --from-literal=password=secret123
```

**Use RBAC:**
```bash
# Check your permissions
kubectl auth can-i create deployments
kubectl auth can-i delete pods --all-namespaces

# List all permissions
kubectl auth can-i --list
```

## Efficiency Best Practices

### Resource Organization

**Use Labels Effectively:**
```yaml
metadata:
  labels:
    app: myapp
    tier: frontend
    env: production
    version: v1.0.0
    team: platform
```

Query by labels:
```bash
# Get all frontend pods
kubectl get pods -l tier=frontend

# Get production resources
kubectl get all -l env=production

# Complex selectors
kubectl get pods -l 'app=myapp,env in (prod,staging)'
```

**Use Namespaces for Isolation:**
```bash
# Organize by environment
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# Organize by team
kubectl create namespace team-platform
kubectl create namespace team-data

# Set default namespace
kubectl config set-context --current --namespace=development
```

### Command Efficiency

**Use Shortcuts:**
```bash
# Resource type shortcuts
kubectl get po      # pods
kubectl get svc     # services
kubectl get deploy  # deployments
kubectl get cm      # configmaps
kubectl get ns      # namespaces

# Multiple resources
kubectl get po,svc,deploy

# All resources
kubectl get all
```

**Use Output Formats for Automation:**
```bash
# Get pod names only
kubectl get pods -o name

# Get specific fields with JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Format as table
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP
```

**Combine Operations:**
```bash
# Wait for condition
kubectl wait --for=condition=ready pod/myapp-pod --timeout=60s

# Port forward and test
kubectl port-forward svc/myapp 8080:80 &
sleep 2
curl http://localhost:8080
kill %1
```

### Filtering and Selection

**Use Field Selectors:**
```bash
# Get running pods only
kubectl get pods --field-selector status.phase=Running

# Get pods on specific node
kubectl get pods --field-selector spec.nodeName=node-1

# Combine multiple fields
kubectl get pods --field-selector status.phase=Running,spec.restartPolicy=Always
```

**Sort Results:**
```bash
# Sort by creation time
kubectl get pods --sort-by=.metadata.creationTimestamp

# Sort by name
kubectl get pods --sort-by=.metadata.name

# Sort events by time
kubectl get events --sort-by='.lastTimestamp'
```

## Debugging Best Practices

### Systematic Debugging Approach

**Follow This Order:**
1. **Check Status**: `kubectl get pods`
2. **Describe Resource**: `kubectl describe pod <name>`
3. **View Logs**: `kubectl logs <name>`
4. **Check Events**: `kubectl get events`
5. **Exec Into Pod**: `kubectl exec -it <name> -- /bin/sh`

### Effective Log Analysis

**Use Timestamps:**
```bash
kubectl logs <pod-name> --timestamps
```

**Filter Logs:**
```bash
# Since time
kubectl logs <pod-name> --since=5m
kubectl logs <pod-name> --since=1h

# Tail logs
kubectl logs <pod-name> --tail=100

# Previous container
kubectl logs <pod-name> --previous
```

**Aggregate Logs:**
```bash
# All pods with label
kubectl logs -l app=myapp --tail=50

# Stream from multiple pods
kubectl logs -l app=myapp -f --max-log-requests=10
```

### Event Analysis

**Monitor Events:**
```bash
# Watch events in real-time
kubectl get events -w

# Filter events by type
kubectl get events --field-selector type=Warning

# Events for specific resource
kubectl get events --field-selector involvedObject.name=<pod-name>

# Recent events
kubectl get events --sort-by='.lastTimestamp' | tail -20
```

### Network Debugging

**Use Debug Containers:**
```bash
# Run temporary debug pod
kubectl run debug-pod --rm -it --image=nicolaka/netshoot -- /bin/bash

# Test connectivity
wget -O- http://service-name:80
nslookup service-name
traceroute service-name
```

**Ephemeral Debug Containers (K8s 1.23+):**
```bash
kubectl debug <pod-name> -it --image=busybox --target=<container-name>
```

## YAML Management Best Practices

### Manifest Organization

**File Structure:**
```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patches/
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

**Version Control:**
- Store all manifests in Git
- Use branches for environments
- Tag releases
- Use GitOps tools (ArgoCD, Flux)

### Declarative Configuration

**Prefer Declarative Over Imperative:**

```bash
# Imperative (avoid for production)
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80

# Declarative (preferred)
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

**Use kubectl apply:**
```bash
# Initial creation
kubectl apply -f deployment.yaml

# Updates
kubectl apply -f deployment.yaml  # Same command!

# Entire directory
kubectl apply -f ./manifests/

# Recursive
kubectl apply -R -f ./k8s/
```

### Kustomize Integration

**Base Configuration:**
```yaml
# kustomization.yaml
resources:
- deployment.yaml
- service.yaml

commonLabels:
  app: myapp

namespace: default
```

**Environment Overlays:**
```yaml
# overlays/prod/kustomization.yaml
bases:
- ../../base

namePrefix: prod-
namespace: production

replicas:
- name: myapp
  count: 5

images:
- name: myapp
  newTag: v2.0.0
```

**Apply with Kustomize:**
```bash
kubectl apply -k base/
kubectl apply -k overlays/prod/
```

## Performance Optimization

### Resource Optimization

**Right-Size Resources:**
```bash
# Check actual usage
kubectl top pods
kubectl top pods --containers

# Set appropriate requests/limits
requests:
  memory: "128Mi"  # What it typically uses
  cpu: "100m"
limits:
  memory: "256Mi"  # Maximum it can use
  cpu: "500m"      # Can burst to this
```

**Use Horizontal Pod Autoscaling:**
```bash
# Create HPA
kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=80

# Check HPA
kubectl get hpa
```

**Use Vertical Pod Autoscaling (if available):**
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
```

### Image Optimization

**Use Specific Tags:**
```yaml
# Bad
image: nginx:latest

# Good
image: nginx:1.21.6-alpine
```

**Use Image Pull Policies:**
```yaml
imagePullPolicy: IfNotPresent  # For tagged images
# or
imagePullPolicy: Always        # For :latest or no tag
```

**Use Small Base Images:**
- Alpine Linux images (~5MB)
- Distroless images (no shell, minimal CVEs)
- Scratch images (static binaries)

## High Availability Patterns

### Multi-Replica Deployments

**Minimum Replicas:**
```yaml
spec:
  replicas: 3  # Minimum for HA
```

**Pod Disruption Budgets:**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
spec:
  minAvailable: 2  # At least 2 must be available
  selector:
    matchLabels:
      app: myapp
```

### Topology Spread

**Spread Across Nodes:**
```yaml
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: myapp
```

**Spread Across Zones:**
```yaml
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: myapp
```

### Health Checks

**Liveness Probe** (restart if unhealthy):
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

**Readiness Probe** (remove from service if not ready):
```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 2
```

**Startup Probe** (for slow-starting containers):
```yaml
startupProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 30  # Up to 5 minutes to start
```

## Error Handling

### Common Errors and Solutions

**ImagePullBackOff**
```bash
# Check image name and tag
kubectl describe pod <pod-name> | grep Image

# Verify image exists
docker pull <image-name>

# Check image pull secret
kubectl get secret <secret-name> -o yaml
```

**CrashLoopBackOff**
```bash
# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# Check exit code
kubectl describe pod <pod-name> | grep "Exit Code"

# Common causes:
# - Application error
# - Missing environment variables
# - Failed health checks
# - Resource limits
```

**Pending Pods**
```bash
# Check events
kubectl describe pod <pod-name>

# Common causes:
# - Insufficient resources
# - Node selector doesn't match
# - Taints not tolerated
# - PV not available

# Check node resources
kubectl top nodes
kubectl describe nodes
```

**OOMKilled**
```bash
# Increase memory limits
resources:
  limits:
    memory: "512Mi"  # Increase this

# Check actual usage
kubectl top pod <pod-name> --containers
```

**Permission Denied Errors**
```bash
# Check RBAC
kubectl auth can-i create pods
kubectl auth can-i get services --as=system:serviceaccount:default:myapp

# Describe ServiceAccount
kubectl describe serviceaccount <sa-name>

# Check RoleBindings
kubectl get rolebindings
kubectl describe rolebinding <binding-name>
```

## Integration with Other Tools

### Docker Integration

**Build and Push:**
```bash
# Build image
docker build -t myapp:v1.0.0 .

# Tag for registry
docker tag myapp:v1.0.0 registry.example.com/myapp:v1.0.0

# Push to registry
docker push registry.example.com/myapp:v1.0.0

# Update deployment
kubectl set image deployment/myapp myapp=registry.example.com/myapp:v1.0.0
```

### Git Integration (GitOps)

**ArgoCD Pattern:**
```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  source:
    repoURL: https://github.com/org/repo
    path: k8s/overlays/prod
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Terraform Integration

**Provision with Terraform, Configure with Kubectl:**
```hcl
# Terraform creates cluster
resource "aws_eks_cluster" "main" {
  name = "my-cluster"
  # ...
}

# Then use kubectl for applications
# kubectl apply -f manifests/
```

### CI/CD Integration

**GitHub Actions Example:**
```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl config use-context production
    kubectl set image deployment/myapp myapp=${{ env.IMAGE_TAG }}
    kubectl rollout status deployment/myapp
```

### Monitoring Integration

**Prometheus:**
```yaml
# ServiceMonitor for Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    interval: 30s
```

**Logging (EFK Stack):**
```yaml
# Fluentd reads logs
# Elasticsearch stores logs
# Kibana visualizes logs

# View logs
kubectl logs <pod-name> -f
```

## Tips and Tricks

### Useful Aliases

```bash
alias k=kubectl
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kgpo='kubectl get pods'
alias kgsvc='kubectl get services'
```

### Quick Operations

**Watch Resources:**
```bash
# Watch pods
kubectl get pods -w

# Watch events
kubectl get events -w

# Watch with specific output
watch kubectl get pods -o wide
```

**Temporary Debug Pod:**
```bash
kubectl run debug-pod --rm -it --image=busybox -- /bin/sh
```

**Quick Port Forward:**
```bash
# Background port forward
kubectl port-forward service/myapp 8080:80 &
PF_PID=$!
# Do work...
kill $PF_PID
```

**Export Resources:**
```bash
# Export pod definition
kubectl get pod <pod-name> -o yaml --export > pod.yaml

# Export all resources
kubectl get all -o yaml > all-resources.yaml
```

### Power User Commands

**List All Resources in Namespace:**
```bash
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -n <namespace>
```

**Find Resource Hogs:**
```bash
# CPU hogs
kubectl top pods --all-namespaces --sort-by=cpu

# Memory hogs
kubectl top pods --all-namespaces --sort-by=memory
```

**Bulk Delete:**
```bash
# Delete all failed pods
kubectl delete pods --field-selector=status.phase=Failed --all-namespaces

# Delete all completed jobs
kubectl delete jobs --field-selector status.successful=1
```

**Context Switching:**
```bash
# Quick context switch (if kubectx installed)
kubectx production

# Quick namespace switch (if kubens installed)
kubens staging

# Without tools
kubectl config use-context production
kubectl config set-context --current --namespace=staging
```

### Advanced JSONPath

**Complex Queries:**
```bash
# Get all container images
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}' | tr -s ' ' '\n'

# Get pod names and IPs
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'

# Get node capacity
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'
```

## Environment-Specific Practices

### Development Environment

- Use smaller resource requests/limits
- Use NodePort or port-forwarding instead of LoadBalancers
- Enable debug logging
- Use :latest tags (with imagePullPolicy: Always)
- Shorter grace periods for faster iteration

### Production Environment

- Use specific image tags
- Set resource requests and limits
- Use multiple replicas
- Configure health checks
- Use PodDisruptionBudgets
- Enable monitoring and logging
- Use NetworkPolicies
- Implement proper RBAC
- Regular backups
- Use namespaces for isolation
