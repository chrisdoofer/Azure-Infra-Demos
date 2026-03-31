# Squad Decisions

## Active Decisions

### 1. Hosting: Azure Static Web Apps (Ripley - Architecture)
- **Choice:** Azure Static Web Apps over App Service for portal
- **Rationale:** Free tier, built-in CI/CD, global CDN, zero infrastructure management vs $50-200/mo App Service
- **Impact:** Portal deployment fully automated, no VM/container management

### 2. Pattern Catalogue Schema (Ripley - Architecture)
- **Choice:** patterns.json as single source of truth with standardized metadata
- **Fields:** id, name, category, status (ready/scaffold), description, businessValue, azureServices, estimatedCost, deploymentTime, bicepPath, talkTrackPath, architectureDiagram
- **Impact:** Enables programmatic filtering, version-controlled metadata, unified pattern discovery

### 3. GitHub Actions OIDC Authentication (Parker - Infrastructure)
- **Choice:** OpenID Connect federation with azure/login@v2, no service principal secrets stored
- **Secrets Required:** AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID
- **Rationale:** Passwordless, time-limited tokens, Azure-native federation, industry best practice
- **Impact:** Secure CI/CD automation, eliminates credential rotation burden

### 4. ARM JSON + Bicep Dual Format (Parker - Infrastructure)
- **Choice:** Author in Bicep (main.bicep), compile to ARM JSON (azuredeploy.json) for Portal buttons
- **Rationale:** Bicep is maintainable, Portal buttons require ARM JSON at raw URLs
- **Impact:** Both formats kept in sync, validated in CI/CD

### 5. Cost Guardrails as First-Class Parameters (Parker - Infrastructure)
- **Choice:** ttlHours tags on all resources, optional expensive components (Firewall, VPN), cost warnings in Portal UI
- **Rationale:** Demo environments are ephemeral, prevent accidental expensive deployments
- **Impact:** Cost transparency, budget-conscious defaults

### 6. Three-Path Deployment Strategy (Parker - Infrastructure)
- **Paths:** (1) Azure Portal with custom UI, (2) GitHub Actions with OIDC, (3) Azure CLI
- **Rationale:** Portal (lowest barrier), Actions (auditable automation), CLI (maximum flexibility)
- **Impact:** Every pattern supports all three methods

### 7. Talk Track is Primary Deliverable (Lambert - DevRel)
- **Choice:** Every pattern must include complete 15-section talk-track.md before production-ready
- **Sections:** Opening Hook, Business Problem, Solution, Benefits, Architecture, Design Decisions, Demo Script, Objection Handling, Cost, Security, Governance, Disaster Recovery, Maintenance, CTA, Resources
- **Rationale:** Customers buy outcomes not code, sales engineers need word-for-word guidance, consistent messaging
- **Impact:** Contributions without talk tracks rejected, customer-ready narratives

### 8. Cost Transparency Mandatory (Lambert - DevRel)
- **Choice:** All patterns must document monthly estimates, cost drivers, optimization levers, teardown procedures
- **Rationale:** Avoid sticker shock, enable accurate budgeting, demonstrate cost-consciousness
- **Impact:** Cost section (Section 11) non-negotiable in all talk tracks

### 9. Original Content Only (Lambert - DevRel)
- **Choice:** All documentation is original (no copy/paste from Azure docs)
- **Rationale:** Copyright compliance, voice consistency, forces understanding, differentiates value
- **Impact:** Reference Azure docs but write in original voice

### 10. Business-First Structure (Lambert - DevRel)
- **Choice:** Talk tracks lead with executive summary and business problems before architecture
- **Rationale:** Decision-makers care about outcomes not VNets, natural "why to how" flow
- **Impact:** Sections 1-5 business discovery/qualification, technical details after

### 11. OIDC-Only Security Model (Lambert - DevRel)
- **Choice:** No secrets permitted in repository, all authentication uses OIDC federated credentials
- **Rationale:** Security best practice, eliminates secret rotation, models correct customer behavior
- **Impact:** SECURITY.md documents setup, GitHub Actions use azure/login@v2, az login/azd auth login for local dev

### 12. TypeScript + Node.js Tooling (Ash - Tester)
- **Choice:** TypeScript for type safety, Node.js for cross-platform, tsx for direct execution
- **Rationale:** Type safety, faster iteration (no build step), zero external dependencies beyond tsx
- **Impact:** Catalogue builder and validation tools are maintainable, portable

### 13. Single Source of Truth Template (Ash - Tester)
- **Choice:** /patterns/_template/ contains canonical boilerplate, placeholder system for substitution
- **Rationale:** Consistency across all patterns, easier learning/maintenance
- **Impact:** New patterns scaffolded from template, valid by default

### 14. Bicep Scaffold Philosophy (Ash - Tester)
- **Choice:** No TODOs in resource definitions, complete resources or properly structured comments
- **Rationale:** Valid by default, clear intent, easier to review
- **Required Parameters:** location, prefix, tags mandatory for all patterns
- **Standards:** @description decorators on all parameters, standardized outputs (deployedResources array, deploymentTimestamp)

### 15. Pattern Directory Structure (Ash - Tester)
- **Structure:** patterns/{pattern-slug}/ contains main.bicep, azuredeploy.json, createUiDefinition.json, README.md, parameters/, optional architecture.mmd and talk-track.md
- **Rationale:** Predictable structure for tooling, co-location of assets, parameter file separation
- **Impact:** Validation workflow discovers patterns by structure, templates referenced by convention

### 16. Validation Coverage (Ash - Tester)
- **Checks:** (1) Catalogue schema, (2) Pattern directories, (3) Bicep parameters, (4) Talk-track sections, (5) Parameters JSON, (6) Orphaned directories
- **CI/CD Integration:** Validation enforces quality gates before patterns go live
- **Impact:** No invalid patterns committed, consistent standards across all patterns

### 17. Hub-Spoke Network as First Pattern (Ripley - Architecture)
- **Choice:** Hub-Spoke Network Topology as full implementation, 7 others as scaffolds
- **Rationale:** Foundational for enterprise (80%+ of deployments), multi-service showcase (VNet, Firewall, VPN, Peering), strong ROI
- **Cost:** ~$50-100/day for demo, quick teardown, cost-optimizable (firewall/VPN optional)
- **Pattern Set:** 8 total: Hub-Spoke (ready), Web App Private Endpoint, Monitor Baseline, Landing Zone, AKS Microservices, Serverless API, Data Pipeline, Zero Trust Network (all scaffold)

### 18. Next.js Static Export Portal (Dallas - Frontend)
- **Choice:** Next.js 14+ with App Router, TypeScript, Tailwind CSS, static export (output: 'export')
- **Rationale:** Modern React, type safety, instant loads (pre-rendered), no runtime needed, portable
- **Features:** Pattern grid with filters, detail pages, search by metadata, Deploy buttons, talk track viewer
- **Accessibility:** WCAG 2.1 AA compliance, responsive design, dark mode support

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
