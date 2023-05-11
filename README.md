# devsecops-class-boto3-automation

terraform init -reconfigure -input=false -backend-config="backend.tfconfig"

terraform validate

terraform fmt --recursive

terraform plan

terraform apply -auto-approve
