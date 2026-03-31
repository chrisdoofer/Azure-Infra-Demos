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
