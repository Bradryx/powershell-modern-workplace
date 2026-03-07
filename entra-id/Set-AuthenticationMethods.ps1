<#
.SYNOPSIS
    Configures authentication methods in Microsoft Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and enables all recommended authentication
    methods for the tenant, including Microsoft Authenticator, FIDO2,
    Temporary Access Pass, SMS, Voice, and Certificate-Based Authentication.

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.ReadWrite.AuthenticationMethod"

# Enable Microsoft Authenticator
Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
    -AuthenticationMethodConfigurationId "microsoftAuthenticator" `
    -BodyParameter @{
        "@odata.type" = "#microsoft.graph.microsoftAuthenticatorAuthenticationMethodConfiguration"
        state         = "enabled"
        featureSettings = @{
            displayAppInformationRequiredState = @{ state = "enabled" }
            displayLocationInformationRequiredState = @{ state = "enabled" }
        }
    }
Write-Host "Microsoft Authenticator: enabled" -ForegroundColor Green

# Enable FIDO2
Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
    -AuthenticationMethodConfigurationId "fido2" `
    -BodyParameter @{
        "@odata.type"      = "#microsoft.graph.fido2AuthenticationMethodConfiguration"
        state              = "enabled"
        isAttestationEnforced = $true
        isSelfServiceRegistrationAllowed = $true
    }
Write-Host "FIDO2: enabled" -ForegroundColor Green

# Enable Temporary Access Pass
Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
    -AuthenticationMethodConfigurationId "temporaryAccessPass" `
    -BodyParameter @{
        "@odata.type"         = "#microsoft.graph.temporaryAccessPassAuthenticationMethodConfiguration"
        state                 = "enabled"
        defaultLifetimeInMinutes = 60
        defaultLength         = 8
        isUsableOnce          = $true
    }
Write-Host "Temporary Access Pass: enabled" -ForegroundColor Green

# Enable SMS
Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
    -AuthenticationMethodConfigurationId "sms" `
    -BodyParameter @{
        "@odata.type" = "#microsoft.graph.smsAuthenticationMethodConfiguration"
        state         = "enabled"
    }
Write-Host "SMS: enabled" -ForegroundColor Green

# Enable Voice
Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
    -AuthenticationMethodConfigurationId "voice" `
    -BodyParameter @{
        "@odata.type" = "#microsoft.graph.voiceAuthenticationMethodConfiguration"
        state         = "enabled"
    }
Write-Host "Voice: enabled" -ForegroundColor Green