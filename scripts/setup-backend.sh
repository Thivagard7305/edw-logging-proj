#!/bin/bash
set -e

LOCATION="eastus"
RG_NAME="rg-edwproj-loggin"
ENVIRONMENTS=("dev" "staging" "prod")

echo "Creating backend storage..."

for ENV in "${ENVIRONMENTS[@]}"; do
    RG_NAME="rg-edwproj-logging-${ENV}"
    STORAGE_NAME="edwprojloggingsa${ENV}"

    echo "Environment: $ENV"
    echo "Resource Group: $RG_NAME"
    az group create --name $RG_NAME --location $LOCATION -o none

    if az storage account show \
        --name $STORAGE_NAME \
        --resource-group $RG_NAME \
        >/dev/null 2>&1; then
        echo "ℹ Storage account already exists: $STORAGE_NAME"
    else
    
        az storage account create \
            --name $STORAGE_NAME \
            --resource-group $RG_NAME \
            --location $LOCATION \
            --sku Standard_LRS \
            --encryption-services blob \
            --https-only true \
            --min-tls-version TLS1_2
        echo "✓ Storage account created: $STORAGE_NAME"
    fi
        az storage container create \
            --name edw-logging-tfstate-cont \
            --account-name $STORAGE_NAME \
            --auth-mode login
        
        echo "✓ Backend created for $ENV"
done