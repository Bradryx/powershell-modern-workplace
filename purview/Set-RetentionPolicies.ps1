<#
.SYNOPSIS
    Creates baseline retention policies in Microsoft Purview.

.DESCRIPTION
    Connects to the Security & Compliance Center and creates baseline
    retention policies per platform following the naming convention:
    <Scope>-<RetentionPeriod>-<Action>

    Policies created:
    - EXO-7Y-Retain   : Retains Exchange Online content for 7 years
    - SPO-7Y-Retain   : Retains SharePoint Online content for 7 years
    - ODB-7Y-Retain   : Retains OneDrive for Business content for 7 years
    - MIP-7Y-Retain   : Retains Microsoft Teams content for 7 years

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

# Connect to Security & Compliance Center
Connect-IPPSSession

# Define retention period in days (7 years)
$RetentionDays = 2555

# Define policies per platform scope
$Policies = @(
    @{ Name = "EXO-7Y-Retain"; LocationParam = @{ ExchangeLocation  = "All" } },
    @{ Name = "SPO-7Y-Retain"; LocationParam = @{ SharePointLocation = "All" } },
    @{ Name = "ODB-7Y-Retain"; LocationParam = @{ OneDriveLocation   = "All" } },
    @{ Name = "MIP-7Y-Retain"; LocationParam = @{ TeamsChannelLocation = "All" } }
)

foreach ($Policy in $Policies) {
    $Exists = Get-RetentionCompliancePolicy -Identity $Policy.Name -ErrorAction SilentlyContinue

    if ($Exists) {
        Write-Host "Retention policy already exists, skipping: $($Policy.Name)" -ForegroundColor Yellow
    } else {
        New-RetentionCompliancePolicy -Name $Policy.Name @($Policy.LocationParam)
        Write-Host "Retention policy created: $($Policy.Name)" -ForegroundColor Green
    }

    # Create retention rule within the policy
    $RuleName   = "$($Policy.Name)-Rule"
    $ExistsRule = Get-RetentionComplianceRule -Identity $RuleName -ErrorAction SilentlyContinue

    if ($ExistsRule) {
        Write-Host "Retention rule already exists, skipping: $RuleName" -ForegroundColor Yellow
    } else {
        New-RetentionComplianceRule -Name $RuleName -Policy $Policy.Name -RetentionDuration $RetentionDays -RetentionComplianceAction Keep
        Write-Host "Retention rule created: $RuleName" -ForegroundColor Green
    }
}