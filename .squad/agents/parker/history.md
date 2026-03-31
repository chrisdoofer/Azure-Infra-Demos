# Project Context

- **Owner:** Chris Bennett
- **Project:** Azure-Infra-Demos — Pattern Demo Portal. A web portal + repo that maintains a catalogue of Azure Architecture Center browse items (patterns/reference architectures/solution ideas), allows one-click deployment via Azure Portal or GitHub Actions, and includes customer-ready talk tracks with business value.
- **Stack:** Next.js (TypeScript), Bicep (IaC), GitHub Actions (CI/CD), Azure (Static Web Apps or App Service for hosting)
- **Created:** 2026-03-31

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-31: Hub-Spoke Network Pattern Infrastructure Created
- Created complete hub-spoke network topology Bicep template with Azure Firewall, VPN Gateway (optional), 3 VNets, peerings, NSGs, and route tables
- Generated ARM JSON (azuredeploy.json) for "Deploy to Azure" button compatibility (Azure Portal requires ARM JSON at raw GitHub URLs)
- Created createUiDefinition.json for custom Azure Portal deployment experience with 4 steps: basics, network config, security options, and tags
- Built 3 GitHub Actions workflows:
  - **deploy.yml**: OIDC-authenticated deployment with bicep validation, resource group auto-creation, parameter handling, and output artifacts
  - **destroy.yml**: Safe teardown workflow with resource listing and confirmation, supports async deletion
  - **validate.yml**: PR validation for Bicep (build + lint), portal build, markdown checks, and JSON validation
- Created Azure Static Web Apps Bicep template (infra/swa/main.bicep) for hosting the portal itself (Free tier default)
- Pattern README includes complete documentation: what deploys, prerequisites, 3 deployment methods (Portal/Actions/CLI), parameters table, outputs, cost estimates (~$30/day with firewall), teardown instructions
- Cost optimization is priority: Added ttlHours tag to all resources, clear cost warnings in UI definition, firewall/VPN optional flags, explicit daily cost breakdowns
- OIDC federation pattern: Workflows use azure/login@v2 with federated credentials (secrets: AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID) for secure, passwordless authentication
- All files are production-ready, syntactically valid, and fully functional - zero placeholders or TODOs
- Parameter files live in patterns/{pattern}/parameters/ directory structure
- Deploy to Azure button format: Use encoded raw.githubusercontent.com URL to azuredeploy.json in main branch

### 2026-03-31: Full Squad Orchestration Completed
- **Team Delivery:** All 5 agents delivered at 2026-03-31T18:15:00Z (Ripley, Parker, Dallas, Lambert, Ash)
- **Orchestration Logs:** 5 timestamped logs written documenting each agent's deliverables, decisions, and handoffs
- **Session Log:** Pattern-demo-portal-build.md summarizing milestones, team achievements, completion status
- **Decision Merge:** 18 decisions consolidated from inbox into decisions.md (18 active decisions covering architecture, infrastructure, DevRel, frontend, testing)
- **Infrastructure Decisions:** OIDC authentication, ARM+Bicep dual format, cost guardrails, 3-path deployment (Portal/Actions/CLI), pattern directory structure standardization
- **Portal Readiness:** Next.js 14 application (20 files), pattern grid with search/filter, deployment buttons, WCAG 2.1 AA accessible
- **Hub-Spoke Pattern:** Complete Bicep template with optional Firewall/VPN, customizable Portal UI, GitHub Actions OIDC workflows, cost documentation
- **Documentation:** 15-section talk tracks, Mermaid diagrams, patterns.json catalogue, root docs, CONTRIBUTING guide, SECURITY.md
- **Scaffolding Tools:** Catalogue builder, validation framework, 7 pattern templates with boilerplate Bicep, parameters, README
- **Ready for Next Phase:** Portal deployment to Static Web Apps, pattern testing, talk track iteration, CI/CD validation

