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

Create an Azure AD application that represents your GitHub Actions workflows.

**Using Azure Portal**:

1. **Sign in to Azure Portal**: Navigate to **Azure Active Directory** → **App Registrations**
2. **Create new registration**:
   - Click **"New registration"**
   - **Name**: `GitHub-Actions-OIDC-AzureInfraDemos` (or customize for your fork)
   - **Supported account types**: "Accounts in this organizational directory only"
   - **Redirect URI**: Leave blank
   - Click **"Register"**
3. **Note the following values** (needed for later steps):
   - **Application (client) ID** — Found on the Overview page
   - **Directory (tenant) ID** — Found on the Overview page

**Using Azure CLI** (PowerShell):

```powershell
# Create app registration
$app = az ad app create --display-name "GitHub-Actions-OIDC-AzureInfraDemos" | ConvertFrom-Json

# Create service principal for the app
az ad sp create --id $app.appId

# Display the values you'll need
Write-Host "✅ App Registration Created"
Write-Host "Client ID: $($app.appId)"
Write-Host "Tenant ID: $(az account show --query tenantId -o tsv)"
Write-Host ""
Write-Host "Save these values — you'll need them in Step 4."
```

**Using Azure CLI** (Bash):

```bash
# Create app registration
app=$(az ad app create --display-name "GitHub-Actions-OIDC-AzureInfraDemos")
appId=$(echo $app | jq -r '.appId')

# Create service principal for the app
az ad sp create --id $appId

# Display the values you'll need
echo "✅ App Registration Created"
echo "Client ID: $appId"
echo "Tenant ID: $(az account show --query tenantId -o tsv)"
echo ""
echo "Save these values — you'll need them in Step 4."
```

### Step 2: Create Federated Credential

Federated credentials link your Azure AD app to your GitHub repository, allowing GitHub Actions workflows to authenticate without secrets.

**Important**: This repository uses **`workflow_dispatch`** triggers (manual workflow runs). The federated credential subject must match this pattern.

**Using Azure Portal**:

1. **Navigate to your App Registration** → **Certificates & secrets**
2. **Click "Federated credentials" tab** → **"Add credential"**
3. **Select scenario**: "GitHub Actions deploying Azure resources"
4. **Configure credential**:
   - **Organization**: Your GitHub username or organization (e.g., `yourname`)
   - **Repository**: Repository name (e.g., `Azure-Infra-Demos`)
   - **Entity type**: Select **"Environment"** (see note below)
   - **Environment name**: Leave blank or use `production`
   - **Name**: `GitHub-Actions-WorkflowDispatch`
5. **Click "Add"**

**Note**: While the Azure Portal doesn't have a direct option for `workflow_dispatch`, using the "Environment" entity type allows broader workflow access. For precise control, use the Azure CLI method below.

**Using Azure CLI** (PowerShell) — **Recommended for workflow_dispatch**:

```powershell
# Replace with your values
$appId = "your-app-id-from-step-1"          # From Step 1
$githubOrg = "your-github-username"         # Your GitHub username or org
$githubRepo = "Azure-Infra-Demos"           # Your repository name

# Create federated credential for main branch (supports workflow_dispatch, push, pull_request)
az ad app federated-credential create `
  --id $appId `
  --parameters "{
    `"name`": `"GitHub-Actions-Main-Branch`",
    `"issuer`": `"https://token.actions.githubusercontent.com`",
    `"subject`": `"repo:$githubOrg/$githubRepo:ref:refs/heads/main`",
    `"description`": `"GitHub Actions OIDC for main branch - supports workflow_dispatch`",
    `"audiences`": [`"api://AzureADTokenExchange`"]
  }"

Write-Host "✅ Federated credential created for main branch"
Write-Host "This credential allows workflow_dispatch, push, and pull_request triggers on main branch."
```

**Using Azure CLI** (Bash):

```bash
# Replace with your values
appId="your-app-id-from-step-1"          # From Step 1
githubOrg="your-github-username"         # Your GitHub username or org
githubRepo="Azure-Infra-Demos"           # Your repository name

# Create federated credential for main branch
az ad app federated-credential create \
  --id $appId \
  --parameters "{
    \"name\": \"GitHub-Actions-Main-Branch\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:$githubOrg/$githubRepo:ref:refs/heads/main\",
    \"description\": \"GitHub Actions OIDC for main branch - supports workflow_dispatch\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

