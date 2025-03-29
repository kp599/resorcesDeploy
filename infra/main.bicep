param applicationName string
param location string
param administratorLogin string
@secure()
param administratorLoginPassword string
param env string

var tags = {
  ApplicationName: applicationName
  Environment: env
}

module keyVault 'br/public:avm/res/key-vault/vault:0.12.1' = {
  name: 'keyVaultDeployment'
  params: {
    name: '${applicationName}kv01'
    sku: 'standard'
    location: location
    tags: tags
    enablePurgeProtection: false
    enableRbacAuthorization: true
    enableSoftDelete: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

module sqlServer 'br/public:avm/res/sql/server:0.12.3' = {
  name: 'sql-server-deployment'
  params: {
    name: '${applicationName}-sqls-01'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    tags: tags
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.17.3' = {
  name: 'storage-account-deployment'
  params: {
    name: '${applicationName}sta01'
    location: location
    tags: tags
    accessTier: 'Cold'
    skuName: 'Standard_LRS'
    allowBlobPublicAccess: true
    publicNetworkAccess: 'Enabled'
    allowSharedKeyAccess: true
    kind: 'StorageV2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
  }
}

module appServicePlan 'br/public:avm/res/web/serverfarm:0.4.1' = {
  name: 'appServicePlanDeployment'
  params: {
    name: '${applicationName}-asp-01'
    location: location
    kind: 'windows'
    tags: tags
    zoneRedundant: false
    skuName: 'B1'
    skuCapacity: 1
  }
}

module appService 'br/public:avm/res/web/site:0.15.1' = {
  name: 'appServiceDeployment'
  params: {
    name: '${applicationName}-as-01'
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    tags: tags
    location: location
    clientCertEnabled: true
    clientCertMode: 'OptionalInteractiveUser'
    httpsOnly: true
    managedIdentities: {
      systemAssigned: true
    }
    publicNetworkAccess: 'Enabled'
  }
}
