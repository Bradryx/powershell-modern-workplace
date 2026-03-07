<#
.SYNOPSIS
    Exports stale guest accounts from Microsoft Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves all guest accounts that
    have not signed in for a specified number of days or have never
    signed in. Exports the results to a CSV file for review and cleanup.

.PARAMETER DaysInactive
    Number of days since last sign-in to consider a guest account stale.
    Defaults to 90 days.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-StaleGuestAccounts.ps1
    .\Get-StaleGuestAccounts.ps1 -DaysInactive 60
    .\Get-StaleGuestAccounts.ps1 -DaysInactive 90 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

param (
    [int]    $DaysInactive = 90,
    [string] $OutputPath   = (Get-Location).Path
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All"

# Calculate cutoff date
$CutoffDate = (Get-Date).AddDays(-$DaysInactive)

# Retrieve all guest accounts
Write-Host "Retrieving guest accounts inactive since $($CutoffDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

$Guests = Get-MgUser -Filter "userType eq 'Guest'" -Property "DisplayName,UserPrincipalName,Mail,CreatedDateTime,SignInActivity" -All

# Filter stale guests
$StaleGuests = $Guests | Where-Object {
    $_.SignInActivity.LastSignInDateTime -lt $CutoffDate -or
    $null -eq $_.SignInActivity.LastSignInDateTime
}

if (-not $StaleGuests) {
    Write-Host "No stale guest accounts found." -ForegroundColor Yellow
    exit
}

Write-Host "$($StaleGuests.Count) stale guest account(s) found." -ForegroundColor Cyan

# Parse results
$Report = $StaleGuests | ForEach-Object {
    [PSCustomObject]@{
        DisplayName       = $_.DisplayName
        UserPrincipalName = $_.UserPrincipalName
        Mail              = $_.Mail
        CreatedDateTime   = $_.CreatedDateTime
        LastSignIn        = $_.SignInActivity.LastSignInDateTime ?? "Never"
        DaysInactive      = if ($_.SignInActivity.LastSignInDateTime) {
                                (New-TimeSpan -Start $_.SignInActivity.LastSignInDateTime -End (Get-Date)).Days
                            } else { "N/A" }
    }
}

# Export to CSV
$FileName   = "StaleGuestAccounts_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green