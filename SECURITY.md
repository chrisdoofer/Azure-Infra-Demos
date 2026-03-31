# Security Policy

## No Secrets in Repository

This repository follows a **secrets-free** model. All authentication uses:

- **GitHub Actions**: OpenID Connect (OIDC) federated credentials
- **Azure Portal deployments**: Interactive browser sessions
- **Local development**: Azure CLI (`az login`) or Azure Developer CLI (`azd auth login`)

**Never commit**:
- Service principal secrets or passwords
- Storage account keys
- Connection strings
- API keys or tokens
- Personal access tokens (PATs)

## GitHub OIDC Federated Credential Setup

GitHub Actions workflows authenticate to Azure using OIDC, eliminating long-lived secrets. Follow these steps to configure OIDC for your forked repository.

### Prerequisites
- Azure subscription with Owner or User Access Administrator role
- GitHub repository (fork of Azure-Infra-Demos)
- Azure CLI installed locally (for setup commands)

### Step 1: Create Azure AD App Registration

1. **Sign in to Azure Portal**: Navigate to Azure Active Directory → App Registrations
2. **Create new registration**:
   - Click "New registration"
   - Name: `GitHub-Actions-OIDC-{YourRepoName}` (e.g., `GitHub-Actions-OIDC-AzureInfraDemos`)
   - Supported account types: "Accounts in this organizational directory only"
   - Redirect URI: Leave blank
   - Click "Register"
3. **Note the following values** (needed later):
   - **Application (client) ID** — Found on the Overview page
   - **Directory (tenant) ID** — Found on the Overview page

**Azure CLI Alternative**:

```powershell
# Create app registration
$app = az ad app create --display-name "GitHub-Actions-OIDC-AzureInfraDemos" | ConvertFrom-Json

# Create service principal for the app
az ad sp create --id $app.appId

# Note these values
Write-Host "Client ID: $($app.appId)"
Write-Host "Tenant ID: $(az account show --query tenantId -o tsv)"
```

### Step 2: Create Federated Credential

Federated credentials link your Azure AD app to your GitHub repository, allowing GitHub Actions to authenticate.

1. **Navigate to your App Registration** → "Certificates & secrets"
2. **Click "Federated credentials" tab** → "Add credential"
3. **Select scenario**: "GitHub Actions deploying Azure resources"
4. **Configure credential**:
   - **Organization**: Your GitHub username or organization name (e.g., `yourname`)
   - **Repository**: Repository name (e.g., `Azure-Infra-Demos`)
   - **Entity type**: "Branch"
   - **GitHub branch name**: `main` (or your default branch)
   - **Name**: `GitHub-Actions-Main-Branch`
5. **Click "Add"**

**Azure CLI Alternative**:

```powershell
# Replace with your values
$appId = "your-app-id-from-step-1"
$githubOrg = "your-github-username"
$githubRepo = "Azure-Infra-Demos"

# Create federated credential for main branch
az ad app federated-credential create `
  --id $appId `
  --parameters '{
    "name": "GitHub-Actions-Main-Branch",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$githubOrg'/'$githubRepo':ref:refs/heads/main",
    "description": "GitHub Actions OIDC for main branch",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

**Optional**: Create additional federated credentials for pull requests:

```powershell
az ad app federated-credential create `
  --id $appId `
  --parameters '{
    "name": "GitHub-Actions-Pull-Requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$githubOrg'/'$githubRepo':pull_request",
    "description": "GitHub Actions OIDC for PRs",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Step 3: Assign RBAC Role to Service Principal

Grant the service principal permissions to deploy resources in your Azure subscription.

1. **Navigate to your Azure subscription** in the Portal → "Access control (IAM)"
2. **Click "Add role assignment"**
3. **Select role**: "Contributor" (minimum required; see below for workflow-specific roles)
4. **Assign access to**: "User, group, or service principal"
5. **Select members**: Search for your app registration name (e.g., `GitHub-Actions-OIDC-AzureInfraDemos`)
6. **Click "Review + assign"**