echo "✅ Federated credential created for main branch"
echo "This credential allows workflow_dispatch, push, and pull_request triggers on main branch."
```

**Explanation of Federated Credential Subject**:

The `subject` field determines which GitHub Actions workflows can authenticate:

| Subject Pattern | Allows |
|-----------------|--------|
| `repo:owner/repo:ref:refs/heads/main` | Workflows triggered from `main` branch (push, pull_request, **workflow_dispatch**) |
| `repo:owner/repo:pull_request` | Workflows triggered by pull requests from any branch |
| `repo:owner/repo:environment:production` | Workflows using the `production` environment |
| `repo:owner/repo:ref:refs/heads/dev` | Workflows triggered from `dev` branch |

**For this repository**, the recommended subject is `repo:owner/repo:ref:refs/heads/main` because:
- ✅ Supports `workflow_dispatch` (manual runs from Actions tab)
- ✅ Supports `push` events to main branch
- ✅ Supports `pull_request` targeting main branch
- ✅ Single credential covers all common scenarios

**Optional**: Create additional federated credentials for other branches or pull requests:

```powershell
# Credential for pull requests from any branch
az ad app federated-credential create `
  --id $appId `
  --parameters "{
    `"name`": `"GitHub-Actions-PullRequests`",
    `"issuer`": `"https://token.actions.githubusercontent.com`",
    `"subject`": `"repo:$githubOrg/$githubRepo:pull_request`",
    `"description`": `"GitHub Actions OIDC for all pull requests`",
    `"audiences`": [`"api://AzureADTokenExchange`"]
  }"
```

### Step 3: Assign RBAC Role to Service Principal

Grant the service principal permissions to deploy resources in your Azure subscription.

**Minimum Required Role**: **Contributor** at subscription or resource group scope

**Using Azure Portal**:

1. **Navigate to your Azure subscription** in the Portal → **Access control (IAM)**
2. **Click "Add role assignment"**
3. **Select role**: **"Contributor"**
4. **Click "Next"**
5. **Assign access to**: "User, group, or service principal"
6. **Click "+ Select members"**
7. **Search for**: Your app registration name (e.g., `GitHub-Actions-OIDC-AzureInfraDemos`)
8. **Select** the app registration from search results
9. **Click "Select"**, then **"Review + assign"**

**Using Azure CLI** (PowerShell):

```powershell
# Get your subscription ID
$subscriptionId = az account show --query id -o tsv

# Get the app ID (from Step 1)
$appId = "your-app-id-from-step-1"

# Get the service principal object ID (NOT the app ID)
$spObjectId = az ad sp list --filter "appId eq '$appId'" --query "[0].id" -o tsv

# Assign Contributor role at subscription scope
az role assignment create `
  --role "Contributor" `
  --assignee-object-id $spObjectId `
  --assignee-principal-type "ServicePrincipal" `
  --scope "/subscriptions/$subscriptionId"

Write-Host "✅ Contributor role assigned to service principal"
Write-Host "Scope: Subscription $subscriptionId"
```

**Using Azure CLI** (Bash):

```bash
# Get your subscription ID
subscriptionId=$(az account show --query id -o tsv)

# Get the app ID (from Step 1)
appId="your-app-id-from-step-1"

# Get the service principal object ID
spObjectId=$(az ad sp list --filter "appId eq '$appId'" --query "[0].id" -o tsv)

# Assign Contributor role at subscription scope
az role assignment create \
  --role "Contributor" \
  --assignee-object-id $spObjectId \
  --assignee-principal-type "ServicePrincipal" \
  --scope "/subscriptions/$subscriptionId"

echo "✅ Contributor role assigned to service principal"
echo "Scope: Subscription $subscriptionId"
```

**Least Privilege Alternative**: Assign roles at resource group level for tighter security:

```powershell
# Create a dedicated resource group for pattern deployments
$rgName = "rg-pattern-demos"
$location = "australiaeast"

az group create --name $rgName --location $location

# Assign Contributor role at resource group scope only
az role assignment create `
  --role "Contributor" `
  --assignee-object-id $spObjectId `
  --assignee-principal-type "ServicePrincipal" `
  --scope "/subscriptions/$subscriptionId/resourceGroups/$rgName"

Write-Host "✅ Contributor role assigned at resource group scope"
Write-Host "The service principal can only deploy to resource group: $rgName"
```

**Note**: Resource group-scoped permissions require you to pre-create the resource group and specify `resourceGroupName` when running workflows. Subscription-scoped permissions allow workflows to create resource groups automatically.

### Step 4: Configure GitHub Repository Secrets

Store the Azure identifiers as **GitHub repository secrets** (not environment variables).

1. **Navigate to your forked repository on GitHub**
2. **Go to Settings** → **Secrets and variables** → **Actions**
3. **Click "New repository secret"** and add each of the following:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `AZURE_CLIENT_ID` | Application (client) ID from Step 1 | Azure Portal → App Registrations → Your App → Overview |
| `AZURE_TENANT_ID` | Directory (tenant) ID from Step 1 | Azure Portal → App Registrations → Your App → Overview |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | Azure Portal → Subscriptions → Your Subscription → Subscription ID |

**Steps to Add Each Secret**:

1. Click **"New repository secret"**
2. **Name**: Enter the exact secret name (e.g., `AZURE_CLIENT_ID`)
3. **Secret**: Paste the corresponding value
4. Click **"Add secret"**
5. Repeat for all three secrets

**Using Azure CLI to Get Your Values**:

```powershell
# Get your tenant ID
$tenantId = az account show --query tenantId -o tsv
Write-Host "AZURE_TENANT_ID: $tenantId"

