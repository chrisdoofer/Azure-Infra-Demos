# Azure Pattern Demo Portal

A curated collection of production-ready Azure architecture patterns with one-click deployment, comprehensive talk tracks, and business value narratives.

## Overview

The Azure Pattern Demo Portal catalogues reference architectures from the [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/browse/?products=azure), enabling rapid deployment for demonstrations, proof-of-concepts, and production workloads. Each pattern includes:

- **Infrastructure-as-code** (Bicep templates) following Azure best practices
- **Business-focused talk tracks** explaining value, not just features
- **Mermaid architecture diagrams** for clear visual communication
- **Cost estimates and optimisation guidance** for transparent budgeting
- **Deployment via Azure Portal or GitHub Actions** for flexible workflows

## Quick Start

### Setup (One-Time)

1. **Fork this repository** to your GitHub account
2. **Update configuration** in `portal/config/site.ts`:
   ```typescript
   export const siteConfig = {
     githubOwner: 'your-github-username',  // Change this
     githubRepo: 'Azure-Infra-Demos',
     defaultBranch: 'main',                // or 'master'
     templateHosting: 'github-pages',      // or 'github-raw' for public repos
   };
   ```
3. **Enable GitHub Pages**:
   - Navigate to Settings → Pages
   - Source: Select "GitHub Actions"
   - Save
4. **Push to main/master**:
   - The `publish-templates.yml` workflow will automatically deploy ARM templates to GitHub Pages
   - Templates will be accessible at `https://your-username.github.io/Azure-Infra-Demos/patterns/{slug}/azuredeploy.json`
5. **Deploy to Azure buttons now work!**

### Deploy Patterns

Once setup is complete:

1. **Browse patterns** in this repository or at the hosted portal
2. **Click "Deploy to Azure"** on your chosen pattern
3. **Provide parameters** (region, resource names) and deploy — done in 10-20 minutes

## What's Included

### Implemented Patterns ✅

| Pattern | Category | Cost Band | Complexity | Deploy Time |
|---------|----------|-----------|------------|-------------|
| [Hub-Spoke Network Topology](./patterns/hub-spoke-network/) | Networking | Medium | ⚙️⚙️⚙️ | ~15 min |

### Scaffolded Patterns 🔲

The following patterns have basic structure but require full implementation:

- **N-Tier Application** (Web/Compute)
- **Microservices on AKS** (Containers)
- **Event-Driven Architecture** (Integration)
- **Static Web App with Functions API** (Web/Serverless)
- **Azure Landing Zone - Small Enterprise** (Management)
- **Data Lake Analytics** (Analytics)
- **High-Availability Multi-Region Web App** (Web/Compute)

## Deployment Models

### Why Two Template Hosting Options?

**The Problem:** Azure Portal's "Deploy to Azure" buttons require templates at publicly accessible URLs. However:
- Raw GitHub URLs (`raw.githubusercontent.com`) only work for **public repositories**
- Private repositories return 404 errors, breaking Deploy to Azure buttons
- Many organizations use private repos for internal demos

**The Solution:** This repository supports **both** hosting strategies:

1. **GitHub Pages (Recommended)** — Works for private repos on Enterprise/Pro/Team plans
2. **Raw GitHub URLs** — Simple but requires public repository

Configure your preference in `portal/config/site.ts`.

### A. Deploy via Azure Portal

The simplest approach for one-time deployments or demonstrations.

1. Navigate to the pattern directory (e.g., `/patterns/hub-spoke-network/`)
2. Click the "Deploy to Azure" button in the pattern README
3. Sign in to the Azure Portal
4. Select subscription, resource group, and parameters
5. Click "Review + Create" → "Create"

Resources deploy to **your** Azure subscription using **your** credentials. No OIDC setup required.

### B. Deploy via GitHub Actions

For repeatable deployments, automation, or CI/CD integration.

1. **Fork this repository** to your GitHub account
2. **Configure OIDC** (see [SECURITY.md](./SECURITY.md) for detailed steps):
   - Create Azure AD App Registration
   - Create federated credential for GitHub Actions
   - Assign Contributor role to service principal
   - Store secrets in GitHub repository
3. **Run the deployment workflow**:
   - Navigate to Actions → "Deploy Pattern"
   - Click "Run workflow"
   - Select pattern (e.g., `hub-spoke-network`) and parameters
   - Monitor deployment progress

The GitHub Actions workflow deploys to your Azure subscription using the configured service principal. No interactive sign-in required.

## Prerequisites

### For Azure Portal Deployments
- Azure subscription with Contributor or Owner role
- Sufficient quota for pattern resources (e.g., VNets, Firewall, Compute)

### For GitHub Actions Deployments
- All Azure Portal prerequisites
- GitHub account (free tier sufficient)
- OIDC configured between GitHub and Azure (see [SECURITY.md](./SECURITY.md))

## OIDC Setup (Quick Overview)

GitHub Actions workflows authenticate to Azure using OpenID Connect (OIDC), eliminating the need for long-lived secrets.

**High-Level Steps** (see [SECURITY.md](./SECURITY.md) for complete instructions):