**Azure CLI Alternative**:

```powershell
# Get subscription ID
$subscriptionId = az account show --query id -o tsv

# Get service principal object ID
$spObjectId = az ad sp list --display-name "GitHub-Actions-OIDC-AzureInfraDemos" --query "[0].id" -o tsv

# Assign Contributor role
az role assignment create `
  --role "Contributor" `
  --assignee-object-id $spObjectId `
  --assignee-principal-type "ServicePrincipal" `
  --scope "/subscriptions/$subscriptionId"
```

**Least Privilege Alternative**: If you want stricter permissions, assign roles at resource group level instead of subscription level:

```powershell
az role assignment create `
  --role "Contributor" `
  --assignee-object-id $spObjectId `
  --assignee-principal-type "ServicePrincipal" `
  --scope "/subscriptions/$subscriptionId/resourceGroups/rg-pattern-demos"
```

### Step 4: Configure GitHub Repository Secrets

Store the Azure identifiers as **GitHub repository secrets** (not environment variables).

1. **Navigate to your GitHub repository** → Settings → Secrets and variables → Actions
2. **Click "New repository secret"** and add each of the following:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `AZURE_CLIENT_ID` | Application (client) ID from Step 1 | App Registration → Overview |
| `AZURE_TENANT_ID` | Directory (tenant) ID from Step 1 | App Registration → Overview |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | Azure Portal → Subscriptions |

**DO NOT** store these as environment secrets or commit them to the repository.

### Step 5: Verify OIDC Configuration

Test the configuration with a simple GitHub Actions workflow:

1. **Navigate to your repository** → Actions tab
2. **Select "Deploy Pattern" workflow** (or create a test workflow)
3. **Click "Run workflow"** → Select a pattern and region
4. **Monitor the workflow run** — Check for successful Azure login in the workflow logs

**Expected log output**:

```
Run azure/login@v2
  with:
    client-id: ***
    tenant-id: ***
    subscription-id: ***
Login successful.
```

If authentication fails, verify:
- Federated credential issuer is `https://token.actions.githubusercontent.com`
- Federated credential subject matches your repository exactly (case-sensitive)
- Service principal has Contributor role on the target subscription or resource group

## Required Azure RBAC Roles

GitHub Actions workflows require the following Azure RBAC roles depending on deployment actions:

### Minimum (Most Patterns)
- **Contributor** — Deploy resources, modify configurations, delete resources

### Workflow-Specific Requirements

| Workflow / Action | Required Role | Scope | Reason |
|-------------------|---------------|-------|--------|
| Deploy pattern | Contributor | Subscription or Resource Group | Create/modify/delete resources |
| Assign RBAC roles to deployed resources | User Access Administrator | Subscription or Resource Group | Grant managed identities access to Key Vault, Storage, etc. |
| Deploy Azure Policy | Resource Policy Contributor | Subscription | Create policy assignments |
| Configure diagnostic settings | Monitoring Contributor | Resource Group | Enable Azure Monitor logs |

**Recommendation**: Start with Contributor at subscription level. If security policies require stricter permissions, assign Contributor at resource group level and grant additional roles (e.g., User Access Administrator) only where needed.

## Pattern Security Defaults

All patterns in this repository follow these security best practices:

### Managed Identities
- Use **system-assigned managed identities** for Azure resources (VMs, App Services, Function Apps, Container Apps)
- Grant identities least-privilege RBAC roles (e.g., Storage Blob Data Contributor, not Contributor)
- **Never** use service principal client secrets or certificates in deployed resources

### HTTPS/TLS
- Enforce HTTPS-only for:
  - App Services and Function Apps (`httpsOnly: true`)
  - Storage Accounts (`supportsHttpsTrafficOnly: true`)
  - API Management
  - Application Gateway
