# kubectl Command Reference

This reference provides comprehensive details on kubectl operations for managing Kubernetes resources.

## Resource Management

### Getting Resources

Use `kubectl get` to list and retrieve resources.

**Syntax:**
```bash
kubectl get <resource-type> [name] [flags]
```

**Common Options:**
- `-o json|yaml|wide|name|custom-columns` - Output format
- `-l <label-selector>` - Filter by labels (e.g., `-l app=nginx,env=prod`)
- `--field-selector` - Filter by fields (e.g., `--field-selector status.phase=Running`)
- `-n <namespace>` - Specify namespace
- `--all-namespaces` or `-A` - Query across all namespaces
- `-w` or `--watch` - Watch for changes in real-time
- `--sort-by=<jsonpath>` - Sort output (e.g., `--sort-by=.metadata.creationTimestamp`)

**Common Resource Types:**
- `pods` (po) - Running containers
- `deployments` (deploy) - Deployment controllers
- `services` (svc) - Service endpoints
- `configmaps` (cm) - Configuration data
- `secrets` - Sensitive data
- `nodes` - Cluster nodes
- `namespaces` (ns) - Namespace isolation
- `ingresses` (ing) - Ingress rules
- `persistentvolumes` (pv) - Storage volumes
- `persistentvolumeclaims` (pvc) - Storage claims
- `statefulsets` (sts) - Stateful applications
- `daemonsets` (ds) - Node-level pods
- `jobs` - Batch jobs
- `cronjobs` (cj) - Scheduled jobs
- `events` - Cluster events

**Examples:**
```bash
# List all pods in current namespace
kubectl get pods

# List pods with additional details
kubectl get pods -o wide

# Get pod in JSON format
kubectl get pod nginx-pod -o json

# Get pods across all namespaces
kubectl get pods --all-namespaces

# Filter pods by label
kubectl get pods -l app=nginx

# Watch pods in real-time
kubectl get pods -w

# Get pods sorted by creation time
kubectl get pods --sort-by=.metadata.creationTimestamp
```

### Describing Resources

Use `kubectl describe` to get detailed information about resources, including events and conditions.

**Syntax:**
```bash
kubectl describe <resource-type> <name> [-n <namespace>]
```

**What It Shows:**
- Resource metadata (name, labels, annotations)
- Spec configuration
- Current status and conditions
- Recent events related to the resource
- Related resources (e.g., pods for a deployment)

**Examples:**
```bash
# Describe a specific pod
kubectl describe pod nginx-pod

# Describe a deployment
kubectl describe deployment web-app

# Describe with namespace
kubectl describe service api-service -n production

# Describe all pods with label
kubectl describe pods -l app=nginx
```

### Creating Resources

**Declarative Approach (Recommended):**
```bash
kubectl apply -f <filename|directory|url>
```

The `apply` command:
- Creates resources if they don't exist
- Updates resources if they already exist
- Preserves fields managed by other processes
- Tracks configuration for future updates

**Examples:**
```bash
# Apply a single file
kubectl apply -f deployment.yaml

# Apply all files in a directory
kubectl apply -f manifests/

# Apply from URL
kubectl apply -f https://example.com/manifest.yaml

# Apply with validation
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server
```

**Imperative Approach:**
```bash
kubectl create -f <filename>
```

The `create` command:
- Only creates new resources
- Fails if resource already exists
- Useful for one-time operations

**Direct Resource Creation:**
```bash
# Create namespace
kubectl create namespace development

# Create configmap from literal values
kubectl create configmap app-config --from-literal=key1=value1 --from-literal=key2=value2

# Create configmap from file
kubectl create configmap app-config --from-file=config.properties

# Create secret from literal values
kubectl create secret generic db-secret --from-literal=password=mypassword

# Create deployment
kubectl create deployment nginx --image=nginx:latest --replicas=3

# Create service
kubectl create service clusterip my-service --tcp=80:8080
```

### Updating Resources

**Declarative Updates:**
```bash
kubectl apply -f <filename>
```
Modify the YAML file and reapply. Kubernetes will compute and apply the diff.

**Patch Updates:**
```bash
kubectl patch <resource-type> <name> -p '<patch-data>'
```

**Patch Types:**
- Strategic merge patch (default) - Kubernetes-native merging
- JSON merge patch (`--type=merge`) - RFC 7386 merge
- JSON patch (`--type=json`) - RFC 6902 operations

**Examples:**
```bash
# Strategic merge patch
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'

# JSON merge patch
kubectl patch deployment nginx --type=merge -p '{"spec":{"replicas":5}}'

# JSON patch
kubectl patch deployment nginx --type=json -p '[{"op":"replace","path":"/spec/replicas","value":5}]'

# Update image
kubectl set image deployment/nginx nginx=nginx:1.21

# Update environment variable
kubectl set env deployment/nginx APP_ENV=production
```

