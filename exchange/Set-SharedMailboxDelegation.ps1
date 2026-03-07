<#
.SYNOPSIS
    Configures FullAccess and SendAs delegation for shared mailboxes.

.DESCRIPTION
    Connects to Exchange Online and assigns FullAccess and SendAs
    permissions to a shared mailbox for a specified list of delegates.

.PARAMETER SharedMailbox
    UPN or alias of the shared mailbox.

.PARAMETER Delegates
    Array of UPNs to assign as delegates.

.PARAMETER FullAccess
    Switch to assign FullAccess permission.

.PARAMETER SendAs
    Switch to assign SendAs permission.

.EXAMPLE
    .\Set-SharedMailboxDelegation.ps1 -SharedMailbox "info@contoso.com" -Delegates @("user1@contoso.com", "user2@contoso.com") -FullAccess -SendAs

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

param (
    [Parameter(Mandatory = $true)]
    [string]   $SharedMailbox,

    [Parameter(Mandatory = $true)]
    [string[]] $Delegates,

    [switch] $FullAccess,
    [switch] $SendAs
)

# Connect to Exchange Online
Connect-ExchangeOnline

# Validate shared mailbox exists
$Mailbox = Get-Mailbox -Identity $SharedMailbox -RecipientTypeDetails SharedMailbox -ErrorAction SilentlyContinue

if (-not $Mailbox) {
    Write-Host "Shared mailbox not found: $SharedMailbox" -ForegroundColor Red
    exit
}

foreach ($Delegate in $Delegates) {
    # Assign FullAccess
    if ($FullAccess) {
        try {
            Add-MailboxPermission -Identity $SharedMailbox -User $Delegate -AccessRights FullAccess -InheritanceType All -AutoMapping $true
            Write-Host "FullAccess granted: $Delegate → $SharedMailbox" -ForegroundColor Green
        } catch {
            Write-Host "Failed FullAccess: $Delegate → $SharedMailbox — $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Assign SendAs
    if ($SendAs) {
        try {
            Add-RecipientPermission -Identity $SharedMailbox -Trustee $Delegate -AccessRights SendAs -Confirm:$false
            Write-Host "SendAs granted: $Delegate → $SharedMailbox" -ForegroundColor Green
        } catch {
            Write-Host "Failed SendAs: $Delegate → $SharedMailbox — $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}