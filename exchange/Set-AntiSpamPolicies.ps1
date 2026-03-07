<#
.SYNOPSIS
    Creates baseline anti-spam and anti-phishing policies in Exchange Online.

.DESCRIPTION
    Connects to Exchange Online and creates baseline anti-spam and
    anti-phishing policies following the naming convention:
    <Scope>-<ThreatType>-<Action>

    Policies created:
    - EXO-Spam-Baseline
    - EXO-Phishing-Baseline

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Create anti-spam policy
$SpamPolicyName = "EXO-Spam-Baseline"
$SpamExists     = Get-HostedContentFilterPolicy -Identity $SpamPolicyName -ErrorAction SilentlyContinue

if ($SpamExists) {
    Write-Host "Anti-spam policy already exists, skipping: $SpamPolicyName" -ForegroundColor Yellow
} else {
    New-HostedContentFilterPolicy -Name $SpamPolicyName `
        -SpamAction MoveToJmf `
        -HighConfidenceSpamAction Quarantine `
        -PhishSpamAction Quarantine `
        -HighConfidencePhishAction Quarantine `
        -BulkThreshold 6 `
        -MarkAsSpamBulkMail On `
        -EnableLanguageBlockList $false `
        -EnableRegionBlockList $false

    New-HostedContentFilterRule -Name $SpamPolicyName `
        -HostedContentFilterPolicy $SpamPolicyName `
        -RecipientDomainIs (Get-AcceptedDomain).Name `
        -Priority 0

    Write-Host "Anti-spam policy created: $SpamPolicyName" -ForegroundColor Green
}

# Create anti-phishing policy
$PhishPolicyName = "EXO-Phishing-Baseline"
$PhishExists     = Get-AntiPhishPolicy -Identity $PhishPolicyName -ErrorAction SilentlyContinue

if ($PhishExists) {
    Write-Host "Anti-phishing policy already exists, skipping: $PhishPolicyName" -ForegroundColor Yellow
} else {
    New-AntiPhishPolicy -Name $PhishPolicyName `
        -EnableMailboxIntelligence $true `
        -EnableMailboxIntelligenceProtection $true `
        -EnableSpoofIntelligence $true `
        -EnableFirstContactSafetyTips $true `
        -EnableSimilarUsersSafetyTips $true `
        -EnableSimilarDomainsSafetyTips $true `
        -EnableUnusualCharactersSafetyTips $true `
        -PhishThresholdLevel 2 `
        -MailboxIntelligenceProtectionAction Quarantine `
        -AuthenticationFailAction Quarantine

    New-AntiPhishRule -Name $PhishPolicyName `
        -AntiPhishPolicy $PhishPolicyName `
        -RecipientDomainIs (Get-AcceptedDomain).Name `
        -Priority 0

    Write-Host "Anti-phishing policy created: $PhishPolicyName" -ForegroundColor Green
}