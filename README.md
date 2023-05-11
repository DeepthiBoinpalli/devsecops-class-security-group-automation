# devsecops-class-boto3-automation

## Pre-reqs

- Configure SNS topic before you test anything

## Steps to deploy

```
terraform init -reconfigure -input=false -backend-config="backend.tfconfig"

terraform validate

terraform fmt --recursive

terraform plan

terraform apply -auto-approve
```

## Detective Control

![Image Description](Detective-Control.jpg) <br>

## Preventive Control

![Image Description](Preventive-Control.jpg) <br>
