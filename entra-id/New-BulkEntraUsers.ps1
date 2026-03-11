<#
.SYNOPSIS
    New-BulkEntraUsers.ps1

.DESCRIPTION
    Maakt cloud-only Microsoft Entra ID-gebruikers aan in bulk vanuit een CSV-bestand.
    - UPN wordt opgebouwd als <voornaam>.<achternaam>@<UPNDomain>
    - Per gebruiker wordt een uniek wachtwoord gegenereerd in het stijl van het
      Microsoft 365 Admin Center: Xxxnnnnn! (3 letters, 1 hoofdletter, 5 cijfers,
      1 speciaal teken) — voldoet aan Entra ID-wachtwoordbeleid
    - Resultaten (inclusief wachtwoorden) worden geëxporteerd naar een CSV

.PARAMETER InputCsvPath
    Pad naar het input CSV-bestand.
    Vereiste kolommen: FirstName, LastName, DisplayName, JobTitle

.PARAMETER UPNDomain
    Het UPN-domein voor de nieuwe accounts. Verplicht.
    Voorbeeld: cloud.contoso.com

.PARAMETER OutputCsvPath
    Pad naar het output CSV-bestand met aangemaakte gebruikers en wachtwoorden.
    Standaard: .\EntraUsers_Created_<timestamp>.csv

.PARAMETER ForceChangePasswordNextSignIn
    Of de gebruiker het wachtwoord moet wijzigen bij de eerste aanmelding.
    Standaard: $true

.EXAMPLE
    .\New-BulkEntraUsers.ps1 -InputCsvPath ".\users.csv" -UPNDomain "cloud.contoso.com"

.EXAMPLE
    .\New-BulkEntraUsers.ps1 -InputCsvPath ".\users.csv" -UPNDomain "cloud.contoso.com" -ForceChangePasswordNextSignIn $false

.NOTES
    Vereisten:
      - Microsoft Graph PowerShell SDK: Install-Module Microsoft.Graph -Scope CurrentUser
      - Vereiste Graph-scope: User.ReadWrite.All
      - Het opgegeven UPNDomain moet als geverifieerd domein aanwezig zijn in de tenant

    CSV-indeling (input):
      FirstName,LastName,DisplayName,JobTitle
      Jan,Jansen,Jan Jansen,Medewerker
      Maria,de Vries,Maria de Vries,Manager

    Wachtwoordformaat (zelfde stijl als Microsoft 365 Admin Center):
      - 1 hoofdletter (positie 0)
      - 2 kleine letters
      - 5 cijfers
      - 1 speciaal teken (!#$^&*)
      Voorbeeld: Kxp82541#
      Voldoet aan Entra ID-complexiteitsbeleid en is veilig te openen in Excel.

    Author      : Brandon
    GitHub      : https://github.com/Bradryx
    Datum       : 2026-03-11
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Pad naar het input CSV-bestand")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$InputCsvPath,

    [Parameter(Mandatory = $true, HelpMessage = "UPN-domein voor de nieuwe accounts, bijv. cloud.contoso.com")]
    [ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}$')]
    [string]$UPNDomain,

    [Parameter(Mandatory = $false)]
    [string]$OutputCsvPath = ".\EntraUsers_Created_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",

    [Parameter(Mandatory = $false)]
    [bool]$ForceChangePasswordNextSignIn = $true
)

#region ── Functies ────────────────────────────────────────────────────────────

