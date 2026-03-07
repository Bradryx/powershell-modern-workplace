<#
.SYNOPSIS
    Exports MFA registration status per user from Microsoft Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves the MFA registration status
    for all users in the tenant. Exports the results to a CSV file.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-MFAStatusReport.ps1
    .\Get-MFAStatusReport.ps1 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

param (
    [string] $OutputPath = (Get-Location).Path
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All", "User.Read.All"

# Retrieve MFA registration details
Write-Host "Retrieving MFA registration status..." -ForegroundColor Cyan

$Users = Get-MgReportAuthenticationMethodUserRegistrationDetail -All

if (-not $Users) {
    Write-Host "No users found." -ForegroundColor Yellow
    exit
}

# Parse results
$Report = $Users | ForEach-Object {
    [PSCustomObject]@{
        UserPrincipalName        = $_.UserPrincipalName
        DisplayName              = $_.UserDisplayName
        MFARegistered            = $_.IsMfaRegistered
        MFACapable               = $_.IsMfaCapable
        PasswordlessCapable      = $_.IsPasswordlessCapable
        DefaultMFAMethod         = $_.DefaultMfaMethod
        MethodsRegistered        = ($_.MethodsRegistered -join ", ")
        IsSsprRegistered         = $_.IsSsprRegistered
        IsSsprCapable            = $_.IsSsprCapable
    }
}

# Export to CSV
$FileName   = "MFAStatusReport_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green