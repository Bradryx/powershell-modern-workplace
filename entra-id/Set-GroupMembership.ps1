<#
.SYNOPSIS
    Bulk adds or removes users from an Entra ID group.

.DESCRIPTION
    Connects to Microsoft Graph and adds or removes a list of users
    from a specified Entra ID group based on a CSV file.

    Required CSV columns: UserPrincipalName

.PARAMETER GroupName
    Display name of the Entra ID group to manage.

.PARAMETER CsvPath
    Path to the CSV file containing UserPrincipalName column.

.PARAMETER Action
    Action to perform. Valid values: Add, Remove.

.EXAMPLE
    .\Set-GroupMembership.ps1 -GroupName "SG-Intune-Users" -CsvPath "~/users.csv" -Action "Add"
    .\Set-GroupMembership.ps1 -GroupName "SG-Intune-Users" -CsvPath "~/users.csv" -Action "Remove"

.NOTES
    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Requires    : Microsoft.Graph PowerShell module
#>

param (
    [Parameter(Mandatory = $true)]
    [string] $GroupName,

    [Parameter(Mandatory = $true)]
    [string] $CsvPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Add", "Remove")]
    [string] $Action
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All"

# Validate CSV path
if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    exit
}

# Retrieve group
$Group = Get-MgGroup -Filter "displayName eq '$GroupName'"

if (-not $Group) {
    Write-Host "Group not found: $GroupName" -ForegroundColor Red
    exit
}

# Import users from CSV
$Users = Import-Csv -Path $CsvPath

foreach ($User in $Users) {
    $MgUser = Get-MgUser -Filter "userPrincipalName eq '$($User.UserPrincipalName)'" -ErrorAction SilentlyContinue

    if (-not $MgUser) {
        Write-Host "User not found, skipping: $($User.UserPrincipalName)" -ForegroundColor Yellow
        continue
    }

    try {
        if ($Action -eq "Add") {
            New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $MgUser.Id
            Write-Host "User added to $GroupName`: $($User.UserPrincipalName)" -ForegroundColor Green
        } elseif ($Action -eq "Remove") {
            Remove-MgGroupMemberByRef -GroupId $Group.Id -DirectoryObjectId $MgUser.Id
            Write-Host "User removed from $GroupName`: $($User.UserPrincipalName)" -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to $Action user: $($User.UserPrincipalName) — $($_.Exception.Message)" -ForegroundColor Red
    }
}