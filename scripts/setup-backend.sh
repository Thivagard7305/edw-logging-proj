#!/bin/bash
set -e

LOCATION="eastus"
RG_NAME="rg-terraform-state"
ENVIRONMENTS=("dev" "staging" "prod")

echo "Creating backend storage..."

az group create --name $RG_NAME --location $LOCATION

for ENV in "${ENVIRONMENTS[@]}"; do
    STORAGE_NAME="stterraformstate${ENV}"
    
    az storage account create \
        --name $STORAGE_NAME \
        --resource-group $RG_NAME \
        --location $LOCATION \
        --sku Standard_LRS \
        --encryption-services blob \
        --https-only true \
        --min-tls-version TLS1_2
    
    az storage container create \
        --name tfstate \
        --account-name $STORAGE_NAME \
        --auth-mode login
    
    echo "✓ Backend created for $ENV"
done