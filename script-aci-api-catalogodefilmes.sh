# Variáveis
rm=rm565277
resourceGroup="rg-catalogo-filmes"
acrName="catalogofilmes$rm"
aciName="$rm-api-catalogofilmes"
aciNameMysql="$rm-mysql-catalogofilmes"
imageName="$rm-api-catalogo-filmes"
tag="v1"
keyVaultName="keyvaultfilmes-$rm"
mysqlPublicIP=$(az container show --resource-group $resourceGroup --name $aciNameMysql --query ipAddress.ip --output tsv)


# Registra o Serviço de ACI na Assintaura
az provider register --namespace Microsoft.ContainerInstance


# Deploy do Container Api de .NET
az container create \
  --resource-group $resourceGroup \
  --name $aciName \
  --image $acrName.azurecr.io/$imageName:$tag \
  --cpu 1 \
  --memory 1 \
  --os-type Linux \
  --dns-name-label api-dotnet-container-$rm \
  --ports 8080 \
  --registry-login-server $acrName.azurecr.io \
  --registry-username $(az keyvault secret show --vault-name $keyVaultName --name acr-username --query value -o tsv) \
  --registry-password $(az keyvault secret show --vault-name $keyVaultName --name acr-password --query value -o tsv) \
  --environment-variables \
    ConnectionStrings__DefaultConnection=$(az keyvault secret show --name connection-strings --vault-name $keyVaultName --query value -o tsv | sed "s/mysql-catalogofilmes/$mysqlPublicIP/") \
  --restart-policy Always

