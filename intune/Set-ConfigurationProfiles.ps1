<#
.SYNOPSIS
    Creates baseline configuration profiles in Microsoft Intune.

.DESCRIPTION
    Connects to Microsoft Graph and creates baseline security configuration
    profiles for Windows and macOS using the Settings Catalog.

    Profiles created:
    - WIN-SecurityBaseline-Config
    - MAC-SecurityBaseline-Config

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

# Define configuration profiles
$Profiles = @(
    @{
        DisplayName  = "WIN-SecurityBaseline-Config"
        Platform     = "windows10"
        Technologies = "mdm"
        Settings     = @(
            @{
                "@odata.type"  = "#microsoft.graph.deviceManagementConfigurationSetting"
                settingInstance = @{
                    "@odata.type"            = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                    settingDefinitionId      = "device_vendor_msft_policy_config_defender_allowrealtimemonitoring"
                    choiceSettingValue       = @{
                        value = "device_vendor_msft_policy_config_defender_allowrealtimemonitoring_1"
                    }
                }
            }
        )
    },
    @{
        DisplayName  = "MAC-SecurityBaseline-Config"
        Platform     = "macOS"
        Technologies = "mdm"
        Settings     = @(
            @{
                "@odata.type"  = "#microsoft.graph.deviceManagementConfigurationSetting"
                settingInstance = @{
                    "@odata.type"            = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                    settingDefinitionId      = "com.apple.screensaver_askforpassword"
                    choiceSettingValue       = @{
                        value = "com.apple.screensaver_askforpassword_1"
                    }
                }
            }
        )
    }
)

foreach ($Profile in $Profiles) {
    $Exists = Get-MgDeviceManagementConfigurationPolicy | Where-Object { $_.Name -eq $Profile.DisplayName }

    if ($Exists) {
        Write-Host "Configuration profile already exists, skipping: $($Profile.DisplayName)" -ForegroundColor Yellow
    } else {
        $Body = @{
            name         = $Profile.DisplayName
            platforms    = $Profile.Platform
            technologies = $Profile.Technologies
            settings     = $Profile.Settings
        }

        New-MgDeviceManagementConfigurationPolicy -BodyParameter $Body
        Write-Host "Configuration profile created: $($Profile.DisplayName)" -ForegroundColor Green
    }
}