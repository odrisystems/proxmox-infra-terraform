#!/bin/bash
# Proxmox-Vault Module - Init Script
# 
# This module uses HashiCorp Vault for managing sensitive variables and configuration.
# 
# Required environment variables:
# VAULT_ADDR=https://vault.my-domain-vault.com 
# TF_VAR_vault_token=hvs.key
# VAULT_TOKEN=hvs.key
# TF_ENV=your-workspace-name
# COMMON_BACKEND="-backend-config=your-backend-config"
# BACKEND_STATE_KEY="backends/your-state-file.conf"
# 
# See README.md in the root directory for detailed workflow commands

terraform init -upgrade  \
                -reconfigure \
                $COMMON_BACKEND \
                -backend-config=$BACKEND_STATE_KEY

echo "Switch to terraform workspace"
terraform workspace select $TF_ENV || terraform workspace new $TF_ENV

terraform fmt
