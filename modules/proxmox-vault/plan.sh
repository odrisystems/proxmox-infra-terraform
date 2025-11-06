[ -f ".env" ] && source .env
[ -f "vars.sh" ] && source vars.sh


terraform fmt
# Tf plan

terraform workspace select $TF_ENV || terraform workspace new $TF_ENV

terraform plan 



