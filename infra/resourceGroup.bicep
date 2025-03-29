targetScope = 'subscription'

param applicationName string
param location string
param env string

var tags = {
  ApplicationName: applicationName
  Environment: env
}

module resourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'resource-group-deploment'
  params: {
    name: '${applicationName}-rg-01'
    location: location
    tags: tags
  }
}
