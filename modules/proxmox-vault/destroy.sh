# See README.md in the root directory for environment setup and workflow commands
# Required environment variables should be set before running this script

terraform fmt
terraform validate
# Tf plan
#terraform apply -input=false "planfile"
terraform destroy --auto-approve


