#Requires -Modules Microsoft.RDInfra.RDPowerShell, AzureAD

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $WvdTenantName,
    [Parameter(Mandatory = $true)]
    [string]
    $AadTenantId
)

Write-Host "Logging into Azure AD
"

$aadContext = Connect-AzureAD

Write-Host "Creating Service Principal
"
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName "Windows Virtual Desktop Svc Principal" -ErrorAction Continue
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId

Write-Host "AppId: $($svcPrincipal.AppId)"
Write-Host "TenantId: $($aadContext.TenantId.Guid)"
Write-Host "Password: $($svcPrincipalCreds.Value)"
Write-Host ""

Write-Host "Adding Service Principal Role Assignment"
New-RdsRoleAssignment -RoleDefinitionName "RDS Owner" -ApplicationId $svcPrincipal.AppId -TenantName $WvdTenantName

Write-Host ""
Write-Host "Signing in with service principal"

$creds = New-Object System.Management.Automation.PSCredential($svcPrincipal.AppId, (ConvertTo-SecureString $svcPrincipalCreds.Value -AsPlainText -Force))
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -Credential $creds -ServicePrincipal -AadTenantId $aadContext.TenantId.Guid