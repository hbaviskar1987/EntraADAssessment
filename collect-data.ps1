<#
.SYNOPSIS
    Entra (Azure AD) assessment data collection wrapper.

.DESCRIPTION
    Runs a set of read-only data gathering commands and packages output into a zip.
    Requires: PowerShell 7+, AzureAD/Exchange/ MSOnline modules as needed, and the AzureADAssessment module if available.
    WARNING: Run under least-privileged account and follow customer data handling policy.

.PARAMETER OutputFolder
    Where to place collected artifacts (default: .\EntraAssessmentOutput)

.EXAMPLE
    .\collect-data.ps1 -OutputFolder C:\Temp\EntraAssessment
#>

param(
    [string]$OutputFolder = ".\EntraAssessmentOutput",
    [switch]$IncludeAADCConfig = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory | Out-Null
    }
}

# Create output structure
$OutputFolder = (Resolve-Path $OutputFolder).Path
Ensure-Directory -Path $OutputFolder
$ts = (Get-Date).ToString('yyyyMMdd-HHmmss')
$collectorRoot = Join-Path $OutputFolder "EntraAssessment-$ts"
Ensure-Directory -Path $collectorRoot

Write-Host "Collector root: $collectorRoot"

# Helper to run Graph queries (requires Microsoft.Graph module)
function Run-GraphQuery {
    param([string]$Name, [scriptblock]$Script)
    $out = Join-Path $collectorRoot "$Name.json"
    try {
        & $Script | ConvertTo-Json -Depth 6 | Out-File -FilePath $out -Encoding utf8
        Write-Host "Saved $Name"
    } catch {
        Write-Warning "Failed to collect $Name: $_"
    }
}

# Example collections (read-only)
# Note: Adjust modules/commands to your environment (AzureAD, MSGraph, Microsoft.Graph)
Write-Host "Collecting tenant information..."
try {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber -ErrorAction SilentlyContinue | Out-Null
    Import-Module Microsoft.Graph -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Microsoft.Graph module not available. Some collections may fail."
}

# Connect prompt (interactive)
Write-Host "You will be prompted to authenticate to Microsoft Graph with required permissions (read-only recommended)."
try {
    Connect-MgGraph -Scopes "Directory.Read.All","AuditLog.Read.All","Policy.Read.All","Application.Read.All"
} catch {
    Write-Warning "Connect-MgGraph failed - ensure you have the required modules and permissions."
}

# Collect a set of core tenant items
Run-GraphQuery -Name "tenant" -Script { Get-MgOrganization }
Run-GraphQuery -Name "domains" -Script { Get-MgDomain -All }
Run-GraphQuery -Name "licenses" -Script { Get-MgSubscribedSku -All }
Run-GraphQuery -Name "users" -Script { Get-MgUser -All -Property "id,displayName,userPrincipalName,accountEnabled" }
Run-GraphQuery -Name "groups" -Script { Get-MgGroup -All -Property "id,displayName,mailEnabled,securityEnabled" }
Run-GraphQuery -Name "applications" -Script { Get-MgServicePrincipal -All -Property "id,displayName,appId,servicePrincipalType" }
Run-GraphQuery -Name "conditionalAccessPolicies" -Script { Get-MgConditionalAccessPolicy -All }
Run-GraphQuery -Name "riskDetections" -Script { Get-MgIdentityRiskDetection -All }  # May require specific permissions
Run-GraphQuery -Name "signIns" -Script { Get-MgAuditLogSignIn -All }  # consider time range in production

# Export role assignments
Run-GraphQuery -Name "directoryRoles" -Script { Get-MgDirectoryRole -All }

# Optionally include Azure AD Connect config (requires access to AADConnect server)
if ($IncludeAADCConfig) {
    Write-Host "Including AAD Connect config export step - ensure access to the AADConnect server."
    # Placeholder: instruct user to run AAD Connect documenter and copy zip file into output.
    Write-Host "Please run the Azure AD Connect Documenter on the AADConnect server and copy the produced zip to the output folder."
}

# Package results
$zipPath = Join-Path $OutputFolder ("EntraAssessmentArtifacts-$ts.zip")
Write-Host "Creating zip: $zipPath"
Compress-Archive -Path (Join-Path $collectorRoot "*") -DestinationPath $zipPath -Force

Write-Host "Collection complete. Artifacts zipped to: $zipPath"