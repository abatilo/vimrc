# Common Kubernetes Workflows

This reference provides step-by-step workflows for common Kubernetes operations and troubleshooting scenarios.

## Debugging Workflows

### Debugging a Failing Pod

When a pod is not starting or crashing, follow this systematic approach:

**1. Check Pod Status**
```bash
kubectl get pods
kubectl get pods -o wide  # Show node, IP, and more details
```

Look for status indicators:
- `Pending` - Not scheduled yet (resource constraints, node selector issues)
- `ContainerCreating` - Being created (image pull, volume mount issues)
- `CrashLoopBackOff` - Container keeps crashing
- `Error` - Container exited with error
- `ImagePullBackOff` - Cannot pull container image
- `ErrImagePull` - Image pull failed

**2. Describe the Pod**
```bash
kubectl describe pod <pod-name>
```

Look for:
- Events at the bottom (most recent issues)
- Container states and reasons
- Resource requests/limits
- Volume mount issues
- Image pull errors

**3. Check Container Logs**
```bash
# Current container logs
kubectl logs <pod-name>

# Previous container logs (if crashed)
kubectl logs <pod-name> --previous

# Specific container in multi-container pod
kubectl logs <pod-name> -c <container-name>

# Follow logs in real-time
kubectl logs <pod-name> -f
```

**4. Check Events**
```bash
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.name=<pod-name>
```

**5. Exec into Pod (if running)**
```bash
kubectl exec -it <pod-name> -- /bin/sh
# or
kubectl exec -it <pod-name> -- /bin/bash

# Check processes
ps aux

# Check disk usage
df -h

# Check environment variables
env

# Check network connectivity
ping google.com
curl http://service-name
```

**6. Common Issues and Solutions**

**Image Pull Issues:**
```bash
# Check image name and tag
kubectl describe pod <pod-name> | grep Image

# Verify image exists
docker pull <image-name>

# Check image pull secrets
kubectl get secrets
kubectl describe pod <pod-name> | grep -A 5 "Image Pull Secrets"
```

**Resource Issues:**
```bash
# Check node resources
kubectl top nodes
kubectl describe node <node-name>

# Check pod resource requests
kubectl describe pod <pod-name> | grep -A 5 "Requests"
```

**Configuration Issues:**
```bash
# Check ConfigMap exists
kubectl get configmap <name>

# Check Secret exists
kubectl get secret <name>

# Verify volume mounts
kubectl describe pod <pod-name> | grep -A 10 "Mounts"
```

### Debugging Service Connectivity

When services are not accessible:

**1. Verify Service Exists**
```bash
kubectl get services
kubectl describe service <service-name>
```

Check:
- Service type (ClusterIP, NodePort, LoadBalancer)
- Selector matches pod labels
- Port and targetPort configuration
- Endpoints are populated

**2. Check Endpoints**
```bash
kubectl get endpoints <service-name>
```

If endpoints are empty, selector doesn't match any pods.

**3. Verify Pod Labels**
```bash
kubectl get pods --show-labels
kubectl get pods -l app=<label-value>
```

**4. Test Connectivity**
```bash
# From another pod
kubectl run test-pod --rm -it --image=busybox -- /bin/sh
wget -O- http://<service-name>:<port>
nslookup <service-name>

# Port forward to test locally
kubectl port-forward service/<service-name> 8080:80
curl http://localhost:8080
```

**5. Check Network Policies**
```bash
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>
```

**6. Check DNS**
```bash
# Test DNS resolution
kubectl run test-dns --rm -it --image=busybox -- nslookup <service-name>

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

### Debugging Performance Issues

**1. Check Resource Usage**
```bash
# Node metrics
kubectl top nodes

# Pod metrics
kubectl top pods
kubectl top pods --namespace=<namespace>

# Specific pod containers
kubectl top pod <pod-name> --containers
```

**2. Check Resource Limits**
```bash
kubectl describe pod <pod-name> | grep -A 5 "Limits"
kubectl describe pod <pod-name> | grep -A 5 "Requests"
```

**3. Check for OOMKilled**
```bash
kubectl get pods | grep OOMKilled
kubectl describe pod <pod-name> | grep -i "OOM"
```

**4. Check Node Conditions**
```bash
kubectl describe node <node-name> | grep -A 10 "Conditions"
```

Look for:
- MemoryPressure
- DiskPressure
- PIDPressure

**5. Analyze Application Metrics**
```bash
# Get logs with timestamps
kubectl logs <pod-name> --timestamps

