<#
.SYNOPSIS
    Exports mailbox size and quota status for all mailboxes in Exchange Online.

.DESCRIPTION
    Connects to Exchange Online and retrieves mailbox size and quota
    information for all user mailboxes. Exports the results to a CSV file.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-MailboxSizeReport.ps1
    .\Get-MailboxSizeReport.ps1 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

param (
    [string] $OutputPath = (Get-Location).Path
)

# Connect to Exchange Online
Connect-ExchangeOnline

# Retrieve all user mailboxes
Write-Host "Retrieving mailbox size and quota information..." -ForegroundColor Cyan
$Mailboxes = Get-Mailbox -ResultSize Unlimited -Filter "RecipientTypeDetails -eq 'UserMailbox'"

# Retrieve mailbox statistics
$Report = foreach ($Mailbox in $Mailboxes) {
    $Stats = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalName

    [PSCustomObject]@{
        DisplayName          = $Mailbox.DisplayName
        UserPrincipalName    = $Mailbox.UserPrincipalName
        MailboxSizeGB        = [math]::Round(($Stats.TotalItemSize.Value.ToBytes() / 1GB), 2)
        ItemCount            = $Stats.ItemCount
        IssueWarningQuotaGB  = [math]::Round(($Mailbox.IssueWarningQuota.Value.ToBytes() / 1GB), 2)
        ProhibitSendQuotaGB  = [math]::Round(($Mailbox.ProhibitSendQuota.Value.ToBytes() / 1GB), 2)
        QuotaStatus          = $Stats.DisplayName
        LastLogonTime        = $Stats.LastLogonTime
    }
}

# Export to CSV
$FileName   = "MailboxSizeReport_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green