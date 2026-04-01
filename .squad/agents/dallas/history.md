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

### 2026-04-01: Microsoft Fluent 2 Design System Implementation

Completed comprehensive restyle of the entire portal to align with Microsoft Azure Global Services (AGS) common-ui theme based on Fluent 2 Design System. This establishes the portal's visual identity as an authentic Azure experience.

**Design System Adoption:**
- **Color palette:** Replaced generic colors with official Fluent 2 tokens
  - Primary brand: #0078D4 (Azure Blue) with hover/pressed variants
  - Neutral palette: #FAF9F8 (page background), #FFFFFF (surface), #F3F2F1 (subtle)
  - Text hierarchy: #323130 (primary), #605E5C (secondary), #A19F9D (disabled)
  - Semantic colors: success (#107C10), warning (#797775 on #FFF4CE), danger (#A4262C)
  - Category accent colors for pattern badges (networking blue, compute teal, data purple, etc.)

- **Typography:** Segoe UI font stack with Fluent 2 sizing
  - Hero: 42px/56px (600 weight)
  - Title 1: 28px/36px (600)
  - Title 2: 20px/28px (600)
  - Subtitle 1: 16px/22px (600)
  - Body 1: 14px/20px (400) — default text
  - Body 2/Caption: 12px/16px (400)
  - Weight standardized to 400 (regular) and 600 (semibold), avoiding 700 per Fluent 2 guidelines

- **Layout & Components:**
  - Border radius: 4px (controls), 8px (cards/panels)
  - Shadows: Fluent card shadow (1.6px/3.6px) and elevated shadow (6.4px/14.4px)
  - Spacing scale: 4px, 8px, 12px, 16px, 20px, 24px, 32px, 48px
  - Max content width: 1280px (centered)
  - Page background: #FAF9F8 (warm off-white, not pure white)

- **Header:** Azure Portal-style dark header (#1B1A19) with white text, clean navigation
- **Buttons:** Fluent 2 primary (Azure blue, white text, 4px radius, 32px height) and secondary (outline style)
- **Cards:** White with Fluent shadow, 8px radius, hover elevation effect with subtle background shift
- **Form controls:** Search input with 2px Azure focus ring, 1px offset per Fluent accessibility standards
- **Filter chips:** Subtle rounded pills with active state using #DEECF9 background
- **Cost badges:** Semantic colors with matching backgrounds (green for low, amber for medium, red for high)
- **Category badges:** Accent colors matching Azure service categories (blue for networking, teal for compute, purple for data, etc.)

**Files Modified:** 12 files
- Core config: `tailwind.config.ts` (Fluent color tokens, typography, shadows)
- Global styles: `globals.css` (CSS variables, markdown typography, focus rings)
- Layout: `layout.tsx` (dark header, footer styling)
- Pages: `page.tsx` (home page with Fluent controls), `patterns/[slug]/page.tsx` (detail page)
- Components: `PatternCard`, `DeployButton`, `SearchBar`, `FilterBar`, `CostBadge`, `ComplexityIndicator`, `TalkTrackViewer`
- Utilities: `lib/patterns.ts` (category color mapping)

**Design Consistency:**
- All components now use Fluent 2 spacing, colors, typography, and shadows
- Focus states meet WCAG 2.1 AA accessibility standards (2px ring, 1px offset)
- Hover states use official Fluent color variants (#106EBE for hover)
- Markdown content in talk track viewer uses Fluent typography hierarchy
- All interactions follow Fluent 2 motion principles (0.2s transitions)

**Result:** Portal now presents as an official Azure experience with professional polish, consistent with Azure Portal and other Microsoft cloud services. Design language supports trust, familiarity, and enterprise credibility.

### 2026-04-01: Pattern Detail Page Enhancement - Bicep Viewer and GitHub Actions Deployment Section

Enhanced the pattern detail page (`/patterns/[slug]`) with two new features to improve developer experience and deployment guidance:

**New Components Created:**

1. **BicepViewer.tsx** (`/portal/components/BicepViewer.tsx`)
   - Collapsible Bicep source code viewer with syntax highlighting
   - Collapsed by default showing first 15 lines with fade-out gradient
   - Expand/collapse toggle to view full source
   - Copy button to copy entire Bicep source to clipboard
   - Fluent 2 styling: white card with shadow, monospace font on neutral-page background
   - Line count display when collapsed
   - Responsive design with horizontal scroll for wide code

2. **ActionsDeploySection.tsx** (`/portal/components/ActionsDeploySection.tsx`)
   - Improved GitHub Actions deployment guidance section
   - Direct "Run Workflow" link to GitHub Actions workflow page
   - Step-by-step deployment instructions with numbered badges
   - Visual presentation of recommended workflow inputs (JSON formatted)
   - OIDC setup guidance with links to SECURITY.md
   - Fluent 2 card styling with Azure blue accents
   - Integration with siteConfig for dynamic GitHub repo URLs

**Page Updates:**

- **Modified** `/portal/app/patterns/[slug]/page.tsx`:
  - Added Bicep content loading (parallels existing talk-track loading pattern)
  - Integrated BicepViewer component (displays after Azure Services section)
  - Replaced basic GitHub Actions JSON block with new ActionsDeploySection component
  - Both sections conditionally render based on file availability and deployment mode support

**Integration Details:**

- BicepViewer loads `main.bicep` from patterns directory at build time using `fs.readFileSync`
- ActionsDeploySection receives pattern slug, title, and workflow inputs example
- Workflow URL dynamically generated: `https://github.com/{owner}/{repo}/actions/workflows/deploy-{slug}.yml`
- Uses siteConfig (owner, repo, defaultBranch) for all GitHub links
- Maintains existing Fluent 2 design system (colors, typography, spacing, shadows)

**Developer Experience Improvements:**

- Developers can now view Bicep infrastructure source directly in portal without navigating to GitHub
- Clear, actionable GitHub Actions deployment workflow with direct links
- Reduced friction for deploying patterns via automated workflows
- Better visibility into infrastructure code and deployment automation

**Files Created:** 2 new React components
**Files Modified:** 1 page component
**Design System:** All components follow Microsoft Fluent 2 standards established in previous work
**Accessibility:** Keyboard navigation, focus states, and semantic HTML maintained throughout

