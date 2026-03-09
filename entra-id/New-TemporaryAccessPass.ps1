#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns

<#
.SYNOPSIS
    Generates a Temporary Access Pass (TAP) for a specified user in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and creates a TAP for a given user.
    Designed for Autopilot enrollment scenarios — defaults to multi-use with
    a 4-hour lifetime. Outputs the TAP and relevant details to the console.

.PARAMETER UserPrincipalName
    The UPN of the user to generate the TAP for.

.PARAMETER LifetimeInMinutes
    Lifetime of the TAP in minutes. Default: 240 (4 hours).

.PARAMETER IsUsableOnce
    If specified, the TAP will be single-use only.
    Default: multi-use (recommended for Autopilot).

.PARAMETER StartDateTime
    Optional. The date/time the TAP becomes valid. Defaults to now.

.EXAMPLE
    .\New-TemporaryAccessPass.ps1 -UserPrincipalName "john.doe@contoso.com"

.EXAMPLE
    .\New-TemporaryAccessPass.ps1 -UserPrincipalName "john.doe@contoso.com" -LifetimeInMinutes 480 -IsUsableOnce

.NOTES
    Required Graph permissions: UserAuthenticationMethod.ReadWrite.All
    Author: Generated for Modern Workplace use
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the UPN of the user.")]
    [ValidatePattern('^[^@]+@[^@]+\.[^@]+$')]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [ValidateRange(10, 480)]
    [int]$LifetimeInMinutes = 240,

    [Parameter(Mandatory = $false)]
    [switch]$IsUsableOnce,

    [Parameter(Mandatory = $false)]
    [datetime]$StartDateTime = (Get-Date)
)

#region --- Connect to Graph ---
Write-Host "`n[Connecting] Connecting to Microsoft Graph..." -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All" -NoWelcome -ErrorAction Stop
    Write-Host "[Connected] Successfully connected to Microsoft Graph.`n" -ForegroundColor Green
}
catch {
    Write-Error "[Error] Failed to connect to Microsoft Graph: $_"
    exit 1
}
#endregion

#region --- Resolve User ---
Write-Host "[Resolving] Looking up user: $UserPrincipalName" -ForegroundColor Cyan

try {
    $User = Get-MgUser -UserId $UserPrincipalName -Property "Id,DisplayName,UserPrincipalName,AccountEnabled" -ErrorAction Stop
}
catch {
    Write-Error "[Error] User '$UserPrincipalName' not found or inaccessible. $_"
    Disconnect-MgGraph | Out-Null
    exit 1
}

if (-not $User.AccountEnabled) {
    Write-Warning "[Warning] The account '$UserPrincipalName' is currently disabled in Entra ID."
    $Confirm = Read-Host "Do you want to continue anyway? (y/N)"
    if ($Confirm -ne 'y') {
        Write-Host "[Aborted] TAP generation cancelled." -ForegroundColor Yellow
        Disconnect-MgGraph | Out-Null
        exit 0
    }
}

Write-Host "[Found] $($User.DisplayName) ($($User.UserPrincipalName))`n" -ForegroundColor Green
#endregion

#region --- Generate TAP ---
Write-Host "[Generating] Creating Temporary Access Pass..." -ForegroundColor Cyan

$TapParams = @{
    IsUsableOnce    = $IsUsableOnce.IsPresent
    LifetimeInMinutes = $LifetimeInMinutes
    StartDateTime   = $StartDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

try {
    $TAP = New-MgUserAuthenticationTemporaryAccessPassMethod -UserId $User.Id -BodyParameter $TapParams -ErrorAction Stop
}
catch {
    Write-Error "[Error] Failed to generate TAP: $_"
    Disconnect-MgGraph | Out-Null
    exit 1
}
#endregion

#region --- Output ---
$ExpiresAt = $StartDateTime.AddMinutes($LifetimeInMinutes)

Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "  TEMPORARY ACCESS PASS GENERATED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor DarkCyan
Write-Host "  User         : $($User.DisplayName)"
Write-Host "  UPN          : $($User.UserPrincipalName)"
Write-Host "  TAP          : " -NoNewline
Write-Host "$($TAP.TemporaryAccessPass)" -ForegroundColor Yellow
Write-Host "  Valid from   : $($StartDateTime.ToString('dd-MM-yyyy HH:mm'))"
Write-Host "  Expires at   : $($ExpiresAt.ToString('dd-MM-yyyy HH:mm'))"
Write-Host "  Lifetime     : $LifetimeInMinutes minutes"
Write-Host "  Multi-use    : $(-not $IsUsableOnce.IsPresent)"
Write-Host "========================================`n" -ForegroundColor DarkCyan

# Copy to clipboard if running interactively
if ($Host.UI.RawUI.KeyAvailable -eq $false) {
    try {
        $TAP.TemporaryAccessPass | Set-Clipboard
        Write-Host "[Clipboard] TAP has been copied to your clipboard." -ForegroundColor Green
    }
    catch {
        # Clipboard not available in all environments, silently skip
    }
}
#endregion

#region --- Disconnect ---
Disconnect-MgGraph | Out-Null
Write-Host "[Disconnected] Graph session closed.`n" -ForegroundColor DarkGray
#endregion