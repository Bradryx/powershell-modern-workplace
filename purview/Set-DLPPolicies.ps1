<#
.SYNOPSIS
    Creates a baseline DLP policy in Microsoft Purview.

.DESCRIPTION
    Connects to the Security & Compliance Center and creates baseline
    DLP policies per platform following the naming convention:
    <Scope>-<SIT>-<Action>

    Policies created:
    - EXO-GDPR-Warn   : Warns on GDPR-related sensitive info in Exchange Online
    - SPO-GDPR-Warn   : Warns on GDPR-related sensitive info in SharePoint Online
    - ODB-GDPR-Warn   : Warns on GDPR-related sensitive info in OneDrive for Business
    - MIP-GDPR-Warn   : Warns on GDPR-related sensitive info in Microsoft Teams

    Sensitive information types included:
    - Credit Card Number
    - EU National Identification Number
    - International Banking Account Number (IBAN)

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

# Connect to Security & Compliance Center
Connect-IPPSSession

# Define sensitive information types
$SensitiveInfoTypes = @(
    @{ Name = "Credit Card Number" },
    @{ Name = "EU National Identification Number" },
    @{ Name = "International Banking Account Number (IBAN)" }
)

# Define policies per platform scope
$Policies = @(
    @{ Name = "EXO-GDPR-Warn"; Location = "Exchange";   LocationParam = @{ ExchangeLocation  = "All" } },
    @{ Name = "SPO-GDPR-Warn"; Location = "SharePoint"; LocationParam = @{ SharePointLocation = "All" } },
    @{ Name = "ODB-GDPR-Warn"; Location = "OneDrive";   LocationParam = @{ OneDriveLocation   = "All" } },
    @{ Name = "MIP-GDPR-Warn"; Location = "Teams";      LocationParam = @{ TeamsLocation       = "All" } }
)

foreach ($Policy in $Policies) {
    # Create DLP policy
    $ExistsPolicy = Get-DlpCompliancePolicy -Identity $Policy.Name -ErrorAction SilentlyContinue

    if ($ExistsPolicy) {
        Write-Host "DLP policy already exists, skipping: $($Policy.Name)" -ForegroundColor Yellow
    } else {
        New-DlpCompliancePolicy -Name $Policy.Name @($Policy.LocationParam)
        Write-Host "DLP policy created: $($Policy.Name)" -ForegroundColor Green
    }

    # Create DLP rule within the policy
    $RuleName   = "$($Policy.Name)-Rule"
    $ExistsRule = Get-DlpComplianceRule -Identity $RuleName -ErrorAction SilentlyContinue

    if ($ExistsRule) {
        Write-Host "DLP rule already exists, skipping: $RuleName" -ForegroundColor Yellow
    } else {
        New-DlpComplianceRule -Name $RuleName -Policy $Policy.Name -ContentContainsSensitiveInformation $SensitiveInfoTypes -GenerateIncidentReport "SiteAdmin" -NotifyUser "LastModifier"
        Write-Host "DLP rule created: $RuleName" -ForegroundColor Green
    }
}