# Get your subscription ID
$subscriptionId = az account show --query id -o tsv
Write-Host "AZURE_SUBSCRIPTION_ID: $subscriptionId"

# Get your app (client) ID (replace with your app name)
$clientId = az ad app list --display-name "GitHub-Actions-OIDC-AzureInfraDemos" --query "[0].appId" -o tsv
Write-Host "AZURE_CLIENT_ID: $clientId"

Write-Host ""
Write-Host "Copy these values to GitHub Secrets in your repository."
```

**Security Notes**:

- ✅ **DO** store these as repository secrets (encrypted by GitHub)
- ✅ **DO** restrict repository access to trusted collaborators
- ❌ **DO NOT** store these as environment variables in workflows
- ❌ **DO NOT** commit these values to the repository
- ❌ **DO NOT** use organization secrets unless you understand the security implications

**Verification**:

After adding the secrets, you should see them listed under Repository secrets:
- `AZURE_CLIENT_ID` (set)
- `AZURE_TENANT_ID` (set)
- `AZURE_SUBSCRIPTION_ID` (set)

Secret values are hidden after creation and cannot be viewed again (only updated or deleted).

### Step 5: Verify OIDC Configuration

Test your OIDC setup by running a simple deployment workflow.

1. **Navigate to your repository** → **Actions** tab
2. **Select** "Deploy Pattern to Azure" workflow from the left sidebar
3. **Click "Run workflow"** button (top right)
4. **Fill in the workflow inputs**:
   - **subscriptionId**: Paste your Azure subscription ID (from Step 4)
   - **location**: Select a region close to you (e.g., `australiaeast`, `eastus`, `westeurope`)
   - **prefix**: Enter a short prefix (e.g., `test`, `demo`, your initials)
   - **patternSlug**: Enter `hub-spoke-network` (smallest pattern for testing)
   - **resourceGroupName**: Leave blank (auto-generated)
   - **extraParamsJson**: Enter `{"deployFirewall": false, "deployVpnGateway": false}` (minimal deployment)
5. **Click** the green **"Run workflow"** button
6. **Wait** a few seconds, then refresh the page
7. **Click** on the new workflow run to view progress

**Expected Results**:

✅ **Validate Bicep Template** job completes successfully:
```
Run azure/login@v2
  with:
    client-id: ***
    tenant-id: ***
    subscription-id: ***
Login successful.
```

✅ **Deploy to Azure** job completes successfully with deployment outputs:
```
🎉 Deployment Successful
Resource Group: rg-test-hub-spoke-network
Location: australiaeast
Pattern: hub-spoke-network
```

**Troubleshooting Common Errors**:

❌ **Error**: `AADSTS70021: No matching federated identity record found`

**Solution**: The federated credential subject doesn't match. Verify in Azure Portal → App Registration → Certificates & secrets → Federated credentials:
- **Issuer**: `https://token.actions.githubusercontent.com`
- **Subject**: `repo:{your-github-username}/{your-repo-name}:ref:refs/heads/main`
- **Audiences**: `api://AzureADTokenExchange`

Ensure the repository name matches exactly (case-sensitive).

❌ **Error**: `AuthorizationFailed: The client '...' does not have authorization to perform action 'Microsoft.Resources/deployments/write'`

**Solution**: The service principal lacks permissions. Verify:
- Contributor role is assigned in Azure Portal → Subscriptions → Access control (IAM)
- Wait 5-10 minutes for role assignments to propagate
- Check you're using the correct subscription ID in workflow inputs

❌ **Error**: `ResourceGroupNotFound: Resource group 'rg-test-hub-spoke-network' could not be found.`

**Solution**: This error occurs if your service principal has resource group-scoped permissions only. Either:
- Pre-create the resource group and specify `resourceGroupName` in workflow inputs, OR
- Assign Contributor role at subscription scope (allows workflow to create resource groups)

❌ **Error**: `InvalidClientId: The client ID '...' is not valid`

**Solution**: Check the `AZURE_CLIENT_ID` secret in GitHub:
- Go to Settings → Secrets and variables → Actions
- Delete and recreate `AZURE_CLIENT_ID` with the correct Application (client) ID from Azure Portal

**Clean Up After Testing**:

After verifying OIDC works, clean up the test resources:

```bash
az group delete --name rg-test-hub-spoke-network --yes --no-wait
```

Or use the "Destroy Azure Resources" workflow in the Actions tab.

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
