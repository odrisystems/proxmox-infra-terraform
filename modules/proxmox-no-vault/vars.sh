export TF_VAR_vault_addr="${VAULT_ADDR}"
export TF_VAR_vault_token="${VAULT_TOKEN}"
export COMMON_BACKEND="-backend-config=endpoint=$(vault kv get -field=S3_MINIO_ENDPOINT ejbest/terraform/s3_minio) \
-backend-config=bucket=$(vault kv get -field=S3_MINIO_BUCKET ejbest/terraform/s3_minio) \
-backend-config=access_key=$(vault kv get -field=S3_MINIO_ACCESS_KEY ejbest/terraform/s3_minio) \
-backend-config=secret_key=$(vault kv get -field=S3_MINIO_SECRET_KEY ejbest/terraform/s3_minio) \
-backend-config=region=$(vault kv get -field=S3_MINIO_REGION ejbest/terraform/s3_minio)"

# export TF_ENV=k8s-base-pve-vm-blue-worker
# export TF_ENV=k8s-base-pve-vm-blue
# export TF_ENV=k8s-base-pve-vm-green-worker
# export TF_ENV=k8s-base-pve-vm-green

export TF_VAR_common_backend=$COMMON_BACKEND

export BACKEND_STATE_KEY="backends/${TF_ENV}.conf"
