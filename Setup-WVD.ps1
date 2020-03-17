#Requires -Modules Microsoft.RDInfra.RDPowerShell, AzureAD

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

$ErrorActionPreference = "Stop"

## Create WVD Tenant

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

$RdsTenant = Get-RdsTenant -TenantName $WvdTenantName -ErrorAction SilentlyContinue

if($RdsTenant) {
    Write-Host "Tenant Exists"
}
else {
    Write-Host "Creating new Tenant"
    $RdsTenant = New-RdsTenant -Name $WvdTenantName -AadTenantId $AadTenantId -AzureSubscriptionId $AzureSubscriptionId
}

Write-Host "Adding RDS Owner Role Assignment to $OwnerUpn"

New-RdsRoleAssignment -TenantName $WvdTenantName -SignInName $OwnerUpn -RoleDefinitionName "RDS Owner"



