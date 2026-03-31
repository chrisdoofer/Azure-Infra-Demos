# Project Context

- **Owner:** Chris Bennett
- **Project:** Azure-Infra-Demos — Pattern Demo Portal. A web portal + repo that maintains a catalogue of Azure Architecture Center browse items (patterns/reference architectures/solution ideas), allows one-click deployment via Azure Portal or GitHub Actions, and includes customer-ready talk tracks with business value.
- **Stack:** Next.js (TypeScript), Bicep (IaC), GitHub Actions (CI/CD), Azure (Static Web Apps or App Service for hosting)
- **Created:** 2026-03-31

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-31: Next.js Portal Application Created

Created complete Next.js 14 portal application with static export configuration for Azure Static Web Apps hosting. Key architectural decisions:

**Technology Stack:**
- Next.js 14 with App Router and static export mode (`output: 'export'`)
- TypeScript in strict mode for type safety
- Tailwind CSS for styling (no component library dependencies)
- React Markdown for talk track rendering
- Client-side search and filtering (no server required)

**Structure:**
- 8 Azure architecture patterns in `data/patterns.json` (single source of truth)
- First pattern (hub-spoke-network) fully implemented and deployment-ready
- Remaining 7 patterns scaffolded with complete metadata, ready for infrastructure files
- TypeScript interfaces ensure type safety across all pattern data

**Features Implemented:**
- Search with 300ms debounce filtering by title, summary, tags, and services
- Multi-dimensional filtering: category, cost band, complexity range
- Sort by name, cost, complexity, or deploy time
- Responsive grid layout (1/2/3 columns for mobile/tablet/desktop)
- Pattern detail pages with deployment instructions, service lists, cost estimates, and teardown guides
- Talk track viewer with expand/collapse and copy functionality
- "Deploy to Azure" buttons with Portal template URIs
- Static generation for all pattern pages

**Design Patterns:**
- Azure brand colors (#0078D4) throughout UI
- Card-based pattern browsing with hover effects
- Category-specific color coding
- Cost indicators ($ to $$$$) with tooltips
- Complexity visualization (1-5 dots)
- "Ready to deploy" badges for completed patterns
- Accessibility-focused component design

**Files Created:** 20 production-ready files including configuration, types, components, pages, and data
**Ready for:** `npm install` followed by `npm run build` to generate static site in `out/` directory

### 2026-03-31: Team Orchestration Complete
- Portal application fully integrated with infrastructure work (Parker)
- Deploy buttons now link to actual GitHub Actions workflows and Portal deployments
- Pattern detail pages pull talk tracks, architecture diagrams, and cost info from patterns.json
- All 8 patterns discoverable via search/filter/category browsing
- Static generation ensures fast load times and no server overhead
- Ready for deployment to Azure Static Web Apps