- Use TLS 1.2 minimum (disable TLS 1.0 and 1.1)

### Key Vault Integration
- Store secrets, connection strings, and certificates in **Azure Key Vault**
- Reference secrets in Bicep using `getSecret()` function
- Enable soft delete and purge protection on Key Vaults
- Grant managed identities "Key Vault Secrets User" role, not "Key Vault Contributor"

### Network Security
- **Deny-by-default** NSG rules (deny all inbound, allow specific ports)
- Use private endpoints for Azure PaaS services (Storage, SQL, Cosmos DB) where feasible
- Disable public network access for sensitive resources
- Enable Azure Firewall or Network Security Groups on all subnets

### Least Privilege
- Deploy resources with minimum required permissions
- Use built-in Azure RBAC roles (e.g., "Storage Blob Data Reader") instead of "Contributor"
- Avoid "Owner" role assignments in patterns

## Reporting Security Issues

**DO NOT** open public GitHub issues for security vulnerabilities.

To report a security vulnerability:

1. **Email**: Send details to the repository maintainer (Chris Bennett) — email address in GitHub profile
2. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested remediation (if known)
3. **Response time**: You will receive acknowledgment within 48 hours and a remediation plan within 7 days

**What qualifies as a security issue**:
- Secrets accidentally committed to the repository
- Bicep templates deploying resources with excessive permissions
- Authentication bypass or privilege escalation in deployed resources
- Insecure defaults (e.g., HTTPS disabled, public access allowed)

**What does NOT qualify**:
- General Azure security questions (ask on Azure forums or Microsoft support)
- Requests to add security features to patterns (open a feature request issue instead)
- Disclosure of vulnerabilities in Azure services themselves (report to [Microsoft Security Response Center](https://msrc.microsoft.com/))

## Content Disclaimer

Pattern documentation in this repository is **original content** written for business communication and demonstration purposes. It references but does not copy Microsoft Azure documentation.

**Authoritative Sources**:
- **Azure Architecture Center**: https://learn.microsoft.com/azure/architecture/
- **Azure Service Documentation**: https://learn.microsoft.com/azure/
- **Azure Well-Architected Framework**: https://learn.microsoft.com/azure/well-architected/

Always refer to official Microsoft documentation for production planning, compliance guidance, and service limits.

## Security Best Practices for Users

If you fork this repository or deploy patterns:

1. **Rotate credentials regularly** — Even with OIDC, review federated credentials quarterly and remove unused ones
2. **Monitor deployments** — Enable Azure Monitor alerts for unexpected resource creation or deletion
3. **Tag resources** — Use `ttlHours` tags to enable automatic cleanup of demo environments
4. **Review costs** — Set Azure Cost Management budgets and alerts to prevent runaway spending
5. **Limit scope** — Deploy patterns to dedicated resource groups or subscriptions isolated from production
6. **Enable Azure Defender** — For production deployments, enable Microsoft Defender for Cloud for threat protection
7. **Audit logs** — Retain Azure Activity Logs and NSG Flow Logs for security investigations

## Compliance and Governance

Patterns in this repository support but do not guarantee compliance with specific regulations (e.g., HIPAA, PCI DSS, SOC 2). 

**Compliance responsibility**:
- **Pattern authors**: Provide security best practices and defaults
- **Users**: Validate patterns meet your organisation's compliance requirements before production use
- **Azure platform**: Microsoft Azure maintains compliance certifications; see [Azure Compliance](https://learn.microsoft.com/azure/compliance/)

**Governance tools supported**:
- Azure Policy assignments (patterns deploy with tags supporting policy enforcement)
- Resource locks (users can apply locks post-deployment)
- RBAC least privilege (patterns use managed identities and scoped roles)
- Diagnostic settings (patterns enable Azure Monitor where applicable)

---

**Last Updated**: 2026-03-31  
**Contact**: Chris Bennett (see GitHub profile for contact methods)
