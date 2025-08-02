# GitOps MailHog with Terraform

This project demonstrates a complete GitOps workflow using:
- **Terraform** for infrastructure provisioning
- **ArgoCD** for continuous deployment
- **Kustomize** for environment-specific configurations
- **MailHog** as the sample application

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   Git Repo      │    │   ArgoCD        │
│                 │───▶│                 │───▶│                 │
│   git push      │    │   YAML Manifests│    │   Sync & Deploy │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │   Kubernetes    │
                                               │   Cluster       │
                                               │   (K3s)         │
                                               └─────────────────┘
```

## 📁 Project Structure

```
gitops-mailhog-terraform/
├── README.md                    # This documentation
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── providers.tf            # Provider configurations
│   └── argocd.tf              # ArgoCD installation
├── manifests/                   # Kubernetes manifests
│   ├── base/                   # Base configurations
│   │   ├── deployment.yaml     # MailHog deployment
│   │   ├── service.yaml        # MailHog service
│   │   └── kustomization.yaml  # Base kustomization
│   └── overlays/               # Environment-specific configs
│       ├── dev/                # Development environment
│       │   ├── kustomization.yaml
│       │   └── replica-patch.yaml
│       └── prod/               # Production environment
│           ├── kustomization.yaml
│           ├── replica-patch.yaml
│           └── security-patch.yaml
└── argocd-apps/                # ArgoCD Applications
    └── mailhog-app.yaml        # MailHog application definition
```

## 🚀 Quick Start

### Prerequisites
- K3s cluster running in multipass VM
- ArgoCD installed and accessible
- kubectl configured

### 1. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform apply
```

### 2. Deploy MailHog Application
```bash
kubectl apply -f argocd-apps/mailhog-app.yaml
```

### 3. Access MailHog
```bash
# Port-forward to access MailHog web UI
kubectl port-forward svc/dev-mailhog -n mailhog-dev 8025:8025

# Open browser to http://localhost:8025
```

## 🔧 Environment Differences

| Feature | Development | Production |
|---------|-------------|------------|
| Replicas | 1 | 2 |
| Resources | Low (32Mi/25m) | High (128Mi/100m) |
| Security | Basic | Enhanced |
| Storage | Ephemeral | Persistent |
| Image Tag | latest | v1.0.1 |
| Namespace | mailhog-dev | mailhog-prod |

## 📊 Monitoring & Observability

- **ArgoCD UI**: Monitor deployment status
- **Kubernetes Dashboard**: View resource utilization
- **MailHog UI**: View captured emails

## 🔒 Security Features

### Development
- Basic resource limits
- Standard Kubernetes security

### Production
- Non-root user execution
- Read-only root filesystem
- Dropped Linux capabilities
- Health checks (readiness/liveness)
- Security contexts

## 🛠️ Customization

### Adding New Environment
1. Create new overlay directory: `manifests/overlays/staging/`
2. Add `kustomization.yaml` with environment-specific settings
3. Create patch files for customizations
4. Create ArgoCD application pointing to new overlay

### Modifying Resources
1. Edit base manifests in `manifests/base/`
2. Add environment-specific patches in overlays
3. Commit changes to Git
4. ArgoCD will automatically sync changes

## 🔄 GitOps Workflow

1. **Developer** makes changes to YAML manifests
2. **Git** stores the desired state
3. **ArgoCD** detects changes and syncs
4. **Kubernetes** applies the changes
5. **Monitoring** validates deployment health

## 📝 Best Practices

- ✅ Use specific image tags in production
- ✅ Implement proper resource limits
- ✅ Add health checks for all services
- ✅ Use separate namespaces per environment
- ✅ Enable automatic pruning in ArgoCD
- ✅ Implement proper RBAC
- ✅ Use secrets management for sensitive data

## 🐛 Troubleshooting

### ArgoCD Application Not Syncing
```bash
# Check application status
kubectl get applications -n argocd

# View application details
kubectl describe application mailhog-dev -n argocd
```

### MailHog Pod Not Starting
```bash
# Check pod status
kubectl get pods -n mailhog-dev

# View pod logs
kubectl logs -f deployment/dev-mailhog -n mailhog-dev
```

### Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints -n mailhog-dev

# Test service connectivity
kubectl port-forward svc/dev-mailhog -n mailhog-dev 8025:8025
```

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [MailHog Documentation](https://github.com/mailhog/MailHog)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)