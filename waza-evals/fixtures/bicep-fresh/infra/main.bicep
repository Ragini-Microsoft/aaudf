targetScope = 'resourceGroup'

@allowed(['bicep', 'avm', 'avm-waf'])
param deploymentFlavor string

param solutionName string = 'myapp'
param location string = 'eastus'
param aiServiceLocation string = location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'st${solutionName}'
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
}

output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.name