**Interactive Editing (use sparingly):**
```bash
kubectl edit <resource-type> <name>
```
Opens resource in default editor. Save and close to apply changes.

### Deleting Resources

**Syntax:**
```bash
kubectl delete <resource-type> <name> [flags]
```

**Common Options:**
- `--grace-period=<seconds>` - Time before force deletion
- `--force` - Force deletion immediately
- `--cascade=<background|foreground|orphan>` - Cascading deletion behavior
- `-l <label-selector>` - Delete by label
- `--all` - Delete all resources of a type

**Examples:**
```bash
# Delete specific pod
kubectl delete pod nginx-pod

# Delete from file
kubectl delete -f deployment.yaml

# Delete by label
kubectl delete pods -l app=nginx

# Delete all pods in namespace
kubectl delete pods --all

# Force delete stuck pod
kubectl delete pod nginx-pod --grace-period=0 --force

# Delete namespace (deletes all resources in it)
kubectl delete namespace development
```

## Application Debugging

### Viewing Logs

**Syntax:**
```bash
kubectl logs <pod-name> [flags]
```

**Common Options:**
- `-f` or `--follow` - Stream logs in real-time
- `-c <container-name>` - Specify container in multi-container pod
- `--previous` - Show logs from previous container (for crashed containers)
- `--since=<duration>` - Show logs since relative time (e.g., `5m`, `1h`)
- `--since-time=<timestamp>` - Show logs since absolute time
- `--tail=<lines>` - Show last N lines
- `--timestamps` - Include timestamps
- `-l <label-selector>` - Get logs from all pods matching label

**Examples:**
```bash
# View pod logs
kubectl logs nginx-pod

# Follow logs in real-time
kubectl logs nginx-pod -f

# Get logs from specific container
kubectl logs nginx-pod -c nginx-container

# Get logs from previous container instance
kubectl logs nginx-pod --previous

# Get last 100 lines
kubectl logs nginx-pod --tail=100

# Get logs from last 5 minutes
kubectl logs nginx-pod --since=5m

# Get logs from all pods with label
kubectl logs -l app=nginx

# Get logs with timestamps
kubectl logs nginx-pod --timestamps
```

### Executing Commands in Containers

**Syntax:**
```bash
kubectl exec <pod-name> [flags] -- <command>
```

**Common Options:**
- `-it` - Interactive terminal (for shells)
- `-c <container-name>` - Specify container in multi-container pod

**Examples:**
```bash
# Run single command
kubectl exec nginx-pod -- ls /etc

# Interactive shell
kubectl exec -it nginx-pod -- /bin/bash
kubectl exec -it nginx-pod -- /bin/sh

# Specific container in multi-container pod
kubectl exec -it nginx-pod -c sidecar -- /bin/sh

# Run command with arguments
kubectl exec nginx-pod -- cat /etc/nginx/nginx.conf

# Check environment variables
kubectl exec nginx-pod -- env
```

### Port Forwarding

**Syntax:**
```bash
kubectl port-forward <resource>/<name> <local-port>:<remote-port>
```

**Resource Types:**
- `pod/<name>`
- `deployment/<name>`
- `service/<name>`

**Examples:**
```bash
# Forward to pod
kubectl port-forward pod/nginx-pod 8080:80

# Forward to deployment
kubectl port-forward deployment/nginx 8080:80

# Forward to service
kubectl port-forward service/nginx-service 8080:80

# Forward multiple ports
kubectl port-forward pod/nginx-pod 8080:80 8443:443

# Forward to random local port
kubectl port-forward pod/nginx-pod :80
```

## Deployment Management

### Scaling

**Syntax:**
```bash
kubectl scale <resource-type>/<name> --replicas=<count>
```

**Supported Resources:**
- deployments
- replicasets
- statefulsets
- replicationcontrollers

**Examples:**
```bash
# Scale deployment
kubectl scale deployment/nginx --replicas=5

# Scale statefulset
kubectl scale statefulset/postgres --replicas=3

# Conditional scaling (only if current replicas match)
kubectl scale deployment/nginx --current-replicas=3 --replicas=5
```

### Rollout Management

**Check Rollout Status:**
```bash
kubectl rollout status <resource-type>/<name>
```

**View Rollout History:**
```bash
kubectl rollout history <resource-type>/<name>
kubectl rollout history <resource-type>/<name> --revision=<number>
```

**Undo Rollout (Rollback):**
```bash
kubectl rollout undo <resource-type>/<name>
kubectl rollout undo <resource-type>/<name> --to-revision=<number>
```

**Restart Rollout:**
```bash
kubectl rollout restart <resource-type>/<name>
```

**Pause/Resume Rollout:**
```bash
kubectl rollout pause <resource-type>/<name>
kubectl rollout resume <resource-type>/<name>
```