function New-AdminCenterPassword {
    <#
    .SYNOPSIS
        Genereert een wachtwoord in de stijl van het Microsoft 365 Admin Center.

    .DESCRIPTION
        Formaat: [Hoofdletter][2 kleine letters][5 cijfers][speciaal teken]
        Voorbeeld: Kxp82541#

        - Voldoet aan Entra ID-complexiteitsbeleid (4 categorieën aanwezig)
        - Begint altijd met een hoofdletter: nooit een Excel-formule-teken (=+-@)
        - Speciaal teken beperkt tot tekens die veilig zijn in CSV en Excel
        - Gebruikt cryptografische RNG voor veilige willekeurigheid
        - Visueel verwarrende tekens weggelaten (0/O, 1/l/I)
    #>
    $rng     = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $upper   = 'ABCDEFGHJKLMNPQRSTUVWXYZ'.ToCharArray()   # I en O weggelaten
    $lower   = 'abcdefghjkmnpqrstuvwxyz'.ToCharArray()    # i, l en o weggelaten
    $digits  = '23456789'.ToCharArray()                   # 0 en 1 weggelaten
    $special = '!#$^&*()'.ToCharArray()                   # Geen +-=@%_ (Excel/CSV-gevoelig)

    function Get-SecureRandomChar {
        param([char[]]$Set)
        $bytes = [byte[]]::new(4)
        $rng.GetBytes($bytes)
        $index = [System.BitConverter]::ToUInt32($bytes, 0) % $Set.Length
        return $Set[$index]
    }

    # Opbouw: 1 hoofdletter + 2 kleine letters + 5 cijfers + 1 speciaal teken = 9 tekens
    $chars = @(
        (Get-SecureRandomChar $upper)    # pos 0: hoofdletter — altijd Excel-safe
        (Get-SecureRandomChar $lower)
        (Get-SecureRandomChar $lower)
        (Get-SecureRandomChar $digits)
        (Get-SecureRandomChar $digits)
        (Get-SecureRandomChar $digits)
        (Get-SecureRandomChar $digits)
        (Get-SecureRandomChar $digits)
        (Get-SecureRandomChar $special)  # pos 8: speciaal teken aan het einde
    )

    $rng.Dispose()
    return -join $chars
}

function ConvertTo-SafeMailNickname {
    <#
    .SYNOPSIS
        Converteert een naam naar een geldige MailNickname.
        Verwijdert diakritische tekens en niet-toegestane tekens.
    #>
    param ([string]$Name)

    $normalized = $Name.Normalize([System.Text.NormalizationForm]::FormD)
    $ascii      = [System.Text.StringBuilder]::new()

    foreach ($char in $normalized.ToCharArray()) {
        $cat = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)
        if ($cat -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$ascii.Append($char)
        }
    }

    # Alleen alfanumeriek, punten en koppeltekens toegestaan in MailNickname
    $clean = $ascii.ToString() -replace '[^a-zA-Z0-9.\-]', ''
    return $clean.ToLower()
}

#endregion

#region ── Verbinding met Microsoft Graph ──────────────────────────────────────

Write-Host "`n[INFO] Verbinden met Microsoft Graph..." -ForegroundColor Cyan

try {
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
        throw "Module 'Microsoft.Graph.Users' niet gevonden. Installeer via: Install-Module Microsoft.Graph -Scope CurrentUser"
    }

    Connect-MgGraph -Scopes "User.ReadWrite.All" -ErrorAction Stop
    Write-Host "[OK]  Verbonden met Microsoft Graph." -ForegroundColor Green
}
catch {
    Write-Error "Verbinding mislukt: $_"
    exit 1
}

#endregion

#region ── CSV inlezen en valideren ────────────────────────────────────────────

Write-Host "`n[INFO] CSV-bestand inlezen: $InputCsvPath" -ForegroundColor Cyan

try {
    $Users = Import-Csv -Path $InputCsvPath -ErrorAction Stop
}
catch {
    Write-Error "Kan CSV niet inlezen: $_"
    Disconnect-MgGraph | Out-Null
    exit 1
}

$requiredColumns = @('FirstName', 'LastName', 'DisplayName', 'JobTitle')
$csvColumns      = $Users[0].PSObject.Properties.Name

foreach ($col in $requiredColumns) {
    if ($col -notin $csvColumns) {
        Write-Error "Verplichte kolom '$col' ontbreekt in het CSV-bestand."
        Disconnect-MgGraph | Out-Null
        exit 1
    }
}

Write-Host "[OK]  $($Users.Count) gebruiker(s) gevonden in CSV." -ForegroundColor Green
Write-Host "[OK]  UPN-domein : $UPNDomain" -ForegroundColor Green

#endregion

#region ── Gebruikers aanmaken ─────────────────────────────────────────────────

