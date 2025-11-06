#!/bin/bash
# Proxmox-No-Vault Module - Init Script
# 
# This module uses direct Terraform variables instead of HashiCorp Vault.
# 
# Required environment variables:
# TF_ENV=lab (or your workspace name)
# COMMON_BACKEND="-backend-config=your-backend-config" (optional)
# BACKEND_STATE_KEY="backends/lab.conf" (optional)
# 
# You'll need to provide variables via terraform.tfvars or TF_VAR_* environment variables
# See terraform.tfvars.example for required variables
# See README.md in the root directory for detailed workflow commands

terraform init -upgrade  \
                -reconfigure \
                ${COMMON_BACKEND:-} \
                ${BACKEND_STATE_KEY:+-backend-config=$BACKEND_STATE_KEY}

echo "Switch to terraform workspace"
terraform workspace select $TF_ENV || terraform workspace new $TF_ENV

terraform fmt