**Examples:**
```bash
# Check deployment rollout status
kubectl rollout status deployment/nginx

# View rollout history
kubectl rollout history deployment/nginx

# View specific revision
kubectl rollout history deployment/nginx --revision=2

# Rollback to previous version
kubectl rollout undo deployment/nginx

# Rollback to specific revision
kubectl rollout undo deployment/nginx --to-revision=3

# Restart deployment (recreate pods)
kubectl rollout restart deployment/nginx

# Pause rollout for canary deployment
kubectl rollout pause deployment/nginx
# ...make changes, test...
kubectl rollout resume deployment/nginx
```

## Context and Namespace Management

### Managing Contexts

**List Contexts:**
```bash
kubectl config get-contexts
```

**Show Current Context:**
```bash
kubectl config current-context
```

**Switch Context:**
```bash
kubectl config use-context <context-name>
```

**Set Default Namespace for Context:**
```bash
kubectl config set-context --current --namespace=<namespace>
```

**Examples:**
```bash
# List all contexts
kubectl config get-contexts

# Show current context
kubectl config current-context

# Switch to different context
kubectl config use-context production-cluster

# Set default namespace for current context
kubectl config set-context --current --namespace=development
```

### Managing Namespaces

**Create Namespace:**
```bash
kubectl create namespace <name>
```

**Delete Namespace:**
```bash
kubectl delete namespace <name>
```

**Set Default Namespace:**
```bash
kubectl config set-context --current --namespace=<namespace>
```

## Resource Introspection

### API Resources

**List All Resource Types:**
```bash
kubectl api-resources
```

**Common Options:**
- `--namespaced=true|false` - Filter by namespace scope
- `--api-group=<group>` - Filter by API group
- `--verbs=<verb1,verb2>` - Filter by supported verbs
- `-o wide|name` - Output format

**Examples:**
```bash
# List all resources
kubectl api-resources

# List only namespaced resources
kubectl api-resources --namespaced=true

# List resources that support 'list' verb
kubectl api-resources --verbs=list

# Short names
kubectl api-resources -o wide
```

### Explain Resource Fields

**Syntax:**
```bash
kubectl explain <resource>[.<field>[.<subfield>]]
```

**Options:**
- `--recursive` - Show all fields recursively

**Examples:**
```bash
# Explain pod resource
kubectl explain pod

# Explain pod spec
kubectl explain pod.spec

# Explain container specification
kubectl explain pod.spec.containers

# Recursive explanation
kubectl explain pod.spec --recursive

# Explain deployment
kubectl explain deployment.spec.template.spec.containers
```

## Advanced Operations

### Waiting for Conditions

**Syntax:**
```bash
kubectl wait --for=<condition> <resource-type>/<name>
```

**Examples:**
```bash
# Wait for pod to be ready
kubectl wait --for=condition=ready pod/nginx-pod

# Wait for pod to be deleted
kubectl wait --for=delete pod/nginx-pod

# Wait with timeout
kubectl wait --for=condition=ready pod/nginx-pod --timeout=60s
```

### Diff Before Apply

**Preview Changes:**
```bash
kubectl diff -f <filename>
```

Shows what would change if you applied the file.

### Label and Annotation Management

**Add/Update Label:**
```bash
kubectl label <resource-type> <name> <key>=<value>
```

**Remove Label:**
```bash
kubectl label <resource-type> <name> <key>-
```

**Add/Update Annotation:**
```bash
kubectl annotate <resource-type> <name> <key>=<value>
```

**Examples:**
```bash
# Add label
kubectl label pod nginx-pod env=production

# Update label (requires --overwrite)
kubectl label pod nginx-pod env=staging --overwrite

# Remove label
kubectl label pod nginx-pod env-

# Add annotation
kubectl annotate pod nginx-pod description="Main web server"
```

## Output Formats

Kubectl supports multiple output formats via the `-o` or `--output` flag:

- **`json`** - Full JSON output
- **`yaml`** - YAML format
- **`wide`** - Additional columns (more info)
- **`name`** - Resource name only (e.g., `pod/nginx`)
- **`jsonpath=<template>`** - Custom output using JSONPath expressions
- **`jsonpath-file=<file>`** - JSONPath template from file
- **`go-template=<template>`** - Go template output
- **`go-template-file=<file>`** - Go template from file
- **`custom-columns=<spec>`** - Define custom columns
- **`custom-columns-file=<file>`** - Custom columns from file

**Examples:**
```bash
# JSON output
kubectl get pod nginx-pod -o json

# YAML output
kubectl get pod nginx-pod -o yaml

# Wide output
kubectl get pods -o wide

# Name only
kubectl get pods -o name

# JSONPath - get pod IPs
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# JSONPath - custom format
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Go template
kubectl get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
```

## Permissions and Authorization

**Check Permissions:**
```bash
kubectl auth can-i <verb> <resource>
```

**Examples:**
```bash
# Check if I can create pods
kubectl auth can-i create pods

# Check if I can delete deployments
kubectl auth can-i delete deployments

# Check for specific user
kubectl auth can-i get pods --as=john@example.com

# List all permissions
kubectl auth can-i --list
```
