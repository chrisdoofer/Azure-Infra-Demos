# Contributing to Azure Pattern Demo Portal

Thank you for contributing to the Azure Pattern Demo Portal! This guide covers everything you need to author new patterns, maintain existing ones, and ensure consistency across the catalogue.

## Pattern Authoring Overview

Each pattern in this repository is:
- **Production-ready** — Not a prototype; deployable to real Azure subscriptions
- **Business-focused** — Includes talk tracks explaining value, not just technical specs
- **Self-contained** — All required files in `/patterns/{slug}/` directory
- **Tested** — Validated locally and deployed successfully before merge

## Pattern Directory Structure

Every pattern follows this structure:

```
/patterns/{slug}/
├── main.bicep                    # Infrastructure-as-code (Bicep)
├── azuredeploy.json              # ARM JSON template (generated from Bicep)
├── README.md                     # Pattern documentation
├── talk-track.md                 # Business value narrative (15 sections)
├── architecture.mmd              # Mermaid architecture diagram
└── parameters/
    └── dev.parameters.json       # Default parameter values for testing
```

### Optional Files
- `metadata.json` — Additional pattern metadata (if needed beyond patterns.json)
- `scripts/` — Helper scripts for deployment or testing
- `docs/` — Extended documentation or decision records

## Required Files Checklist

Before submitting a pull request, ensure your pattern includes:

- [ ] **main.bicep** — Complete Bicep infrastructure-as-code
- [ ] **azuredeploy.json** — Generated ARM JSON (`az bicep build --file main.bicep`)
- [ ] **README.md** — Pattern overview, prerequisites, deployment instructions, architecture diagram reference
- [ ] **talk-track.md** — All 15 sections (see below)
- [ ] **architecture.mmd** — Mermaid diagram showing key components and connections
- [ ] **parameters/dev.parameters.json** — Working parameter values for testing
- [ ] **Entry in `/patterns/catalog/patterns.json`** — Pattern metadata

## Talk Track: 15-Section Template

Every pattern **must** include `talk-track.md` with these sections in order:

1. **Executive Summary (Business-first)** — 5-7 bullets for CIO/IT leadership; outcomes not services
2. **Business Problem Statement** — Customer pain points + business risks of inaction
3. **Business Value & Outcomes** — Cost optimisation, risk reduction, time-to-market, operational efficiency, scalability
4. **Value-to-Metric Mapping (Table)** — Business outcome → KPI → How pattern improves it
5. **Customer Conversation Starters** — 5-7 discovery questions to qualify relevance
6. **Architecture Overview** — Plain-language explanation + simplified Mermaid diagram
7. **Key Azure Services (What & Why)** — For each service: what it does + why chosen (business + technical rationale)
8. **Security, Risk & Compliance Value** — Security improvements, compliance alignment, risks avoided
9. **Reliability, Scale & Operational Impact** — HA approach, scaling model, operational burden reduced
10. **Observability (What to show in demo)** — Logs/metrics/alerts and business insights
11. **Cost Considerations & Optimisation Levers** — Major cost drivers + levers + demo guardrails
12. **Deployment Experience (Demo Narrative)** — What to say while deploying + value to reinforce
13. **10-15 Minute Demo Script (Say / Do / Show)** — "Say" = business framing; "Do" = actions; "Show" = outcomes
14. **Common Objections & Business Responses** — Crisp, business-aligned answers
15. **Teardown & Cost Control** — Clear teardown steps and cost hygiene reminders

**Tone**: Business-friendly, outcome-driven, technically accurate, no marketing fluff. Write **original** content — do not copy from Azure documentation.

**Example**: See `/patterns/hub-spoke-network/talk-track.md` for a complete reference implementation.

## patterns.json Entry Schema

Add your pattern to `/patterns/catalog/patterns.json` using this schema:

```json
{
  "id": "pattern-slug",
  "slug": "pattern-slug",
  "title": "Pattern Display Name",
  "summary": "2-3 sentence description explaining the pattern's purpose and value (original, not copied from Azure docs)",
  "sourceUrl": "https://learn.microsoft.com/azure/architecture/...",
  "category": "networking|web|containers|integration|serverless|analytics|management",
  "tags": ["tag1", "tag2", "tag3"],
  "primaryServices": ["Service 1", "Service 2", "Service 3"],
  "estimatedCostBand": "low|medium|high",
  "complexity": 1-5,
  "typicalDeployTimeMinutes": 10-60,
  "deploymentModesSupported": ["portal", "actions"],
  "templateUri": "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F{owner}%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2F{slug}%2Fazuredeploy.json",
  "actionsWorkflowInputsExample": {
    "subscriptionId": "your-subscription-id",
    "location": "australiaeast",
    "prefix": "demo",
    "patternSlug": "pattern-slug"
  },
  "lastReviewedDate": "YYYY-MM-DD"
}
```

**Field Guidance**:
- **summary**: Must be original content, 2-3 sentences, written in plain language explaining what the pattern does and why it matters
- **category**: Choose one primary category (networking, web, containers, integration, serverless, analytics, management)
- **tags**: 4-8 keywords for discovery (e.g., "hub-spoke", "firewall", "vpn", "enterprise")
- **estimatedCostBand**: 
  - `low` = $10-50/month
  - `medium` = $50-300/month
  - `high` = $300+/month
- **complexity**: 1 (trivial) to 5 (enterprise-scale, multi-component)
- **typicalDeployTimeMinutes**: Actual deployment time in minutes (not including validation or planning)

## Bicep Coding Standards

### Parameters
- Use `@description()` decorators for all parameters
- Provide sensible defaults where possible (e.g., `location string = resourceGroup().location`)
- Include `prefix` parameter for resource naming (e.g., `${prefix}-hub-vnet`)
- Document cost-impacting parameters (e.g., `deployFirewall bool = true`)

