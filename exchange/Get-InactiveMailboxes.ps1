<#
.SYNOPSIS
    Exports mailboxes with no activity for a specified number of days.

.DESCRIPTION
    Connects to Exchange Online and retrieves all user mailboxes that
    have not had any logon activity for a specified number of days.
    Exports the results to a CSV file for review and cleanup.

.PARAMETER DaysInactive
    Number of days since last logon to consider a mailbox inactive.
    Defaults to 30 days.

.PARAMETER OutputPath
    Path to export the CSV file. Defaults to current directory.

.EXAMPLE
    .\Get-InactiveMailboxes.ps1
    .\Get-InactiveMailboxes.ps1 -DaysInactive 60
    .\Get-InactiveMailboxes.ps1 -DaysInactive 90 -OutputPath "~/Reports"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

param (
    [int]    $DaysInactive = 30,
    [string] $OutputPath   = (Get-Location).Path
)

# Connect to Exchange Online
Connect-ExchangeOnline

# Calculate cutoff date
$CutoffDate = (Get-Date).AddDays(-$DaysInactive)

# Retrieve all user mailboxes
Write-Host "Retrieving mailboxes inactive since $($CutoffDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan
$Mailboxes = Get-Mailbox -ResultSize Unlimited -Filter "RecipientTypeDetails -eq 'UserMailbox'"

# Filter inactive mailboxes
$Report = foreach ($Mailbox in $Mailboxes) {
    $Stats = Get-MailboxStatistics -Identity $Mailbox.UserPrincipalName

    if ($null -eq $Stats.LastLogonTime -or $Stats.LastLogonTime -lt $CutoffDate) {
        [PSCustomObject]@{
            DisplayName       = $Mailbox.DisplayName
            UserPrincipalName = $Mailbox.UserPrincipalName
            LastLogonTime     = $Stats.LastLogonTime ?? "Never"
            DaysInactive      = if ($Stats.LastLogonTime) {
                                    (New-TimeSpan -Start $Stats.LastLogonTime -End (Get-Date)).Days
                                } else { "N/A" }
            MailboxSizeGB     = [math]::Round(($Stats.TotalItemSize.Value.ToBytes() / 1GB), 2)
            ItemCount         = $Stats.ItemCount
        }
    }
}

if (-not $Report) {
    Write-Host "No inactive mailboxes found." -ForegroundColor Yellow
    exit
}

Write-Host "$($Report.Count) inactive mailbox(es) found." -ForegroundColor Cyan

# Export to CSV
$FileName   = "InactiveMailboxes_$(Get-Date -Format 'yyyy-MM-dd').csv"
$ExportPath = Join-Path -Path $OutputPath -ChildPath $FileName

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
Write-Host "Export completed: $ExportPath" -ForegroundColor Green