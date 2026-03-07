<#
.SYNOPSIS
    Creates baseline Conditional Access policies in Microsoft Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and creates baseline Conditional Access
    policies following the naming convention:
    <Target>-<Condition>-<Action>

    Policies created:
    - ALL-MFA-Require          : Requires MFA for all users and all apps
    - ALL-CompliantDevice-Require : Requires compliant device for all users
    - ADM-NamedLocation-Block  : Blocks admin access from outside named locations

.PARAMETER NamedLocationId
    Object ID of the named location to use for admin access restriction.
    Run Get-MgIdentityConditionalAccessNamedLocation to retrieve IDs.

.EXAMPLE
    .\Set-ConditionalAccessPolicies.ps1 -NamedLocationId "00000000-0000-0000-0000-000000000000"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

param (
    [Parameter(Mandatory = $true)]
    [string] $NamedLocationId
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess", "Policy.Read.All"

# Define Conditional Access policies
$Policies = @(
    @{
        DisplayName = "ALL-MFA-Require"
        State       = "enabledForReportingButNotEnforced"
        Conditions  = @{
            Users = @{
                IncludeUsers = @("All")
                ExcludeRoles = @("62e90394-69f5-4237-9190-012177145e10") # Global Administrator
            }
            Applications = @{
                IncludeApplications = @("All")
            }
        }
        GrantControls = @{
            Operator        = "OR"
            BuiltInControls = @("mfa")
        }
    },
    @{
        DisplayName = "ALL-CompliantDevice-Require"
        State       = "enabledForReportingButNotEnforced"
        Conditions  = @{
            Users = @{
                IncludeUsers = @("All")
                ExcludeRoles = @("62e90394-69f5-4237-9190-012177145e10") # Global Administrator
            }
            Applications = @{
                IncludeApplications = @("All")
            }
            Platforms = @{
                IncludePlatforms = @("windows", "macOS")
            }
        }
        GrantControls = @{
            Operator        = "OR"
            BuiltInControls = @("compliantDevice")
        }
    },
    @{
        DisplayName = "ADM-NamedLocation-Block"
        State       = "enabledForReportingButNotEnforced"
        Conditions  = @{
            Users = @{
                IncludeRoles = @("62e90394-69f5-4237-9190-012177145e10") # Global Administrator
            }
            Applications = @{
                IncludeApplications = @("All")
            }
            Locations = @{
                IncludeLocations = @("All")
                ExcludeLocations = @($NamedLocationId)
            }
        }
        GrantControls = @{
            Operator        = "OR"
            BuiltInControls = @("block")
        }
    }
)

foreach ($Policy in $Policies) {
    $Exists = Get-MgIdentityConditionalAccessPolicy | Where-Object { $_.DisplayName -eq $Policy.DisplayName }

    if ($Exists) {
        Write-Host "Conditional Access policy already exists, skipping: $($Policy.DisplayName)" -ForegroundColor Yellow
    } else {
        $Body = @{
            displayName   = $Policy.DisplayName
            state         = $Policy.State
            conditions    = $Policy.Conditions
            grantControls = $Policy.GrantControls
        }

        New-MgIdentityConditionalAccessPolicy -BodyParameter $Body
        Write-Host "Conditional Access policy created: $($Policy.DisplayName)" -ForegroundColor Green
    }
}