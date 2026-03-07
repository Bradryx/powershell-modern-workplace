<#
.SYNOPSIS
    Exports stale devices from Microsoft Intune.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves all managed devices that
    have not checked in for a specified number of days.
    Exports the results to a CSV file for review and cleanup.

.PARAMETER DaysInactive
    Number of days since last check-in to consider a device stale.
    Defaults to 30 days.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-StaleDevices.ps1
    .\Get-StaleDevices.ps1 -DaysInactive 60
    .\Get-StaleDevices.ps1 -DaysInactive 90 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

param (
    [int]    $DaysInactive = 30,
    [string] $OutputPath   = (Get-Location).Path
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Calculate cutoff date
$CutoffDate = (Get-Date).AddDays(-$DaysInactive)

# Retrieve all managed devices
Write-Host "Retrieving devices inactive since $($CutoffDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

$Devices = Get-MgDeviceManagementManagedDevice -All | Where-Object {
    $_.LastSyncDateTime -lt $CutoffDate
}

if (-not $Devices) {
    Write-Host "No stale devices found." -ForegroundColor Yellow
    exit
}

Write-Host "$($Devices.Count) stale device(s) found." -ForegroundColor Cyan

# Parse results
$Report = $Devices | ForEach-Object {
    [PSCustomObject]@{
        DeviceName      = $_.DeviceName
        Platform        = $_.OperatingSystem
        OSVersion       = $_.OsVersion
        LastCheckIn     = $_.LastSyncDateTime
        DaysInactive    = (New-TimeSpan -Start $_.LastSyncDateTime -End (Get-Date)).Days
        PrimaryUser     = $_.UserPrincipalName
        ComplianceState = $_.ComplianceState
        EnrollmentType  = $_.DeviceEnrollmentType
    }
}

# Export to CSV
$FileName   = "StaleDevices_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green