# Variaveis
rm=rm565277
resourceGroup="rg-catalogo-filmes"
acrName="catalogofilmes$rm"
aciName="$rm-mysql-catalogofilmes"
imageName="$rm-mysql-catalogo-filmes"
tag="v1"
storageAccountName="volumefilmesdata$rm"
file_share_name="mysql-catalogofilmes-volume"
storage_key=$(az storage account keys list --resource-group $resourceGroup --account-name $storageAccountName --query "[0].value" --output tsv)
keyVaultName="keyvaultfilmes-$rm"

# Registra o Serviço de ACI na Assinatura
az provider register --namespace Microsoft.ContainerInstance

# Deploy do Container MySQL
az container create \
  --resource-group $resourceGroup \
  --name $aciName \
  --image $acrName.azurecr.io/$imageName:$tag \
  --cpu 1 \
  --memory 1 \
  --os-type Linux \
  --dns-name-label mysql-container-$rm \
  --ports 3306 \
  --registry-login-server $acrName.azurecr.io \
  --registry-username $(az keyvault secret show --vault-name $keyVaultName --name acr-username --query value -o tsv) \
  --registry-password $(az keyvault secret show --vault-name $keyVaultName --name acr-password --query value -o tsv) \
  --azure-file-volume-account-name $storageAccountName \
  --azure-file-volume-account-key $storage_key \
  --azure-file-volume-share-name $file_share_name \
  --azure-file-volume-mount-path /var/lib/mysql \
  --environment-variables \
    MYSQL_ROOT_PASSWORD=$(az keyvault secret show --vault-name $keyVaultName --name mysql-root-password --query value -o tsv) \
    MYSQL_DATABASE=$(az keyvault secret show --vault-name $keyVaultName --name mysql-database --query value -o tsv) \
    MYSQL_USER=$(az keyvault secret show --vault-name $keyVaultName --name mysql-user --query value -o tsv) \
    MYSQL_PASSWORD=$(az keyvault secret show --vault-name $keyVaultName --name mysql-password --query value -o tsv) \
  --restart-policy Always
