<#
.SYNOPSIS
    Creates baseline compliance policies in Microsoft Intune.

.DESCRIPTION
    Connects to Microsoft Graph and creates baseline compliance policies
    for Windows, macOS, iOS/iPadOS, and Android platforms.

    Policies created:
    - WIN-Compliance-Baseline
    - MAC-Compliance-Baseline
    - IOS-Compliance-Baseline
    - AND-Compliance-Baseline

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

# Define compliance policies per platform
$Policies = @(
    @{
        DisplayName = "WIN-Compliance-Baseline"
        Platform    = "windows10CompliancePolicy"
        Settings    = @{
            passwordRequired                   = $true
            passwordMinimumLength              = 12
            bitLockerEnabled                   = $true
            secureBootEnabled                  = $true
            codeIntegrityEnabled               = $true
            storageRequireEncryption           = $true
            activeFirewallRequired             = $true
            defenderEnabled                    = $true
            osMinimumVersion                   = "10.0.19041"
        }
    },
    @{
        DisplayName = "MAC-Compliance-Baseline"
        Platform    = "macOSCompliancePolicy"
        Settings    = @{
            passwordRequired                   = $true
            passwordMinimumLength              = 12
            storageRequireEncryption           = $true
            firewallEnabled                    = $true
            osMinimumVersion                   = "13.0"
        }
    },
    @{
        DisplayName = "IOS-Compliance-Baseline"
        Platform    = "iosCompliancePolicy"
        Settings    = @{
            passcodeRequired                   = $true
            passcodeMinimumLength              = 6
            managedEmailProfileRequired        = $true
            osMinimumVersion                   = "16.0"
        }
    },
    @{
        DisplayName = "AND-Compliance-Baseline"
        Platform    = "androidCompliancePolicy"
        Settings    = @{
            passwordRequired                   = $true
            passwordMinimumLength              = 6
            storageRequireEncryption           = $true
            securityBlockJailbrokenDevices     = $true
            osMinimumVersion                   = "12.0"
        }
    }
)

foreach ($Policy in $Policies) {
    $Exists = Get-MgDeviceManagementDeviceCompliancePolicy | Where-Object { $_.DisplayName -eq $Policy.DisplayName }

    if ($Exists) {
        Write-Host "Compliance policy already exists, skipping: $($Policy.DisplayName)" -ForegroundColor Yellow
    } else {
        $Body = @{
            "@odata.type" = "#microsoft.graph.$($Policy.Platform)"
            displayName   = $Policy.DisplayName
        } + $Policy.Settings

        New-MgDeviceManagementDeviceCompliancePolicy -BodyParameter $Body
        Write-Host "Compliance policy created: $($Policy.DisplayName)" -ForegroundColor Green
    }
}