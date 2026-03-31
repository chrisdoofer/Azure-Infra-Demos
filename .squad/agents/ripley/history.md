# Project Context

- **Owner:** Chris Bennett
- **Project:** Azure-Infra-Demos — Pattern Demo Portal. A web portal + repo that maintains a catalogue of Azure Architecture Center browse items (patterns/reference architectures/solution ideas), allows one-click deployment via Azure Portal or GitHub Actions, and includes customer-ready talk tracks with business value.
- **Stack:** Next.js (TypeScript), Bicep (IaC), GitHub Actions (CI/CD), Azure (Static Web Apps or App Service for hosting)
- **Created:** 2026-03-31

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2025-01-28: Architecture Plan Finalized
- **Decision:** Azure Static Web Apps chosen over App Service for hosting the portal (Next.js static export)
- **Rationale:** Free tier, built-in CI/CD, global CDN, zero infrastructure management vs $50-200/mo App Service cost
- **First Pattern:** Hub-Spoke Network Topology selected as the first full implementation
  - Foundational for enterprise deployments, showcases multiple Azure services (VNet, Firewall, VPN, Peering)
  - Moderate cost (~$50-100/day for demo), quick teardown, strong business value talk track
- **Pattern Set:** 8 patterns total (1 full, 7 scaffolds): Hub-Spoke Network, Web App with Private Endpoint, Azure Monitor Baseline, Landing Zone Foundation, Microservices on AKS, Serverless API with Functions, Data Analytics Pipeline, Zero Trust Network Access
- **Deployment Model:** Deploy to Azure buttons (Portal UI) + GitHub Actions workflows with OIDC federated credentials
- **Catalogue Schema:** patterns.json committed to repo with metadata (id, name, category, status, businessValue, azureServices, estimatedCost, deploymentTime, paths)
- **Repo Structure:** Mono-repo with /portal (Next.js), /patterns (Bicep templates + docs + talk tracks), /scripts (tooling), /.github/workflows (CI/CD)
- **Tool Support:** scripts/add-pattern.sh for scaffolding new patterns interactively
- **Documentation Standards:** Each pattern includes architecture.md, talk-track.md with business problem, solution, benefits, demo script, objection handling
- **Tech Stack:** Next.js 14+ (App Router, static export), TypeScript, Tailwind CSS, shadcn/ui components
- **Implementation Phases:** 
  1. Foundation (portal + data structure)
  2. First pattern (hub-spoke full implementation)
  3. Scaffolds (7 additional patterns)
  4. Polish (search, UX, cost estimates, contribution guidelines)

### 2026-03-31: Orchestration Complete — Full Portal Build Delivered
- **Completion Status:** Phase 1 (Portal Foundation) + Phase 2 (Hub-Spoke Pattern) + Phase 3 (Scaffolds) + Phase 4 (Documentation) — ALL COMPLETE
- **Ripley Leadership:** Architecture plan delivered with 20 decision points, 4-phase roadmap, 8-pattern starter set, implementation priorities
- **Parker Infrastructure:** Hub-Spoke Bicep template (main.bicep, azuredeploy.json, createUiDefinition.json) + 3 GitHub Actions workflows (deploy/destroy/validate) + Static Web Apps hosting Bicep — OIDC federation implemented, cost guardrails in place, 3-path deployment strategy enabled
- **Dallas Frontend:** Next.js 14 portal with TypeScript/Tailwind (20 files: homepage, pattern detail pages, components, styles) — static export mode, client-side search/filtering, Deploy button integration — WCAG 2.1 AA accessible
- **Lambert Documentation:** Hub-Spoke talk track (15-section narrative, business-first structure), Mermaid architecture diagram, patterns.json catalogue (8 patterns), root README/CONTRIBUTING/SECURITY.md, documentation decisions document
- **Ash Testing:** Catalogue builder (interactive CLI, pattern metadata generation), validate-patterns tool (schema/directory/Bicep/talk-track/JSON validation), 7 pattern scaffolds (web-app-private-endpoint, azure-monitor-baseline, landing-zone-foundation, microservices-aks, serverless-api-functions, data-analytics-pipeline, zero-trust-network-access) with boilerplate Bicep, parameters, README templates
- **Orchestration Logs Written:** 5 timestamped logs (Ripley/Parker/Dallas/Lambert/Ash) documenting deliverables, technical decisions, outcomes, handoffs — ISO 8601 UTC format
- **Session Log:** Pattern-demo-portal-build.md with milestones, deliverables summary, completion status
- **Decisions Merged:** 18 decisions from inbox files consolidated into decisions.md with governance framework
- **Ready for:** Portal deployment to Static Web Apps, Hub-Spoke pattern deployment testing, pattern talk track completion, CI/CD workflow validation
