using '../main.bicep'

// Per-environment parameters for the `dev` stage. The CI/CD pipeline (_infra.yml)
// reads `resourceGroupName` to target the deployment; keep only values that differ
// per environment here.

param resourceGroupName = 'rg-aaudf-dev'
param deploymentFlavor = 'bicep'
param solutionName = 'aaudf-dev'
param location = 'eastus'
param azureAiServiceLocation = 'eastus'
param useUserAccessToken = false
param deployingUserPrincipalType = 'ServicePrincipal'
