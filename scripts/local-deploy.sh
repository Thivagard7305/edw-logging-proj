#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: ./local-deploy.sh <environment>"
    exit 1
fi

ENV=$1
cd "environments/$ENV"

echo "Deploying to $ENV..."

terraform init -backend-config=backend.hcl -reconfigure
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan

echo "✓ Deployment complete!"
terraform output