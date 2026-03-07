<#
.SYNOPSIS
    Bulk assigns FullAccess and SendAs permissions to mailboxes from a CSV file.

.DESCRIPTION
    Connects to Exchange Online and assigns FullAccess and/or SendAs
    permissions to mailboxes based on a CSV file.

    Required CSV columns:
    - Mailbox       : UPN or alias of the target mailbox
    - Delegate      : UPN or alias of the user receiving permissions
    - FullAccess    : TRUE or FALSE
    - SendAs        : TRUE or FALSE

.PARAMETER CsvPath
    Path to the CSV file containing mailbox permission assignments.

.EXAMPLE
    .\Set-MailboxPermissions.ps1 -CsvPath "~/mailbox-permissions.csv"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

param (
    [Parameter(Mandatory = $true)]
    [string] $CsvPath
)

# Connect to Exchange Online
Connect-ExchangeOnline

# Validate CSV path
if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    exit
}

# Import CSV
$Permissions = Import-Csv -Path $CsvPath

foreach ($Entry in $Permissions) {
    # Assign FullAccess
    if ($Entry.FullAccess -eq "TRUE") {
        try {
            Add-MailboxPermission -Identity $Entry.Mailbox -User $Entry.Delegate -AccessRights FullAccess -InheritanceType All -AutoMapping $true
            Write-Host "FullAccess granted: $($Entry.Delegate) → $($Entry.Mailbox)" -ForegroundColor Green
        } catch {
            Write-Host "Failed FullAccess: $($Entry.Delegate) → $($Entry.Mailbox) — $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Assign SendAs
    if ($Entry.SendAs -eq "TRUE") {
        try {
            Add-RecipientPermission -Identity $Entry.Mailbox -Trustee $Entry.Delegate -AccessRights SendAs -Confirm:$false
            Write-Host "SendAs granted: $($Entry.Delegate) → $($Entry.Mailbox)" -ForegroundColor Green
        } catch {
            Write-Host "Failed SendAs: $($Entry.Delegate) → $($Entry.Mailbox) — $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}