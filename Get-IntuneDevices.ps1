<#
.SYNOPSIS
    Retrieves all devices from Microsoft Intune.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves all managed devices
    from Microsoft Intune. Outputs the device name, OS, and compliance state.

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Retrieve all managed devices
$Devices = Get-MgDeviceManagementManagedDevice -All

# Output relevant properties
$Devices | Select-Object DeviceName, OperatingSystem, ComplianceState | Format-Table -AutoSize