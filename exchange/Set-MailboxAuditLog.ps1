<#
.SYNOPSIS
    Enables mailbox auditing for all mailboxes in Exchange Online.

.DESCRIPTION
    Connects to Exchange Online and enables mailbox auditing for all
    user mailboxes. Configures audit actions for Owner, Delegate,
    and Admin logon types based on Microsoft recommended settings.

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Retrieve all user mailboxes
Write-Host "Retrieving all user mailboxes..." -ForegroundColor Cyan
$Mailboxes = Get-Mailbox -ResultSize Unlimited -Filter "RecipientTypeDetails -eq 'UserMailbox'"

Write-Host "$($Mailboxes.Count) mailbox(es) found." -ForegroundColor Cyan

foreach ($Mailbox in $Mailboxes) {
    Set-Mailbox -Identity $Mailbox.UserPrincipalName `
        -AuditEnabled $true `
        -AuditOwner @(
            "MailboxLogin", "HardDelete", "SoftDelete",
            "Update", "Move", "MoveToDeletedItems"
        ) `
        -AuditDelegate @(
            "SendAs", "SendOnBehalf", "HardDelete",
            "SoftDelete", "Update", "Move", "MoveToDeletedItems"
        ) `
        -AuditAdmin @(
            "Copy", "HardDelete", "MessageBind",
            "Move", "MoveToDeletedItems", "SendAs", "SoftDelete", "Update"
        )

    Write-Host "Auditing enabled: $($Mailbox.UserPrincipalName)" -ForegroundColor Green
}