# Check application-specific metrics
kubectl port-forward <pod-name> 9090:9090
# Access metrics endpoint locally
curl http://localhost:9090/metrics
```

## Deployment Workflows

### Deploying an Application

**1. Prepare Manifests**

Create deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

Create service.yaml:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

**2. Validate Manifests**
```bash
# Client-side validation
kubectl apply -f deployment.yaml --dry-run=client

# Server-side validation
kubectl apply -f deployment.yaml --dry-run=server
```

**3. Apply Manifests**
```bash
# Apply all files in directory
kubectl apply -f manifests/

# Apply specific files
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

**4. Monitor Deployment**
```bash
# Watch rollout status
kubectl rollout status deployment/myapp

# Watch pods
kubectl get pods -l app=myapp -w

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

**5. Verify Application**
```bash
# Check pods are running
kubectl get pods -l app=myapp

# Check service endpoints
kubectl get endpoints myapp-service

# Test connectivity
kubectl port-forward service/myapp-service 8080:80
curl http://localhost:8080
```

**6. View Logs**
```bash
# All pods with label
kubectl logs -l app=myapp

# Follow logs
kubectl logs -l app=myapp -f

# Specific pod
kubectl logs <pod-name>
```

### Updating a Deployment

**1. Update Image**
```bash
# Using kubectl set
kubectl set image deployment/myapp myapp=myapp:v2.0.0

# Or update YAML and apply
kubectl apply -f deployment.yaml
```

**2. Monitor Rollout**
```bash
# Watch rollout status
kubectl rollout status deployment/myapp

# Watch pods during rollout
kubectl get pods -l app=myapp -w

# Check rollout history
kubectl rollout history deployment/myapp
```

**3. Verify New Version**
```bash
# Check image version
kubectl get deployment myapp -o jsonpath='{.spec.template.spec.containers[0].image}'

# Test application
kubectl port-forward deployment/myapp 8080:8080
curl http://localhost:8080/version
```

**4. Rollback if Needed**
```bash
# Rollback to previous version
kubectl rollout undo deployment/myapp

# Rollback to specific revision
kubectl rollout history deployment/myapp
kubectl rollout undo deployment/myapp --to-revision=3
```

### Scaling Applications

**Manual Scaling:**
```bash
# Scale deployment
kubectl scale deployment/myapp --replicas=5

# Verify scaling
kubectl get deployment myapp
kubectl get pods -l app=myapp
```

**Autoscaling (HPA):**
```bash
# Create horizontal pod autoscaler
kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=80

# Check HPA status
kubectl get hpa
kubectl describe hpa myapp

# View HPA events
kubectl get events --field-selector involvedObject.name=myapp
```

### Blue-Green Deployment

**1. Deploy Green (New Version)**
```bash
# Create new deployment
kubectl apply -f deployment-green.yaml

# Wait for ready
kubectl rollout status deployment/myapp-green

# Verify
kubectl get pods -l version=green
```

**2. Test Green Deployment**
```bash
# Create temporary service
kubectl expose deployment myapp-green --name=myapp-test --type=ClusterIP

# Test
kubectl port-forward service/myapp-test 8080:80
curl http://localhost:8080

# Delete test service
kubectl delete service myapp-test
```

**3. Switch Traffic**
```bash
# Update service selector to point to green
kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'

# Verify endpoints
kubectl get endpoints myapp
```

**4. Monitor and Cleanup**
```bash
# Monitor new version
kubectl logs -l version=green -f

# If successful, delete blue
kubectl delete deployment myapp-blue

# If issues, rollback
kubectl patch service myapp -p '{"spec":{"selector":{"version":"blue"}}}'
```

### Canary Deployment

**1. Deploy Canary**
```bash
# Keep production at 9 replicas
kubectl scale deployment/myapp-prod --replicas=9

# Deploy canary with 1 replica (10% traffic)
kubectl apply -f deployment-canary.yaml
kubectl scale deployment/myapp-canary --replicas=1
```

**2. Monitor Canary**
```bash
# Watch canary pods
kubectl get pods -l version=canary -w

# Monitor canary logs
kubectl logs -l version=canary -f

# Check metrics/errors
kubectl top pods -l version=canary
```

**3. Gradually Increase Traffic**
```bash
# Increase canary to 30% (3/10 pods)
kubectl scale deployment/myapp-prod --replicas=7
kubectl scale deployment/myapp-canary --replicas=3

# Monitor...

# Increase to 50%
kubectl scale deployment/myapp-prod --replicas=5
kubectl scale deployment/myapp-canary --replicas=5
```

**4. Complete Rollout or Rollback**
```bash
# If successful, full rollout
kubectl scale deployment/myapp-prod --replicas=0
kubectl scale deployment/myapp-canary --replicas=10
# Or update prod deployment to new version
kubectl set image deployment/myapp-prod myapp=myapp:v2.0.0
kubectl delete deployment myapp-canary

