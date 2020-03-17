#Requires -Module Az.Resources

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $DomainName,

    [Parameter(Mandatory = $true)]
    [string] 
    $ResourceGroupName,

    [Parameter()]
    [string]
    $Location = "westus2",

    [Parameter()]
    [string]
    $TemplateFile = ".\Templates\domainservicestemplate.json"
    
)


$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))

$DeploymentName = ((Split-Path $TemplateFile -Leaf) + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))

Write-Host "Using template file: $TemplateFile"

$TemplateArgs = New-Object -TypeName Hashtable

$TemplateArgs.Add('domainName', $DomainName)

$TemplateArgs.Add('location', $Location)

if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
}

$ErrorActionPreference = 'Continue' # Switch to Continue" so multiple errors can be formatted and output

New-AzResourceGroupDeployment -Name $DeploymentName `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            @TemplateArgs `
            -Force -Verbose `
            -ErrorVariable ErrorMessages

$ErrorActionPreference = 'Stop' 
if ($ErrorMessages) {
    Write-Output '', 'Template deployment returned the following errors:', '', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message })
    Write-Error "Deployment failed."
}