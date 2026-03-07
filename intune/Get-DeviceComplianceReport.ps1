<#
.SYNOPSIS
    Exports a device compliance report from Microsoft Intune.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves the compliance status
    of all managed devices. Exports the results to a CSV file.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-DeviceComplianceReport.ps1
    .\Get-DeviceComplianceReport.ps1 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

param (
    [string] $OutputPath = (Get-Location).Path
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Retrieve all managed devices
Write-Host "Retrieving device compliance status..." -ForegroundColor Cyan

$Devices = Get-MgDeviceManagementManagedDevice -All

if (-not $Devices) {
    Write-Host "No managed devices found." -ForegroundColor Yellow
    exit
}

# Parse results
$Report = $Devices | ForEach-Object {
    [PSCustomObject]@{
        DeviceName       = $_.DeviceName
        Platform         = $_.OperatingSystem
        OSVersion        = $_.OsVersion
        ComplianceState  = $_.ComplianceState
        LastCheckIn      = $_.LastSyncDateTime
        PrimaryUser      = $_.UserPrincipalName
        ManagementState  = $_.ManagementState
        EnrollmentType   = $_.DeviceEnrollmentType
    }
}

# Export to CSV
$FileName   = "DeviceComplianceReport_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green