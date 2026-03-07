<#
.SYNOPSIS
    Exports a sensitivity label usage report from Microsoft Purview.

.DESCRIPTION
    Connects to the Security & Compliance Center and retrieves sensitivity
    label activity from the Unified Audit Log for a specified date range.
    Exports the results to a CSV file for reporting purposes.

    Activity types included:
    - FileSensitivityLabelApplied
    - FileSensitivityLabelChanged
    - FileSensitivityLabelRemoved

.PARAMETER StartDate
    Start date for the audit log query. Defaults to 7 days ago.

.PARAMETER EndDate
    End date for the audit log query. Defaults to today.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-SensitivityLabelReport.ps1
    .\Get-SensitivityLabelReport.ps1 -StartDate "2024-01-01" -EndDate "2024-01-31"
    .\Get-SensitivityLabelReport.ps1 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

param (
    [datetime] $StartDate  = (Get-Date).AddDays(-7),
    [datetime] $EndDate    = (Get-Date),
    [string]   $OutputPath = (Get-Location).Path
)

# Connect to Security & Compliance Center
Connect-IPPSSession

# Define label activity types
$ActivityTypes = @(
    "FileSensitivityLabelApplied",
    "FileSensitivityLabelChanged",
    "FileSensitivityLabelRemoved"
)

# Retrieve sensitivity label activity from Unified Audit Log
Write-Host "Retrieving sensitivity label activity from $StartDate to $EndDate..." -ForegroundColor Cyan

$Results = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Operations $ActivityTypes -ResultSize 5000

if (-not $Results) {
    Write-Host "No sensitivity label activity found for the specified date range." -ForegroundColor Yellow
    exit
}

# Parse and export results
$ParsedResults = $Results | ForEach-Object {
    $AuditData = $_.AuditData | ConvertFrom-Json
    [PSCustomObject]@{
        Timestamp        = $_.CreationDate
        User             = $AuditData.UserId
        Activity         = $_.Operations
        FileName         = $AuditData.DestinationFileName ?? $AuditData.ObjectId
        Platform         = $AuditData.Workload
        LabelApplied     = $AuditData.SensitivityLabelEventData.SensitivityLabelId
        LabelPrevious    = $AuditData.SensitivityLabelEventData.OldSensitivityLabelId ?? "N/A"
    }
}

# Export to CSV
$FileName   = "SensitivityLabelReport_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$ParsedResults | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green