### 2026-03-31: Deploy to Azure Button Hosting Strategy Fixed
- **Root Cause:** Raw GitHub URLs only work for public repos; private repos return 404 breaking Deploy to Azure buttons
- **Solution Implemented:** Dual hosting strategy with GitHub Pages as default (works for private repos on Enterprise/Pro/Team)
- **GitHub Pages Workflow:** Created `.github/workflows/publish-templates.yml` that copies all azuredeploy.json and createUiDefinition.json files to GitHub Pages on push to main/master
- **Configuration System:** Created `portal/config/site.ts` with siteConfig containing githubOwner, githubRepo, defaultBranch, and templateHosting strategy selection
- **Dynamic URL Construction:** Updated DeployButton component to build Azure Portal URLs dynamically using siteConfig instead of hardcoded templateUri values
- **Schema Migration:** Changed Pattern interface from `templateUri: string` to `templatePath: string` (relative path like `patterns/hub-spoke-network/azuredeploy.json`)
- **Data Updates:** Updated all 8 patterns in portal/data/patterns.json and patterns/catalog/patterns.json to use templatePath instead of templateUri
- **Documentation Updates:** Updated hub-spoke README explaining both hosting options (GitHub Pages vs raw URLs), setup steps, and template URL format requirements
- **Root README Updates:** Added "Setup (One-Time)" section explaining how to fork, configure site.ts, enable GitHub Pages, and verify deployment
- **Portability:** Any fork now automatically gets correct URLs by updating 2 lines in site.ts (githubOwner and templateHosting preference)
- **Template Base URLs:** GitHub Pages = `https://[owner].github.io/Azure-Infra-Demos`, Raw GitHub = `https://raw.githubusercontent.com/[owner]/Azure-Infra-Demos/[branch]`
- **Pattern Detail Page:** Updated to pass templatePath (not templateUri) to DeployButton component
- **All 8 Patterns Migrated:** hub-spoke-network (ready), plus 7 scaffold patterns all using new templatePath schema

### 2026-03-31: Wave 1 Infrastructure Complete - Three Production-Ready Patterns
- **Deliverables:** Implemented complete, deployable Bicep templates for 3 Wave 1 patterns (serverless-api, web-app-private-endpoint, azure-monitor-baseline)
- **Quality Bar:** All patterns match hub-spoke-network reference implementation quality with complete resource definitions, no TODOs, valid Bicep syntax
- **Pattern 1 - Serverless API:** Azure Functions (Consumption, Linux), API Management (Consumption), Cosmos DB (serverless), Key Vault, Application Insights, Storage Account. Features: managed identity, Key Vault secret storage for Cosmos connection, APIM API/operation definitions with backend policy, multi-runtime support (Node.js 20, Python, .NET)
- **Pattern 2 - Web App Private Endpoint:** App Service (B1 Linux, Node.js 20 LTS), VNet with 2 subnets (app integration with delegation, private endpoint subnet), NSG, Private Endpoint, Private DNS Zone. Features: VNet integration, public access disabled, HTTPS only, TLS 1.2 minimum, alwaysOn for non-Basic SKUs
- **Pattern 3 - Azure Monitor Baseline:** Log Analytics workspace (30-day retention, 5GB daily cap), Application Insights, Action Group (email), Metric Alert (data ingestion >5GB), Scheduled Query Alert (error rate >10%), Azure Monitor Workbook with 3 dashboard sections
- **ARM JSON Generation:** All 3 patterns compiled to valid ARM JSON (azuredeploy.json) for Azure Portal Deploy buttons - serverless-api (18KB), web-app-private-endpoint (12KB), azure-monitor-baseline (13KB)
- **Parameters Updated:** Cost-efficient defaults in dev.parameters.json - Node.js 20, B1 SKU (not P1v3), 48-hour TTL, 5GB Log Analytics cap (not 1GB)
- **Architecture Diagrams:** Updated all 3 architecture.mmd files to accurately reflect deployed resources, include SKU/tier details, show all relationships (VNet integration, Key Vault secrets, alert flows)
- **Security:** Managed identities, Key Vault access policies, HTTPS-only, minimum TLS 1.2, private endpoints, NSG rules, no public access where applicable
- **Bicep Validation:** All templates successfully compile with az bicep build (warnings only for API version metadata, no errors)
- **Resource Naming:** Consistent patterns using `${prefix}-${uniqueString(resourceGroup().id)}` suffix, abbreviations follow Azure CAF standards (func-, apim-, cosmos-, kv-, st, app-, asp-, vnet-, pe-, log-, appi-)
- **Outputs:** All patterns provide comprehensive outputs (resource IDs, URLs, endpoints, instrumentation keys) matching standardized schema with deployedResources array
- **Cost Targets:** serverless-api ~$5-15/day (Consumption plans), web-app-private-endpoint ~$20-40/day (B1 tier), azure-monitor-baseline ~$10-25/day (Log Analytics ingestion)