# If issues, rollback
kubectl scale deployment/myapp-canary --replicas=0
kubectl scale deployment/myapp-prod --replicas=10
```

## Configuration Management

### Managing ConfigMaps

**Creating ConfigMaps:**
```bash
# From literals
kubectl create configmap app-config \
  --from-literal=key1=value1 \
  --from-literal=key2=value2

# From file
kubectl create configmap app-config --from-file=config.properties

# From directory
kubectl create configmap app-config --from-file=configs/

# From YAML
kubectl apply -f configmap.yaml
```

**Using ConfigMaps:**
```yaml
# As environment variables
env:
- name: KEY1
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: key1

# As volume mount
volumes:
- name: config
  configMap:
    name: app-config
```

**Updating ConfigMaps:**
```bash
# Edit directly
kubectl edit configmap app-config

# Replace from file
kubectl create configmap app-config --from-file=config.properties --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to pick up changes
kubectl rollout restart deployment/myapp
```

### Managing Secrets

**Creating Secrets:**
```bash
# Generic secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123

# TLS secret
kubectl create secret tls tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/key.key

# Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass \
  --docker-email=user@example.com

# From file
kubectl create secret generic ssh-secret --from-file=ssh-privatekey=~/.ssh/id_rsa
```

**Using Secrets:**
```yaml
# As environment variables
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password

# As volume
volumes:
- name: secret
  secret:
    secretName: db-secret
```

### Environment-Specific Deployments

**Using Kustomize:**

**Base (base/kustomization.yaml):**
```yaml
resources:
- deployment.yaml
- service.yaml
```

**Overlay for Dev (overlays/dev/kustomization.yaml):**
```yaml
bases:
- ../../base
namePrefix: dev-
replicas:
- name: myapp
  count: 1
```

**Overlay for Prod (overlays/prod/kustomization.yaml):**
```yaml
bases:
- ../../base
namePrefix: prod-
replicas:
- name: myapp
  count: 5
```

**Deploy:**
```bash
# Dev
kubectl apply -k overlays/dev/

# Prod
kubectl apply -k overlays/prod/
```

## Maintenance Workflows

### Draining and Cordoning Nodes

**Drain Node for Maintenance:**
```bash
# Cordon node (prevent new pods)
kubectl cordon <node-name>

# Drain node (evict pods gracefully)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Perform maintenance...

# Uncordon node
kubectl uncordon <node-name>
```

### Backup and Restore

**Backup Resources:**
```bash
# Backup all resources in namespace
kubectl get all -n production -o yaml > backup-production.yaml

# Backup specific resources
kubectl get deployment,service,configmap -n production -o yaml > backup.yaml

# Backup with labels
kubectl get all -l app=myapp -o yaml > backup-myapp.yaml
```

**Restore Resources:**
```bash
# Restore from backup
kubectl apply -f backup-production.yaml

# Restore to different namespace
kubectl apply -f backup-production.yaml -n staging
```

### Cluster Inspection

**Check Cluster Health:**
```bash
# Node status
kubectl get nodes
kubectl describe nodes | grep -A 5 "Conditions"

# Component status
kubectl get componentstatuses
kubectl get pods -n kube-system

# API server health
kubectl get --raw /healthz
kubectl get --raw /readyz

# Check critical pods
kubectl get pods -n kube-system
```

**Resource Usage Overview:**
```bash
# Cluster-wide resource usage
kubectl top nodes

# All pods resource usage
kubectl top pods --all-namespaces

# Resources by namespace
kubectl top pods -n production

# Sort by CPU
kubectl top pods --sort-by=cpu

# Sort by memory
kubectl top pods --sort-by=memory
```

### Cleaning Up Resources

**Delete Resources by Label:**
```bash
# Delete all resources with label
kubectl delete all -l app=myapp

# Delete specific types with label
kubectl delete deployment,service -l app=myapp
```

**Delete Old Resources:**
```bash
# Find old completed jobs
kubectl get jobs --field-selector status.successful=1

# Delete completed jobs
kubectl delete jobs --field-selector status.successful=1

# Delete failed pods
kubectl delete pods --field-selector status.phase=Failed

# Delete evicted pods
kubectl get pods --all-namespaces --field-selector=status.phase==Failed -o json | kubectl delete -f -
```

**Force Delete Stuck Resources:**
```bash
# Force delete pod
kubectl delete pod <pod-name> --grace-period=0 --force

# Remove finalizers (last resort)
kubectl patch pod <pod-name> -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete pod <pod-name>
```
