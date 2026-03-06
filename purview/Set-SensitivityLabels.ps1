<#
.SYNOPSIS
    Creates and configures sensitivity labels in Microsoft Purview.

.DESCRIPTION
    Connects to the Security & Compliance Center and creates a standard
    set of sensitivity labels based on a common classification framework.
    Labels created: Public, Internal, Confidential, Highly Confidential.

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : ExchangeOnlineManagement module
#>

# Connect to Security & Compliance Center
Connect-IPPSSession

# Define labels
$Labels = @(
    @{ Name = "Public";               Tooltip = "Information approved for public use." },
    @{ Name = "Internal";             Tooltip = "Information intended for internal use only." },
    @{ Name = "Confidential";         Tooltip = "Sensitive information, restricted to authorized users." },
    @{ Name = "Highly Confidential";  Tooltip = "Highly sensitive information, strictly restricted." }
)

# Create labels
foreach ($Label in $Labels) {
    $Exists = Get-Label -Identity $Label.Name -ErrorAction SilentlyContinue

    if ($Exists) {
        Write-Host "Label already exists, skipping: $($Label.Name)" -ForegroundColor Yellow
    } else {
        New-Label -Name $Label.Name -DisplayName $Label.Name -Tooltip $Label.Tooltip
        Write-Host "Label created: $($Label.Name)" -ForegroundColor Green
    }
}