1. Create Azure AD App Registration
2. Create federated credential linking the app to your GitHub repository
3. Assign Contributor role to the app's service principal on your subscription
4. Store three secrets in GitHub:
   - `AZURE_CLIENT_ID` — App Registration client ID
   - `AZURE_TENANT_ID` — Azure AD tenant ID
   - `AZURE_SUBSCRIPTION_ID` — Target subscription ID

**Time required**: 10-15 minutes for first-time setup. Reuse the same app registration for all patterns.

## How to Add a New Pattern

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the complete pattern authoring guide.

**Quick Checklist**:
1. Create `/patterns/{slug}/` directory using the `_template` structure
2. Write `main.bicep` with parameterised infrastructure
3. Generate `azuredeploy.json` (`az bicep build`)
4. Write `README.md`, `talk-track.md`, and `architecture.mmd`
5. Add entry to `/patterns/catalog/patterns.json`
6. Test locally with `az deployment group validate`
7. Submit pull request

## Pattern Catalogue

All patterns are registered in `/patterns/catalog/patterns.json` with metadata including:

- **Title & summary** — Plain-language description
- **Category & tags** — For discovery and filtering
- **Primary Azure services** — Key components deployed
- **Cost band** — Low / Medium / High (monthly estimates)
- **Complexity rating** — 1-5 scale (1 = simple, 5 = advanced)
- **Typical deploy time** — Minutes to full deployment
- **Deployment modes** — Portal, GitHub Actions, or both

## Portal Development

The web portal is a Next.js application consuming the pattern catalogue.

### Run Locally

```powershell
cd portal
npm install
npm run dev
```

Browse to `http://localhost:3000` to see the pattern catalogue.

### Project Structure

```
portal/
├── app/                 # Next.js app routes
├── components/          # React components
├── data/                # patterns.json symlink
├── public/              # Static assets
└── package.json
```

## Repository Structure

```
Azure-Infra-Demos/
├── patterns/
│   ├── hub-spoke-network/       # Fully implemented pattern
│   │   ├── main.bicep            # Infrastructure-as-code
│   │   ├── azuredeploy.json      # ARM JSON (generated)
│   │   ├── README.md             # Pattern documentation
│   │   ├── talk-track.md         # Business value narrative
│   │   ├── architecture.mmd      # Mermaid diagram
│   │   └── parameters/
│   │       └── dev.parameters.json
│   ├── catalog/
│   │   └── patterns.json         # Master pattern registry
│   └── _template/                # Pattern scaffolding template
├── portal/                       # Next.js web application
├── infra/                        # Infrastructure for hosting portal
├── .github/workflows/            # CI/CD and deployment workflows
├── README.md                     # This file
├── CONTRIBUTING.md               # Pattern authoring guide
└── SECURITY.md                   # OIDC setup and security guidance
```

## Security & Secrets

**No secrets are stored in this repository.** All authentication uses OIDC federated credentials or Azure CLI interactive login.

- **GitHub Actions**: Uses OIDC with federated credentials (no service principal secrets)
- **Azure Portal deployments**: Uses your interactive browser session
- **Local development**: Uses Azure CLI (`az login`) or Azure Developer CLI (`azd auth login`)

See [SECURITY.md](./SECURITY.md) for security best practices, OIDC configuration, and vulnerability reporting.

## Cost Transparency

Each pattern includes cost guidance in its README and talk track. Typical demo deployments range from:

- **Low**: $10-50/month (e.g., serverless patterns, static sites)
- **Medium**: $50-300/month (e.g., hub-spoke network, simple compute)
- **High**: $300+/month (e.g., AKS clusters, multi-region HA)

**Cost control recommendations**:
- Tag resources with `ttlHours` for automatic cleanup
- Delete resource groups immediately after demos
- Use Azure Cost Management budgets and alerts
- Disable optional components (e.g., VPN Gateway) in demos

## Troubleshooting

### Deployment Fails with "Quota Exceeded"
Check your subscription's regional quotas for the required services (e.g., Azure Firewall, Public IPs, VM cores). Request quota increases in Azure Portal → Quotas.

### GitHub Actions Workflow Fails with "Authentication Failed"
Verify OIDC configuration: ensure federated credential matches your repository name exactly (case-sensitive), and the service principal has Contributor role on the target subscription.

### Bicep Template Validation Errors
Run `az bicep build --file main.bicep` locally to catch syntax errors before deployment. Use `az deployment group validate` to test template validity.

## Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for:
- Pattern authoring standards
- Bicep coding conventions
- Documentation requirements
- Pull request process

## License

This repository is provided as-is for demonstration and learning purposes. See [LICENSE](./LICENSE) for details.

**Content Disclaimer**: Pattern documentation in this repository is original content written for business communication. It references but does not copy Microsoft Azure documentation. Always refer to official [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/) for authoritative technical guidance.

## Support

- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions and community support
- **Security**: Report vulnerabilities privately per [SECURITY.md](./SECURITY.md)

---

**Maintained by Chris Bennett** — Azure Infrastructure Demos Project  
**Pattern Portal**: [Coming Soon]
