# Variaveis
rm=rm565277
resourceGroup="rg-catalogo-filmes"
location="chilecentral"
MYSQL_ROOT_PASSWORD=senha-catalogofilmes
MYSQL_DATABASE=db-catalogofilmes
MYSQL_USER=user-catalogofilmes
MYSQL_PASSWORD=senha-catalogofilmes

CONNECTIONSTRINGS='Server=mysql-catalogofilmes;Port=3306;Database=db-catalogofilmes;User=user-catalogofilmes;Password=senha-catalogofilmes;'

acrName="catalogofilmes$rm"
ACRUSERNAME=$(az acr credential show --name $acrName --resource-group $resourceGroup --query username --output tsv)
ACRPASSWORD=$(az acr credential show --name $acrName --resource-group $resourceGroup --query passwords[0].value --output tsv)
keyVaultName="keyvaultfilmes-$rm"

# Registra o Serviço do Key Vault na Assinatura
az provider register --namespace Microsoft.KeyVault

# Criar o Key Vault 
#az keyvault create --name $keyVaultName --resource-group $resourceGroup --location $location
if ! az keyvault show --name "$keyVaultName" --resource-group "$resourceGroup" &> /dev/null; then
  az keyvault create --name "$keyVaultName" --resource-group "$resourceGroup" --location "$location"
else
  echo "Key Vault '$keyVaultName' já existe no Grupo de Recurso '$resourceGroup'."
fi

# Conceder acesso de ADM no Key Vault para nossa Assinatura
az role assignment create \
  --assignee $(az account show --query user.name -o tsv) \
  --role "Key Vault Administrator" \
  --scope /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName

sleep 15

# Armazenar os dados sensíveis
az keyvault secret set --vault-name $keyVaultName --name mysql-root-password --value "$MYSQL_ROOT_PASSWORD"
az keyvault secret set --vault-name $keyVaultName --name mysql-database --value "$MYSQL_DATABASE"
az keyvault secret set --vault-name $keyVaultName --name mysql-user --value "$MYSQL_USER"
az keyvault secret set --vault-name $keyVaultName --name mysql-password --value "$MYSQL_PASSWORD"
az keyvault secret set --vault-name $keyVaultName --name connection-strings --value "$CONNECTIONSTRINGS"
az keyvault secret set --vault-name $keyVaultName --name acr-username --value "$ACRUSERNAME"
az keyvault secret set --vault-name $keyVaultName --name acr-password --value "$ACRPASSWORD"
