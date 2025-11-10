# Entra ID (Azure AD successor) Assessment Guide

> This is a community forked/adapted assessment guide to help consultants and customers run an Entra (Azure AD) configuration assessment. Credit: This guide is adapted from Microsoft’s Azure AD Assessment content — see Microsoft’s original Azure AD Assessment Guide for reference. citeturn0view0

---

## Goals
- Provide a reproducible, GitHub-publishable Entra ID assessment workflow for consultants and customers.
- Keep a clear engagement process: Kick-Off, Pre-Interview, Interview, Post-Interview, Report.
- Supply scripts, templates, and checklists suitable for automation and secure sharing.

---

## Repository layout (recommended)

```
/ (repo root)
├─ README.md                    # This file
├─ LICENSE.md                   # MIT license (or your chosen license)
├─ ASSESSMENT_GUIDE.md          # Long-form guide (this content)
├─ scripts/
│  ├─ collect-data.ps1          # PowerShell data collection script (wrapper)
│  └─ helpers/                  # helper scripts
├─ templates/
│  ├─ interview-worksheet.xlsx  # Interview worksheet template
│  ├─ report-out.pptx           # Report PowerPoint template
│  └─ aadconnect-docs/         # generated AADConnect export examples
├─ pbix/                        # Power BI templates (if distributable)
├─ CHECKLISTS/
│  ├─ pre-interview.md
│  └─ post-interview.md
└─ CONTRIBUTING.md
```

---

## High-level Assessment Workflow

1. **Engagement Kick-Off**
   - Schedule a 30-minute meeting and share the Customer Overview deck.
   - Set expectations (data to be collected, timeframe, deliverables).

2. **Pre-Interview**
   - Provide the customer with the data collection script and instructions.
   - Customer runs the script and securely shares the produced `.aad` data file(s).
   - Assessor prepares local workspace and installs prerequisites (PowerShell 7+, Power BI Desktop, AzureADAssessment module or community equivalent).

3. **Interview**
   - 1–2 hour guided walkthrough using the interview worksheet.
   - Validate portal settings, Conditional Access, Identity Protection, SSO applications, Azure AD Connect, privileged roles, and monitoring.

4. **Post-Interview**
   - Run report generation commands (e.g., Complete-AADAssessmentReports) against the collected `.aad` file(s).
   - Generate Azure AD Connect documenter and ADFS migration artifacts if applicable.
   - Produce final ReportOut PowerPoint and prioritized recommendations.

---

## Data Collection & Tools

> NOTE: Always follow customer policy and GDPR/privacy rules for data handling. Encrypt and transfer collected files securely.

### Recommended tools
- PowerShell 7 or later
- Power BI Desktop (for `.pbit` templates)
- Azure AD Connect Config Documenter (if using AD Connect)
- AzureADAssessment PowerShell module (or forked module with Entra naming)

### Example commands (adapted)

```powershell
# Install module (example)
Install-Module AzureADAssessment -Force -AcceptLicense

# Generate reports from a collected data file
Complete-AADAssessmentReports -Path C:\AzureADAssessment\Customer\AzureADAssessmentData-contoso.aad -OutputDirectory C:\AzureADAssessment\Customer\Report

# Expand AAD Connect config (if provided)
Import-Module AzureADAssessment
Expand-AADAssessAADConnectConfig -CustomerName 'Contoso' -AADConnectProdConfigZipFilePath C:\AzureADAssessment\Customer\AzureADAssessmentData-AADC-PROD.zip -OutputRootPath C:\AzureADAssessment\Customer\Report\AADC
```

(These commands are adapted from Microsoft’s guide — consult upstream docs for the latest module names and parameter changes.) citeturn0view0

---

## Assessment Checks (skeleton)
Create checklists as simple markdown files or spreadsheets. Example areas to cover:

- Tenant basics (name, domains, licenses, tenant settings)
- Identity sources (Azure AD Connect health, sync rules, device writeback)
- Authentication (password policies, SSPR, MFA rollouts)
- Conditional Access (policies, exclusions, service principals)
- Privileged access (PIM, privileged roles, role assignments)
- Application management (enterprise apps, app registrations, OAuth permissions)
- Identity Protection & risk detections
- Monitoring & logging (Azure AD sign-in logs, diagnostic settings, Log Analytics)
- Identity Governance (Entitlement management, access reviews, lifecycle)

---

## Deliverables & Templates
- Interview Worksheet (XLSX) — guided portal walkthrough + interview questions.
- Power BI reports (`.pbit`) — visualize the collected tenant data.
- ReportOut PowerPoint — executive summary, findings, prioritized recommendations.
- AADConnect HTML export — for sync analysis.

(Include these artifacts in `templates/` for easier reuse.)

---

## Attribution & License
This repo is a community-created adaptation for Entra ID assessments. Original Azure AD Assessment content is authored by Microsoft and available under the AzureADAssessment project. Where content or commands are taken from Microsoft’s materials, we include attribution and links back to Microsoft. See Microsoft’s original guide for further legal or licensing statements. citeturn0view0

**Recommended repository LICENSE:** MIT (or your organization’s preferred license). Add a `LICENSE.md` file.

**Suggested credit block (place in README.md):**

> This Entra ID Assessment is adapted from Microsoft’s Azure AD Assessment Guide. Original content © Microsoft. Used with attribution. Link: Microsoft Azure AD Assessment Guide. citeturn0view0

---



---

*End of guide*

