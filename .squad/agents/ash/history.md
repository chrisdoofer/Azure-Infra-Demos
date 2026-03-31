# Project Context

- **Owner:** Chris Bennett
- **Project:** Azure-Infra-Demos — Pattern Demo Portal. A web portal + repo that maintains a catalogue of Azure Architecture Center browse items (patterns/reference architectures/solution ideas), allows one-click deployment via Azure Portal or GitHub Actions, and includes customer-ready talk tracks with business value.
- **Stack:** Next.js (TypeScript), Bicep (IaC), GitHub Actions (CI/CD), Azure (Static Web Apps or App Service for hosting)
- **Created:** 2026-03-31

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-31: Pattern Tooling & Scaffold Infrastructure

**Created complete pattern management toolchain:**

1. **Tools Directory** (`/tools/`)
   - `catalog-builder.ts`: Interactive CLI for creating/listing/validating patterns
   - `validate-patterns.ts`: Comprehensive validation (Bicep params, talk-track sections, JSON schema)
   - `package.json`: Minimal setup with tsx for TypeScript execution

2. **Pattern Template** (`/patterns/_template/`)
   - Complete boilerplate with main.bicep, README.md, talk-track.md, architecture.mmd, parameters
   - Placeholder substitution system for pattern name, slug, summary, etc.
   - All 15 required talk-track sections defined

3. **Seven Scaffold Patterns** (all syntactically valid, deployment-ready):
   - `web-app-private-endpoint`: App Service + Private Link (intermediate complexity)
   - `azure-monitor-baseline`: Log Analytics + App Insights (beginner complexity)
   - `serverless-api`: Functions + APIM + Cosmos DB (intermediate)
   - `microservices-aks`: AKS + ACR + Key Vault (advanced)
   - `landing-zone-foundation`: Subscription-level governance (advanced)
   - `data-analytics-pipeline`: Synapse + Data Factory + Data Lake (advanced)
   - `zero-trust-network`: App Gateway + WAF + Firewall (advanced)

4. **Catalog JSON** (`/patterns/catalog/patterns.json`)
   - All 7 patterns registered with metadata
   - Valid schema for category, services, costBand, complexity, status

**Validation Strategy:**
- Bicep files: Required parameters (location, prefix, tags), @description decorators
- Talk-track.md: All 15 sections present
- Parameters: Valid JSON schema with $schema and contentVersion
- Catalog: Schema validation for all required fields

**Key Decisions:**
- No TODOs in Bicep — use complete resource definitions or properly commented placeholders
- Subscription-level deployment for landing-zone-foundation (targetScope = 'subscription')
- Cost estimates and complexity ratings documented in each README
- Mermaid diagrams show architecture topology for visual learners
- All patterns use consistent naming conventions and tag structures

### 2026-03-31: Full Team Orchestration Completed
- All tools integrated with portal and infrastructure (Dallas, Parker, Ripley)
- Validation tools enforce pattern quality standards
- Catalogue builder enables easy pattern addition
- 7 scaffolds ready for talk track completion and iterative development
- Validation CI/CD integration prevents invalid patterns from being committed
- Hub-Spoke pattern passes all validation checks (Bicep, talk-track, JSON, catalog schema)
