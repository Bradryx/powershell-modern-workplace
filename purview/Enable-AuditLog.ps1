<#
.SYNOPSIS
    Enables the Unified Audit Log in Microsoft Purview.

.DESCRIPTION
    Connects to Exchange Online and enables the Unified Audit Log
    for the tenant. Also validates the current audit log status
    and outputs the result.

    Recommended to run as a baseline configuration step during
    tenant onboarding.

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Check current audit log status
$AuditConfig = Get-AdminAuditLogConfig

if ($AuditConfig.UnifiedAuditLogIngestionEnabled) {
    Write-Host "Unified Audit Log is already enabled." -ForegroundColor Yellow
} else {
    # Enable Unified Audit Log
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
    Write-Host "Unified Audit Log has been enabled." -ForegroundColor Green
}

# Validate and output result
$AuditConfig = Get-AdminAuditLogConfig
Write-Host "Current Unified Audit Log status: $($AuditConfig.UnifiedAuditLogIngestionEnabled)" -ForegroundColor Cyan