### Tagging
All resources must include a `tags` parameter with defaults:

```bicep
param tags object = {
  owner: 'demo-user'
  workload: 'pattern-name'
  environment: 'dev'
  ttlHours: '24'
}
```

Apply tags to every resource: `tags: tags`

### Security Defaults
- **Deny-by-default**: NSGs should deny all inbound traffic except explicitly allowed
- **Managed identities**: Use system-assigned or user-assigned identities, never service principal secrets
- **HTTPS/TLS**: Enable HTTPS-only for web apps, storage accounts, and APIs
- **Key Vault integration**: Store secrets in Key Vault, reference via Bicep `getSecret()`
- **Least privilege**: Assign RBAC roles with minimum required permissions

### Outputs
Provide useful outputs for chaining deployments or validation:

```bicep
output resourceId string = resource.id
output endpoint string = resource.properties.endpoint
output principalId string = resource.identity.principalId
```

### Modularity
For complex patterns, split Bicep into modules:

```
main.bicep                  # Orchestration
modules/
├── network.bicep           # VNets, NSGs, peering
├── compute.bicep           # VMs, scale sets
└── monitoring.bicep        # Log Analytics, Application Insights
```

## Deploy to Azure Button Format

Every pattern README should include a "Deploy to Azure" button linking to the `azuredeploy.json` file.

**Markdown Format**:

```markdown
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F{owner}%2FAzure-Infra-Demos%2Fmain%2Fpatterns%2F{slug}%2Fazuredeploy.json)
```

Replace `{owner}` with the repository owner (e.g., your GitHub username) and `{slug}` with the pattern slug.

## How to Test Locally

Before submitting a pull request, validate your pattern:

### 1. Bicep Build
Generate ARM JSON and check for syntax errors:

```powershell
az bicep build --file patterns/{slug}/main.bicep
```

Ensure `azuredeploy.json` is created without errors.

### 2. Template Validation
Validate against Azure Resource Manager:

```powershell
az deployment group validate `
  --resource-group rg-pattern-test `
  --template-file patterns/{slug}/main.bicep `
  --parameters patterns/{slug}/parameters/dev.parameters.json
```

Fix any validation errors before proceeding.

### 3. Test Deployment
Deploy to a test resource group:

```powershell
az deployment group create `
  --resource-group rg-pattern-test `
  --template-file patterns/{slug}/main.bicep `
  --parameters patterns/{slug}/parameters/dev.parameters.json
```

Verify all resources deploy successfully and outputs are correct.

### 4. Cost Estimate
Use Azure Pricing Calculator to estimate monthly costs for the default deployment. Document this in `talk-track.md` Section 11.

### 5. Teardown
Delete the test resource group:

```powershell
az group delete --name rg-pattern-test --yes --no-wait
```

## Pull Request Process

1. **Fork the repository** and create a feature branch (`git checkout -b pattern/my-new-pattern`)
2. **Author the pattern** following all standards above
3. **Test locally** (Bicep build, validation, test deployment)
4. **Commit changes** with clear messages (e.g., "Add N-Tier Web App pattern with talk track")
5. **Push to your fork** and open a pull request against `main`
6. **Describe your PR**:
   - Pattern name and category
   - Link to source Azure Architecture Center page
   - Estimated cost band
   - Any deployment prerequisites or caveats
7. **Address review feedback** — Maintainers will review for completeness, accuracy, and standards compliance
8. **Merge** — Once approved, your pattern will be merged and appear in the catalogue

## Validation Checks (Automated)

Pull requests trigger automated validation:
- **Bicep lint** — Checks syntax and best practices
- **ARM template validation** — Validates against Azure Resource Manager API
- **Markdown lint** — Checks documentation formatting
- **patterns.json schema validation** — Ensures catalogue entry is valid JSON

Fix any validation failures before merge.

## Template Files Location

Use `/patterns/_template/` as a starting point for new patterns. The template includes:
- Basic `main.bicep` with common parameters
- Starter `README.md` structure
- Empty `talk-track.md` with section headers
- Sample `dev.parameters.json`

Copy the template directory to `/patterns/{your-slug}/` and customise.

## Content Guidelines

### Documentation Writing
- **Audience**: Write for IT decision-makers and technical implementers, not Azure experts
- **Clarity**: Use plain language; avoid acronyms without explanation
- **Original content**: Do not copy/paste from Azure docs; write your own summaries and explanations
- **Business focus**: Lead with outcomes (cost savings, faster deployments, reduced risk), then explain how

### Architecture Diagrams (Mermaid)
- Show key components and connections, not every resource detail
- Use subgraphs to group related resources (e.g., VNets, subnets)
- Label connections with purpose (e.g., "VNet Peering", "HTTPS Traffic")
- Use colour/styling to differentiate component types (hub vs. spoke, security vs. compute)

### Talk Tracks
- **Executive summary**: Write for CxO/IT leadership; focus on business outcomes
- **Demo scripts**: Provide word-for-word "Say" guidance; engineers should read and sound professional
- **Objection handling**: Address real customer concerns with business-aligned responses, not dismissive technical answers
- **Cost transparency**: Be honest about costs; provide optimisation levers and teardown guidance

## Code of Conduct

- **Be respectful**: Constructive feedback, no personal attacks
- **Be collaborative**: Help each other improve patterns and documentation
- **Be honest**: If you're unsure about a technical detail, ask for review or research further
- **Give credit**: If you reference external sources, link to them

## Questions?

- **GitHub Discussions**: Ask questions about pattern authoring or standards
- **GitHub Issues**: Report bugs or request features
- **Pull Request Comments**: Ask specific questions during review

---

Thank you for contributing! High-quality patterns with strong business narratives help Azure customers succeed.
