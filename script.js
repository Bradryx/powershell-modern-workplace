/* ===========================
   DATA
=========================== */
const GITHUB_BASE = "https://github.com/Bradryx/powershell-modern-workplace/blob/main/";

const MODULES = [
  {
    id: "intune",
    label: "Intune",
    tag: "Device Management",
    color: "#0078d4",
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/></svg>`,
  },
  {
    id: "entra-id",
    label: "Entra ID",
    tag: "Identity &amp; Access",
    color: "#7b68ee",
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`,
  },
  {
    id: "exchange",
    label: "Exchange Online",
    tag: "Mailbox Management",
    color: "#107c41",
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>`,
  },
  {
    id: "purview",
    label: "Purview",
    tag: "Compliance &amp; Data Protection",
    color: "#c43e1c",
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>`,
  },
];

const SCRIPTS = [
  // INTUNE
  {
    module: "intune",
    file: "Get-IntuneDevices.ps1",
    desc: "Retrieves all managed devices from Intune with device name, OS, and compliance state.",
    tags: ["Microsoft.Graph", "Read-Only"],
    synopsis: "Retrieves all devices from Microsoft Intune.",
    description: "Connects to Microsoft Graph and retrieves all managed devices from Microsoft Intune. Outputs the device name, OS, and compliance state.",
    parameters: [],
    example: "Connect-MgGraph -Scopes 'DeviceManagementManagedDevices.Read.All'\n.\\Get-IntuneDevices.ps1",
  },
  {
    module: "intune",
    file: "Get-DeviceComplianceReport.ps1",
    desc: "Exports a detailed device compliance report to CSV — platform, OS version, compliance state, last check-in, primary user.",
    tags: ["Microsoft.Graph", "CSV Export"],
    synopsis: "Exports a device compliance report from Microsoft Intune.",
    description: "Connects to Microsoft Graph and retrieves the compliance status of all managed devices. Exports the results to a CSV file.",
    parameters: [
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-DeviceComplianceReport.ps1 -OutputPath '~/Reports'",
  },
  {
    module: "intune",
    file: "Get-StaleDevices.ps1",
    desc: "Identifies devices inactive for a configurable number of days and exports them to CSV for cleanup review.",
    tags: ["Microsoft.Graph", "CSV Export"],
    synopsis: "Exports stale devices from Microsoft Intune.",
    description: "Connects to Microsoft Graph and retrieves all managed devices that have not checked in for a specified number of days. Exports the results to a CSV file for review and cleanup.",
    parameters: [
      { name: "DaysInactive", desc: "Number of days since last check-in to consider a device stale. Defaults to 30." },
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-StaleDevices.ps1 -DaysInactive 90 -OutputPath '~/Reports'",
  },
  {
    module: "intune",
    file: "Set-CompliancePolicies.ps1",
    desc: "Creates baseline compliance policies for Windows, macOS, iOS/iPadOS, and Android with password, encryption, firewall, and Defender requirements.",
    tags: ["Microsoft.Graph", "Baseline", "Write"],
    synopsis: "Creates baseline compliance policies in Microsoft Intune.",
    description: "Connects to Microsoft Graph and creates baseline compliance policies for Windows, macOS, iOS/iPadOS, and Android platforms. Policies created: WIN-Compliance-Baseline, MAC-Compliance-Baseline, IOS-Compliance-Baseline, AND-Compliance-Baseline.",
    parameters: [],
    example: ".\\Set-CompliancePolicies.ps1",
  },
  {
    module: "intune",
    file: "Set-ConfigurationProfiles.ps1",
    desc: "Deploys baseline security configuration profiles for Windows and macOS devices via Intune.",
    tags: ["Microsoft.Graph", "Baseline", "Write"],
    synopsis: "Creates baseline configuration profiles in Microsoft Intune.",
    description: "Connects to Microsoft Graph and creates baseline security configuration profiles for Windows and macOS using the Settings Catalog. Profiles created: WIN-SecurityBaseline-Config, MAC-SecurityBaseline-Config.",
    parameters: [],
    example: ".\\Set-ConfigurationProfiles.ps1",
  },

  // ENTRA ID
  {
    module: "entra-id",
    file: "Get-MFAStatusReport.ps1",
    desc: "Exports MFA registration status per user to CSV — includes MFA capability, passwordless capability, default method, and SSPR status.",
    tags: ["Microsoft.Graph", "CSV Export"],
    synopsis: "Exports MFA registration status per user from Microsoft Entra ID.",
    description: "Connects to Microsoft Graph and retrieves the MFA registration status for all users in the tenant. Exports the results to a CSV file.",
    parameters: [
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-MFAStatusReport.ps1 -OutputPath '~/Reports'",
  },
  {
    module: "entra-id",
    file: "Get-StaleGuestAccounts.ps1",
    desc: "Identifies external guest accounts inactive for a configurable number of days and exports them to CSV.",
    tags: ["Microsoft.Graph", "CSV Export"],
    synopsis: "Exports stale guest accounts from Microsoft Entra ID.",
    description: "Connects to Microsoft Graph and retrieves all guest accounts that have not signed in for a specified number of days or have never signed in. Exports the results to a CSV file for review and cleanup.",
    parameters: [
      { name: "DaysInactive", desc: "Number of days since last sign-in to consider a guest account stale. Defaults to 90." },
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-StaleGuestAccounts.ps1 -DaysInactive 90 -OutputPath '~/Reports'",
  },
  {
    module: "entra-id",
    file: "New-BulkEntraUsers.ps1",
    desc: "Creates cloud-only Entra ID users in bulk from a CSV file. Generates secure passwords, handles UPN construction and MailNickname normalization, and exports results with object IDs.",
    tags: ["Microsoft.Graph", "CSV Import", "Write"],
    synopsis: "Creates cloud-only Entra ID users in bulk from a CSV file.",
    description: "Connects to Microsoft Graph and creates cloud-only Entra ID users in bulk from a CSV file. UPN is constructed as firstname.lastname@domain. A unique secure password is generated per user in Microsoft 365 Admin Center style. Results including passwords and object IDs are exported to CSV.",
    parameters: [
      { name: "InputCsvPath", desc: "Path to the input CSV file. Required columns: FirstName, LastName, DisplayName, JobTitle." },
      { name: "UPNDomain", desc: "The UPN domain for the new accounts, e.g. cloud.contoso.com." },
      { name: "OutputCsvPath", desc: "Path to the output CSV with created users and passwords. Defaults to .\\EntraUsers_Created_<timestamp>.csv." },
      { name: "ForceChangePasswordNextSignIn", desc: "Whether the user must change password on first sign-in. Defaults to $true." },
    ],
    example: ".\\New-BulkEntraUsers.ps1 -InputCsvPath '.\\users.csv' -UPNDomain 'cloud.contoso.com'",
  },
  {
    module: "entra-id",
    file: "New-TemporaryAccessPass.ps1",
    desc: "Creates Temporary Access Passes (TAP) for Entra ID users — a time-limited passcode for onboarding and recovery scenarios.",
    tags: ["Microsoft.Graph", "Write"],
    synopsis: "Generates a Temporary Access Pass (TAP) for a specified user in Entra ID.",
    description: "Connects to Microsoft Graph and creates a TAP for a given user. Designed for Autopilot enrollment scenarios — defaults to multi-use with a 4-hour lifetime. Outputs the TAP and relevant details to the console.",
    parameters: [
      { name: "UserPrincipalName", desc: "The UPN of the user to generate the TAP for." },
      { name: "LifetimeInMinutes", desc: "Lifetime of the TAP in minutes. Default: 240 (4 hours)." },
      { name: "IsUsableOnce", desc: "If specified, the TAP will be single-use only. Default: multi-use." },
      { name: "StartDateTime", desc: "Optional. The date/time the TAP becomes valid. Defaults to now." },
    ],
    example: ".\\New-TemporaryAccessPass.ps1 -UserPrincipalName 'john.doe@contoso.com'",
  },
  {
    module: "entra-id",
    file: "Set-AuthenticationMethods.ps1",
    desc: "Enables all recommended authentication methods tenant-wide including FIDO2, Microsoft Authenticator, and Temporary Access Pass.",
    tags: ["Microsoft.Graph", "Baseline", "Write"],
    synopsis: "Configures authentication methods in Microsoft Entra ID.",
    description: "Connects to Microsoft Graph and enables all recommended authentication methods for the tenant, including Microsoft Authenticator, FIDO2, Temporary Access Pass, SMS, Voice, and Certificate-Based Authentication.",
    parameters: [],
    example: ".\\Set-AuthenticationMethods.ps1",
  },
  {
    module: "entra-id",
    file: "Set-ConditionalAccessPolicies.ps1",
    desc: "Creates 3 baseline Conditional Access policies: require MFA for all users, require device compliance, and restrict admin access by named location.",
    tags: ["Microsoft.Graph", "Baseline", "Write"],
    synopsis: "Creates baseline Conditional Access policies in Microsoft Entra ID.",
    description: "Connects to Microsoft Graph and creates baseline Conditional Access policies: ALL-MFA-Require (MFA for all users), ALL-CompliantDevice-Require (device compliance), ADM-NamedLocation-Block (admin access restriction by location).",
    parameters: [
      { name: "NamedLocationId", desc: "Object ID of the named location to use for admin access restriction. Run Get-MgIdentityConditionalAccessNamedLocation to retrieve IDs." },
    ],
    example: ".\\Set-ConditionalAccessPolicies.ps1 -NamedLocationId '00000000-0000-0000-0000-000000000000'",
  },
  {
    module: "entra-id",
    file: "Set-GroupMembership.ps1",
    desc: "Bulk adds or removes users from Entra ID groups using a CSV file. Supports both add and remove operations.",
    tags: ["Microsoft.Graph", "CSV Import", "Write"],
    synopsis: "Bulk adds or removes users from an Entra ID group.",
    description: "Connects to Microsoft Graph and adds or removes a list of users from a specified Entra ID group based on a CSV file. Required CSV column: UserPrincipalName.",
    parameters: [
      { name: "GroupName", desc: "Display name of the Entra ID group to manage." },
      { name: "CsvPath", desc: "Path to the CSV file containing UserPrincipalName column." },
      { name: "Action", desc: "Action to perform. Valid values: Add, Remove." },
    ],
    example: ".\\Set-GroupMembership.ps1 -GroupName 'SG-Intune-Users' -CsvPath '~/users.csv' -Action 'Add'",
  },

  // EXCHANGE
  {
    module: "exchange",
    file: "Get-InactiveMailboxes.ps1",
    desc: "Exports mailboxes inactive for a configurable number of days to CSV for archival or offboarding decisions.",
    tags: ["ExchangeOnlineManagement", "CSV Export"],
    synopsis: "Exports mailboxes with no activity for a specified number of days.",
    description: "Connects to Exchange Online and retrieves all user mailboxes that have not had any logon activity for a specified number of days. Exports the results to a CSV file for review and cleanup.",
    parameters: [
      { name: "DaysInactive", desc: "Number of days since last logon to consider a mailbox inactive. Defaults to 30." },
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-InactiveMailboxes.ps1 -DaysInactive 90 -OutputPath '~/Reports'",
  },
  {
    module: "exchange",
    file: "Get-MailboxSizeReport.ps1",
    desc: "Exports mailbox size, quota status, and quota usage percentage to CSV for capacity planning and governance reporting.",
    tags: ["ExchangeOnlineManagement", "CSV Export"],
    synopsis: "Exports mailbox size and quota status for all mailboxes in Exchange Online.",
    description: "Connects to Exchange Online and retrieves mailbox size and quota information for all user mailboxes. Exports the results to a CSV file.",
    parameters: [
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-MailboxSizeReport.ps1 -OutputPath '~/Reports'",
  },
  {
    module: "exchange",
    file: "Set-AntiSpamPolicies.ps1",
    desc: "Creates baseline anti-spam and anti-phishing policies with spam/phishing quarantine, bulk threshold, mailbox intelligence, and spoof intelligence.",
    tags: ["ExchangeOnlineManagement", "Baseline", "Write"],
    synopsis: "Creates baseline anti-spam and anti-phishing policies in Exchange Online.",
    description: "Connects to Exchange Online and creates baseline anti-spam and anti-phishing policies. Policies created: EXO-Spam-Baseline and EXO-Phishing-Baseline. Includes spam/phishing quarantine, bulk threshold, mailbox intelligence, spoof intelligence, and safety tips.",
    parameters: [],
    example: ".\\Set-AntiSpamPolicies.ps1",
  },
  {
    module: "exchange",
    file: "Set-MailboxAuditLog.ps1",
    desc: "Enables mailbox auditing for all user mailboxes in the tenant to support security investigations and compliance requirements.",
    tags: ["ExchangeOnlineManagement", "Write"],
    synopsis: "Enables mailbox auditing for all mailboxes in Exchange Online.",
    description: "Connects to Exchange Online and enables mailbox auditing for all user mailboxes. Configures audit actions for Owner, Delegate, and Admin logon types based on Microsoft recommended settings.",
    parameters: [],
    example: ".\\Set-MailboxAuditLog.ps1",
  },
  {
    module: "exchange",
    file: "Set-MailboxPermissions.ps1",
    desc: "Bulk assigns FullAccess and SendAs permissions to user mailboxes using a CSV file, streamlining delegation at scale.",
    tags: ["ExchangeOnlineManagement", "CSV Import", "Write"],
    synopsis: "Bulk assigns FullAccess and SendAs permissions to mailboxes from a CSV file.",
    description: "Connects to Exchange Online and assigns FullAccess and/or SendAs permissions to mailboxes based on a CSV file. Required CSV columns: Mailbox, Delegate, FullAccess, SendAs.",
    parameters: [
      { name: "CsvPath", desc: "Path to the CSV file containing mailbox permission assignments." },
    ],
    example: ".\\Set-MailboxPermissions.ps1 -CsvPath '~/mailbox-permissions.csv'",
  },
  {
    module: "exchange",
    file: "Set-SharedMailboxDelegation.ps1",
    desc: "Configures FullAccess and SendAs delegation for shared mailboxes, enabling team access with proper permissions.",
    tags: ["ExchangeOnlineManagement", "Write"],
    synopsis: "Configures FullAccess and SendAs delegation for shared mailboxes.",
    description: "Connects to Exchange Online and assigns FullAccess and SendAs permissions to a shared mailbox for a specified list of delegates.",
    parameters: [
      { name: "SharedMailbox", desc: "UPN or alias of the shared mailbox." },
      { name: "Delegates", desc: "Array of UPNs to assign as delegates." },
      { name: "FullAccess", desc: "Switch to assign FullAccess permission." },
      { name: "SendAs", desc: "Switch to assign SendAs permission." },
    ],
    example: ".\\Set-SharedMailboxDelegation.ps1 -SharedMailbox 'info@contoso.com' -Delegates @('user1@contoso.com','user2@contoso.com') -FullAccess -SendAs",
  },

  // PURVIEW
  {
    module: "purview",
    file: "Enable-AuditLog.ps1",
    desc: "Enables the Unified Audit Log for the tenant — a prerequisite for compliance monitoring, eDiscovery, and security investigations.",
    tags: ["ExchangeOnlineManagement", "Write"],
    synopsis: "Enables the Unified Audit Log in Microsoft Purview.",
    description: "Connects to Exchange Online and enables the Unified Audit Log for the tenant. Also validates the current audit log status. Recommended as a baseline configuration step during tenant onboarding.",
    parameters: [],
    example: ".\\Enable-AuditLog.ps1",
  },
  {
    module: "purview",
    file: "Get-DLPPolicyMatches.ps1",
    githubPath: "purview/Get-DLPPolicyMatches",
    desc: "Exports DLP policy match events from the Unified Audit Log to CSV for compliance monitoring and incident investigation.",
    tags: ["ExchangeOnlineManagement", "CSV Export"],
    synopsis: "Exports DLP policy matches from Microsoft Purview.",
    description: "Connects to the Security & Compliance Center and retrieves DLP policy matches from the Unified Audit Log for a specified date range. Exports the results to a CSV file for reporting purposes.",
    parameters: [
      { name: "StartDate", desc: "Start date for the audit log query. Defaults to 7 days ago." },
      { name: "EndDate", desc: "End date for the audit log query. Defaults to today." },
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-DLPPolicyMatches.ps1 -StartDate '2024-01-01' -EndDate '2024-01-31'",
  },
  {
    module: "purview",
    file: "Get-SensitivityLabelReport.ps1",
    desc: "Exports sensitivity label usage and activity to CSV for data governance insights and information protection reporting.",
    tags: ["ExchangeOnlineManagement", "CSV Export"],
    synopsis: "Exports a sensitivity label usage report from Microsoft Purview.",
    description: "Connects to the Security & Compliance Center and retrieves sensitivity label activity from the Unified Audit Log for a specified date range. Activity types: FileSensitivityLabelApplied, FileSensitivityLabelChanged, FileSensitivityLabelRemoved.",
    parameters: [
      { name: "StartDate", desc: "Start date for the audit log query. Defaults to 7 days ago." },
      { name: "EndDate", desc: "End date for the audit log query. Defaults to today." },
      { name: "OutputPath", desc: "Path to export the CSV file. Defaults to current directory." },
    ],
    example: ".\\Get-SensitivityLabelReport.ps1 -OutputPath '~/Reports'",
  },
  {
    module: "purview",
    file: "Set-DLPPolicies.ps1",
    desc: "Creates 4 baseline DLP policies across Exchange, SharePoint, OneDrive, and MIP — detecting credit cards, EU ID numbers, and IBAN with incident reporting.",
    tags: ["ExchangeOnlineManagement", "Baseline", "GDPR", "Write"],
    synopsis: "Creates baseline DLP policies in Microsoft Purview.",
    description: "Connects to the Security & Compliance Center and creates baseline DLP policies per platform: EXO-GDPR-Warn, SPO-GDPR-Warn, ODB-GDPR-Warn, MIP-GDPR-Warn. Sensitive information types: Credit Card Number, EU National Identification Number, IBAN.",
    parameters: [],
    example: ".\\Set-DLPPolicies.ps1",
  },
  {
    module: "purview",
    file: "Set-RetentionPolicies.ps1",
    desc: "Creates baseline retention policies across Exchange, SharePoint, and OneDrive to meet legal hold and compliance retention requirements.",
    tags: ["ExchangeOnlineManagement", "Baseline", "Write"],
    synopsis: "Creates baseline retention policies in Microsoft Purview.",
    description: "Connects to the Security & Compliance Center and creates baseline retention policies per platform: EXO-7Y-Retain, SPO-7Y-Retain, ODB-7Y-Retain, MIP-7Y-Retain.",
    parameters: [],
    example: ".\\Set-RetentionPolicies.ps1",
  },
  {
    module: "purview",
    file: "Set-SensitivityLabels.ps1",
    desc: "Creates a standard set of sensitivity labels for content classification — enabling information protection across Microsoft 365 workloads.",
    tags: ["ExchangeOnlineManagement", "Baseline", "Write"],
    synopsis: "Creates and configures sensitivity labels in Microsoft Purview.",
    description: "Connects to the Security & Compliance Center and creates a standard set of sensitivity labels: Public, Internal, Confidential, Highly Confidential.",
    parameters: [],
    example: ".\\Set-SensitivityLabels.ps1",
  },
];

const CHANGELOG = [
  { hash: "3b8839c", msg: "created New-BulkEntraUsers.ps1" },
  { hash: "f95d9f4", msg: "created New-TemporaryAccessPass script" },
  { hash: "b48ef4e", msg: "Update README with full script overview" },
  { hash: "2cd39e2", msg: "Add Exchange baseline script collection" },
  { hash: "6f1f33e", msg: "Add Entra ID baseline script collection" },
  { hash: "a4bfa85", msg: "Add Intune baseline script collection" },
  { hash: "92d0102", msg: "Add Get-SensitivityLabelReport script to purview" },
  { hash: "bf46b24", msg: "Add Get-DLPPolicyMatches script to purview" },
  { hash: "9fd8f4b", msg: "Add Set-RetentionPolicies script to purview" },
  { hash: "f93ef92", msg: "Add Enable-AuditLog script to purview" },
  { hash: "777374b", msg: "Add Set-DLPPolicies script to purview" },
  { hash: "576c195", msg: "Add Set-SensitivityLabels script to purview" },
  { hash: "3d4ce86", msg: "Add folder structure and move Get-IntuneDevices to intune" },
  { hash: "589b9cd", msg: "Create Get-IntuneDevices.ps1" },
  { hash: "a4651dc", msg: "Add initial README for powershell-modern-workplace" },
];

/* ===========================
   HELPERS
=========================== */
function getType(filename) {
  if (filename.startsWith("Get-"))    return "get";
  if (filename.startsWith("Set-"))    return "set";
  if (filename.startsWith("New-"))    return "new";
  if (filename.startsWith("Enable-")) return "enable";
  return "get";
}

const COPY_ICON = `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>`;
const LINK_ICON = `<svg class="card-link-icon" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>`;

/* ===========================
   RENDER
=========================== */
function renderScripts() {
  const list = document.getElementById("script-list");

  MODULES.forEach((mod) => {
    const scripts = SCRIPTS.filter((s) => s.module === mod.id);

    const group = document.createElement("div");
    group.className = "module-group";
    group.dataset.module = mod.id;

    group.innerHTML = `
      <div class="module-header">
        <div class="module-icon" style="--c: ${mod.color};">${mod.icon}</div>
        <h3>${mod.label}</h3>
        <span class="module-tag">${mod.tag}</span>
      </div>
      <div class="cards"></div>
    `;

    const cardsEl = group.querySelector(".cards");

    scripts.forEach((s) => {
      const type = getType(s.file);
      const ghPath = s.githubPath || `${s.module}/${s.file}`;
      const ghUrl = GITHUB_BASE + ghPath;

      const hasParams = s.parameters && s.parameters.length > 0;
      const paramsHtml = hasParams
        ? `<table class="params-table">
            <thead><tr><th>Parameter</th><th>Description</th></tr></thead>
            <tbody>${s.parameters.map((p) => `<tr><td>-${p.name}</td><td>${p.desc}</td></tr>`).join("")}</tbody>
          </table>`
        : `<span style="font-size:0.8rem;color:var(--text-faint);">No parameters.</span>`;

      const card = document.createElement("div");
      card.className = "card";
      card.dataset.module = s.module;
      card.dataset.tags = s.tags.join(" ").toLowerCase() + " " + s.file.toLowerCase() + " " + s.desc.toLowerCase();

      card.innerHTML = `
        <div class="card-main">
          <div class="card-header">
            <span class="card-type ${type}">${type.toUpperCase()}</span>
            <a class="card-name-link" href="${ghUrl}" target="_blank" rel="noopener" title="View on GitHub">
              <code class="card-name">${s.file}</code>
              ${LINK_ICON}
            </a>
            <button class="card-copy-btn" data-copy="${s.file}" title="Copy filename">${COPY_ICON}</button>
          </div>
          <p>${s.desc}</p>
          <div class="card-footer">
            ${s.tags.map((t) => `<span class="tag">${t}</span>`).join("")}
          </div>
        </div>
        <button class="card-accordion-btn" aria-expanded="false">
          <span>Details &amp; Usage</span>
          <svg class="accordion-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
        </button>
        <div class="card-details">
          <div>
            <div class="details-section-label">Description</div>
            <div class="details-desc">${s.description}</div>
          </div>
          <div>
            <div class="details-section-label">Parameters</div>
            ${paramsHtml}
          </div>
          <div>
            <div class="details-section-label">Example</div>
            <div class="example-block">
              ${s.example.replace(/\n/g, "<br>")}
              <button class="example-copy-btn" data-copy="${s.example.replace(/"/g, "&quot;")}" title="Copy example">${COPY_ICON}</button>
            </div>
          </div>
        </div>
      `;

      // Accordion toggle
      const btn = card.querySelector(".card-accordion-btn");
      const details = card.querySelector(".card-details");
      btn.addEventListener("click", () => {
        const open = details.classList.toggle("open");
        btn.classList.toggle("open", open);
        btn.setAttribute("aria-expanded", open);
      });

      cardsEl.appendChild(card);
    });

    list.appendChild(group);
  });
}

function renderChangelog() {
  const el = document.getElementById("changelog-list");
  el.innerHTML = CHANGELOG.map(
    (c, i) => `
    <div class="timeline-item">
      <div class="timeline-msg">${c.msg}</div>
      <div class="timeline-hash">${c.hash}</div>
    </div>`
  ).join("");
}

/* ===========================
   COPY TOAST
=========================== */
let toastTimer = null;

function showToast(msg = "Copied!") {
  const toast = document.getElementById("toast");
  toast.textContent = msg;
  toast.classList.add("show");
  if (toastTimer) clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove("show"), 1800);
}

function copyText(text) {
  navigator.clipboard.writeText(text).then(() => showToast()).catch(() => {
    const el = document.createElement("textarea");
    el.value = text;
    el.style.position = "fixed";
    el.style.opacity = "0";
    document.body.appendChild(el);
    el.select();
    document.execCommand("copy");
    document.body.removeChild(el);
    showToast();
  });
}

document.addEventListener("click", (e) => {
  const btn = e.target.closest("[data-copy]");
  if (btn) copyText(btn.dataset.copy);
});

/* ===========================
   SEARCH + FILTER
=========================== */
function applyFilters(filter, query) {
  const groups = document.querySelectorAll(".module-group");
  const cards = document.querySelectorAll(".card");
  let visible = 0;

  cards.forEach((card) => {
    const mod = card.dataset.module;
    const tags = (card.dataset.tags || "").toLowerCase();
    const matchFilter = filter === "all" || mod === filter;
    const matchSearch = !query || tags.includes(query);
    const show = matchFilter && matchSearch;
    card.classList.toggle("hidden", !show);
    if (show) visible++;
  });

  groups.forEach((g) => {
    const hasVisible = [...g.querySelectorAll(".card")].some((c) => !c.classList.contains("hidden"));
    g.classList.toggle("hidden", !hasVisible);
  });

  document.getElementById("no-results").classList.toggle("hidden", visible > 0);
}

function initControls() {
  let activeFilter = "all";
  let searchQuery = "";

  const searchInput = document.getElementById("search");
  const searchClear = document.getElementById("search-clear");
  const filterTabs = document.getElementById("filter-tabs");

  searchInput.addEventListener("input", () => {
    searchQuery = searchInput.value.toLowerCase().trim();
    searchClear.classList.toggle("visible", searchQuery.length > 0);
    applyFilters(activeFilter, searchQuery);
  });

  searchClear.addEventListener("click", () => {
    searchInput.value = "";
    searchQuery = "";
    searchClear.classList.remove("visible");
    searchInput.focus();
    applyFilters(activeFilter, searchQuery);
  });

  filterTabs.addEventListener("click", (e) => {
    const tab = e.target.closest(".tab");
    if (!tab) return;
    activeFilter = tab.dataset.filter;
    filterTabs.querySelectorAll(".tab").forEach((t) => t.classList.remove("active"));
    tab.classList.add("active");
    applyFilters(activeFilter, searchQuery);
  });
}

/* ===========================
   INIT
=========================== */
renderScripts();
renderChangelog();
initControls();
