#Requires -Modules Microsoft.RDInfra.RDPowerShell

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $WvdTenantName,
    [Parameter(Mandatory = $true)]
    [string]
    $AadTenantId,
    # Azure Subscription ID for WVD Tenant
    [Parameter(Mandatory = $true)]
    [string]
    $AzureSubscriptionId,
    # Owner UPN
    [Parameter(Mandatory = $true)]
    [string]
    $OwnerUpn
)

## Create WVD Tenant

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

New-RdsTenant -Name $WvdTenantName -AadTenantId $AadTenantId -AzureSubscriptionId $AzureSubscriptionId

New-RdsRoleAssignment -TenantName $WvdTenantName -SignInName $OwnerUpn -RoleDefinitionName "RDS Owner"

