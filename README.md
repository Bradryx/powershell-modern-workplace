# powershell-modern-workplace

A personal collection of PowerShell scripts for managing and automating Modern Workplace environments.

## Structure

### Intune
| Script | Description |
|---|---|
| `Get-IntuneDevices.ps1` | Retrieves all managed devices from Intune |
| `Get-DeviceComplianceReport.ps1` | Exports compliance status per device to CSV |
| `Get-StaleDevices.ps1` | Exports devices inactive for X days to CSV |
| `Set-CompliancePolicies.ps1` | Creates baseline compliance policies for Windows, macOS, iOS and Android |
| `Set-ConfigurationProfiles.ps1` | Deploys baseline security configuration profiles for Windows and macOS |

### Entra ID
| Script | Description |
|---|---|
| `Get-MFAStatusReport.ps1` | Exports MFA registration status per user to CSV |
| `Get-StaleGuestAccounts.ps1` | Exports guest accounts inactive for X days to CSV |
| `Set-AuthenticationMethods.ps1` | Enables all recommended authentication methods tenant-wide |
| `Set-ConditionalAccessPolicies.ps1` | Creates baseline Conditional Access policies |
| `Set-GroupMembership.ps1` | Bulk adds or removes users from a group via CSV |

### Purview
| Script | Description |
|---|---|
| `Enable-AuditLog.ps1` | Enables the Unified Audit Log for the tenant |
| `Get-DLPPolicyMatches.ps1` | Exports DLP policy matches from the Unified Audit Log to CSV |
| `Get-SensitivityLabelReport.ps1` | Exports sensitivity label activity to CSV |
| `Set-DLPPolicies.ps1` | Creates baseline DLP policies per platform (EXO, SPO, ODB, MIP) |
| `Set-RetentionPolicies.ps1` | Creates baseline retention policies per platform |
| `Set-SensitivityLabels.ps1` | Creates a standard set of sensitivity labels |

### Exchange
| Script | Description |
|---|---|
| `Get-InactiveMailboxes.ps1` | Exports mailboxes inactive for X days to CSV |
| `Get-MailboxSizeReport.ps1` | Exports mailbox size and quota status to CSV |
| `Set-AntiSpamPolicies.ps1` | Creates baseline anti-spam and anti-phishing policies |
| `Set-MailboxAuditLog.ps1` | Enables mailbox auditing for all user mailboxes |
| `Set-MailboxPermissions.ps1` | Bulk assigns FullAccess and SendAs permissions via CSV |
| `Set-SharedMailboxDelegation.ps1` | Configures FullAccess and SendAs delegation for shared mailboxes |

## Requirements
- Microsoft.Graph PowerShell module
- ExchangeOnlineManagement module
- Appropriate Microsoft 365 permissions per script

## Usage
Each script contains a comment-based help block with a synopsis, description, parameters, and usage examples.

## Author
Brandon | [GitHub](https://github.com/Bradryx) | [LinkedIn](https://www.linkedin.com/in/brandon-van-dijk/)