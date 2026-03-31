# Project Context

- **Owner:** Chris Bennett
- **Project:** Azure-Infra-Demos — Pattern Demo Portal. A web portal + repo that maintains a catalogue of Azure Architecture Center browse items (patterns/reference architectures/solution ideas), allows one-click deployment via Azure Portal or GitHub Actions, and includes customer-ready talk tracks with business value.
- **Stack:** Next.js (TypeScript), Bicep (IaC), GitHub Actions (CI/CD), Azure (Static Web Apps or App Service for hosting)
- **Created:** 2026-03-31

## Learnings

### 2026-03-31: Documentation Framework Established

Created comprehensive documentation structure covering all aspects of the Pattern Demo Portal:

1. **Talk Track Structure**: Established 15-section talk track framework for all patterns. This is the core documentation format that makes patterns business-ready, not just technically accurate. Each section serves a specific purpose in customer conversations:
   - Sections 1-5: Business discovery and qualification
   - Sections 6-11: Technical architecture and value
   - Sections 12-15: Demo execution and objection handling

2. **Pattern Catalog Schema**: Defined complete JSON schema for patterns.json with fields for:
   - Business metadata (cost band, complexity, deploy time)
   - Technical references (template URIs, service lists, source URLs)
   - Deployment modes (portal vs. GitHub Actions)
   - Status tracking (implemented vs. scaffold)

3. **Security Model**: OIDC-first approach documented in SECURITY.md. No secrets in repo; everything uses federated credentials or interactive browser auth.

4. **Content Philosophy**: "Write for the audience, not the author." Documentation must:
   - Lead with business outcomes, not features
   - Use original content (no copy/paste from Azure docs)
   - Provide word-for-word demo scripts engineers can read confidently
   - Address real customer objections with business-aligned responses

5. **Repository Structure Patterns**:
   - `/patterns/{slug}/` contains all pattern-specific files
   - `/patterns/catalog/patterns.json` is the single source of truth for pattern metadata
   - Each pattern must have: main.bicep, azuredeploy.json, README.md, talk-track.md, architecture.mmd, parameters/

6. **Cost Transparency Mandate**: Every pattern must document costs honestly with optimization levers and teardown guidance. Demo environments should include `ttlHours` tags for automatic cleanup.

**Key Insight**: The talk track is more important than the Bicep code. Customers buy outcomes, not templates. The 15-section format ensures every pattern can be sold, demoed, and objection-handled consistently.

### 2026-03-31: Full Squad Delivery Integrated
- Hub-Spoke talk track completed (15 sections, business-first narrative, objection handling)
- Mermaid architecture diagram created with hub, spokes, peering, and firewall visualization
- Patterns.json catalogue created with all 8 patterns (1 ready, 7 scaffold)
- Root README, CONTRIBUTING.md, SECURITY.md written
- Documentation decisions document merged into squad decisions
- Portal now displays talk tracks, diagrams, and pattern metadata
- All documentation standards enforceable via validation tools
