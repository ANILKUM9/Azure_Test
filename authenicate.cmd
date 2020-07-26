az login --service-principal -u %TF_VAR_client_id% -p %TF_VAR_client_secret% -t %TF_VAR_tenant_id%


az vm image list-publishers -l westus2 -o table
az vm image list-offers -l westus2 -p MicrosoftWindowsServer -o table
az vm image list-skus -l westus2 -p MicrosoftWindowsServer -f WindowsServer -o table


az vm list-sizes -l westus2 -o table