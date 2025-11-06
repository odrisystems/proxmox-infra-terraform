# Proxmox VM Terraform Infrastructure

This repository contains Terraform modules for provisioning virtual machines on Proxmox VE clusters. The infrastructure supports both HashiCorp Vault-based secret management and traditional variable-based configuration.

## Available Modules

### 1. **proxmox-vault** - HashiCorp Vault Integration

Best for production environments requiring centralized secret management.

**Features:**
- Centralized secret management via HashiCorp Vault
- No credentials stored in code or configuration files
- Dynamic credential retrieval at runtime
- Suitable for team environments and CI/CD pipelines
- Enhanced security posture

**Use when:**
- You have a Vault infrastructure in place
- Security and compliance require centralized secret management
- Multiple team members need access without sharing credentials
- Deploying in production environments

**Documentation:** See [modules/proxmox-vault/README.md](modules/proxmox-vault/README.md)

### 2. **proxmox-no-vault** - Direct Variable Configuration

Best for development, testing, or environments without Vault infrastructure.

**Features:**
- Simple configuration via terraform.tfvars or environment variables
- No external dependencies
- Quick setup and deployment
- Suitable for single-user or development environments

**Use when:**
- You don't have HashiCorp Vault infrastructure
- Working in development or testing environments
- Quick prototyping or proof-of-concept work
- Single-user deployments

**Documentation:** See [modules/proxmox-no-vault/README.md](modules/proxmox-no-vault/README.md)

## Common Features

Both modules provide:
- Creates `proxmox_vm_qemu` VMs with configurable resources
- Cloud-init enabled template support
- Blue/green deployment pattern support
- Multi-workspace management (master and worker nodes)
- Automated SSH key deployment
- Automated VM provisioning with Terraform installation
- Network configuration via cloud-init

## Quick Start

### Using Vault Module (Recommended for Production)

1. **Set up environment variables:**

```bash
export VAULT_ADDR=https://vault.my-domain-vault.com
export TF_VAR_vault_token=hvs.your-vault-key
export VAULT_TOKEN=hvs.your-vault-key
export TF_ENV=lab
export COMMON_BACKEND="-backend-config=backend.conf"
export BACKEND_STATE_KEY="backends/lab.conf"
```

2. **Navigate to the module:**

```bash
cd modules/proxmox-vault
```

3. **Run the workflow:**

```bash
# Initialize
./init.sh

# Apply
./apply.sh

# Destroy (when needed)
./destroy.sh
```

### Using No-Vault Module (For Development)

1. **Set up environment variables:**

```bash
export TF_ENV=lab
```

2. **Navigate to the module:**

```bash
cd modules/proxmox-no-vault
```

3. **Configure variables:**

```bash
# Copy and edit the example file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

4. **Run the workflow:**

```bash
# Initialize
./init.sh

# Apply
./apply.sh

# Destroy (when needed)
./destroy.sh
```

## Requirements

- **Terraform** >= 1.5.0
- **Provider**: [`Telmate/proxmox`](https://registry.terraform.io/providers/Telmate/proxmox/latest) >= 3.0.0
- Proxmox VE 7.4 or newer with API access enabled
- API token or user/password with appropriate privileges on target resources
- **HashiCorp Vault** (only for proxmox-vault module)

## Workflow Commands

### Initialize Terraform

Initialize Terraform with backend configuration and workspace setup:

**With Vault:**
```bash
terraform init -upgrade \
               -reconfigure \
               $COMMON_BACKEND \
               -backend-config=$BACKEND_STATE_KEY

terraform workspace select $TF_ENV || terraform workspace new $TF_ENV
terraform fmt
```

**Without Vault:**
```bash
terraform init -upgrade \
               -reconfigure \
               ${COMMON_BACKEND:-} \
               ${BACKEND_STATE_KEY:+-backend-config=$BACKEND_STATE_KEY}

terraform workspace select $TF_ENV || terraform workspace new $TF_ENV
terraform fmt
```

### Apply Changes

Deploy your infrastructure:

```bash
terraform fmt
terraform validate
terraform apply --auto-approve
```

### Destroy Infrastructure

Tear down the infrastructure:

```bash
terraform fmt
terraform validate
terraform destroy --auto-approve
```

## Workspace Configuration

Both modules currently support the following workspace:

| Workspace Name | VMID | Memory | Storage |
|----------------|------|--------|---------|
| `lab` | 8000 | 4GB | local |

To add more workspaces (e.g., for blue/green deployments or multiple nodes), edit the `locals.tf` file in the respective module.

## Security Best Practices

### For Vault Module
- Rotate Vault tokens regularly
- Use Vault policies to restrict access to specific paths
- Enable audit logging in Vault
- Never commit Vault tokens to version control

### For No-Vault Module
- **Never commit `terraform.tfvars`** with real credentials
- Add `terraform.tfvars` to `.gitignore`
- Use environment variables in CI/CD pipelines
- Consider encrypting sensitive files at rest
- Rotate credentials regularly
- For production, migrate to the Vault module

## Preparing a Fresh Proxmox Server

1. Create an API token via *Datacenter → Permissions → API Tokens* and note the token ID and secret.
2. (Recommended) Create a cloud-init ready template named `ubuntu-cloud-template`. Proxmox ships cloud-init packages; follow the official guide to turn a cloud image into a template.
3. Ensure the storage locations referenced by the module exist. For a default install, `local` and `local-lvm` are available.
4. Configure appropriate permissions for the API user/token:
   - `VM.Allocate`
   - `VM.Config.*`
   - `VM.Console`
   - `Datastore.AllocateSpace`
   - `Sys.Audit`

## Troubleshooting

### Vault Connection Issues
- Verify `VAULT_ADDR` is correct and accessible
- Check Vault token has not expired
- Ensure Vault policies allow access to the Proxmox secret path

### Proxmox Connection Issues
- Verify API URL is correct (include port 8006)
- Check credentials have appropriate permissions
- Ensure `pm_tls_insecure = true` if using self-signed certificates

### Template Not Found
- Verify the template `ubuntu-cloud-template` exists on the target node
- Check the template is properly configured for cloud-init

## Contributing

When contributing:
1. Test changes in both modules if applicable
2. Update relevant documentation
3. Follow existing code style and patterns
4. Do not commit sensitive information

## License

[Your License Here]

## Support

For issues and questions:
- Check module-specific READMEs
- Review Terraform and Proxmox provider documentation
- Consult Vault documentation for secret management questions