$Results      = [System.Collections.Generic.List[PSCustomObject]]::new()
$successCount = 0
$failCount    = 0

Write-Host "`n[INFO] Starten met aanmaken van gebruikers in Entra ID..." -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

foreach ($User in $Users) {

    $firstName   = $User.FirstName.Trim()
    $lastName    = $User.LastName.Trim()
    $displayName = $User.DisplayName.Trim()
    $jobTitle    = $User.JobTitle.Trim()

    $upnPrefix    = "$(ConvertTo-SafeMailNickname $firstName).$(ConvertTo-SafeMailNickname $lastName)"
    $upn          = "$upnPrefix@$UPNDomain"
    $mailNickname = $upnPrefix

    $plainPassword = New-AdminCenterPassword

    $passwordProfile = @{
        Password                      = $plainPassword
        ForceChangePasswordNextSignIn = $ForceChangePasswordNextSignIn
    }

    $userParams = @{
        DisplayName       = $displayName
        GivenName         = $firstName
        Surname           = $lastName
        UserPrincipalName = $upn
        MailNickName      = $mailNickname
        AccountEnabled    = $true
        PasswordProfile   = $passwordProfile
    }

    # JobTitle alleen meegeven als de waarde niet leeg is
    if (-not [string]::IsNullOrWhiteSpace($jobTitle)) {
        $userParams['JobTitle'] = $jobTitle
    }

    $status   = ""
    $errorMsg = ""
    $objectId = ""

    try {
        if ($PSCmdlet.ShouldProcess($upn, "Gebruiker aanmaken in Entra ID")) {
            $createdUser = New-MgUser @userParams -ErrorAction Stop
            $objectId    = $createdUser.Id
            $status      = "Succesvol"
            $successCount++
            Write-Host "  [+] Aangemaakt : $upn" -ForegroundColor Green
        }
    }
    catch {
        $status   = "Mislukt"
        $errorMsg = $_.Exception.Message
        $failCount++
        Write-Host "  [!] Mislukt    : $upn  →  $errorMsg" -ForegroundColor Red
    }

    $Results.Add([PSCustomObject]@{
        DisplayName       = $displayName
        FirstName         = $firstName
        LastName          = $lastName
        JobTitle          = $jobTitle
        UserPrincipalName = $upn
        MailNickName      = $mailNickname
        ObjectId          = $objectId
        GeneratedPassword = $plainPassword
        Status            = $status
        ErrorMessage      = $errorMsg
    })
}

#endregion

#region ── Resultaten exporteren ───────────────────────────────────────────────

Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "`n[INFO] Resultaten exporteren naar: $OutputCsvPath" -ForegroundColor Cyan

try {
    $Results | Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
    Write-Host "[OK]  Export geslaagd." -ForegroundColor Green
}
catch {
    Write-Warning "Export mislukt: $_"
    Write-Host "[INFO] Resultaten worden alsnog in de console weergegeven:`n"
    $Results | Format-Table -AutoSize
}

#endregion

#region ── Samenvatting ────────────────────────────────────────────────────────

Write-Host "`n╔══════════════════════════════════╗" -ForegroundColor Cyan
Write-Host   "║         SAMENVATTING             ║" -ForegroundColor Cyan
Write-Host   "╚══════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "  Totaal verwerkt : $($Users.Count)"
Write-Host "  Succesvol       : $successCount" -ForegroundColor Green
Write-Host "  Mislukt         : $failCount"    -ForegroundColor $(if ($failCount -gt 0) { 'Red' } else { 'Gray' })
Write-Host "  UPN-domein      : $UPNDomain"
Write-Host "  Output CSV      : $OutputCsvPath`n"

Write-Host "[WAARSCHUWING] De output CSV bevat wachtwoorden in leesbare tekst." -ForegroundColor Yellow
Write-Host "               Bewaar dit bestand op een veilige locatie en verwijder het na gebruik.`n" -ForegroundColor Yellow

#endregion

Disconnect-MgGraph | Out-Null
Write-Host "[INFO] Verbinding met Microsoft Graph verbroken.`n" -ForegroundColor DarkGray