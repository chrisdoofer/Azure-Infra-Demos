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


### 2026-03-31: Wave 2 Infrastructure Complete - Landing Zone Foundation Pattern
- **Deliverable:** Complete, deployable Bicep template for Landing Zone Foundation pattern (resource group scope)
- **Pattern Architecture:** Governance building blocks for Azure environments - simplified RG-scoped version demonstrating governance without management group permissions
- **Resources Deployed:** 
  - Log Analytics workspace (90-day retention, 5GB daily cap, PerGB2018 SKU)
  - Automation Account (Basic SKU, system managed identity, linked to Log Analytics)
  - Key Vault (RBAC authorization, soft delete enabled, purge protection, 90-day soft delete retention)
  - Storage Account (Standard LRS, HTTPS only, TLS 1.2 minimum, blob soft delete 7 days)
  - Action Group (email notifications for alerts)
  - Budget Alert (monitors spending against $1000/month, alerts at 80% and 100% thresholds)
  - Activity Log diagnostic settings (sends to Log Analytics)
  - Network Watcher (documented as auto-created resource)
  - Recovery Services Vault (Standard tier, system managed identity)
- **Security Features:** Key Vault with RBAC auth (no access policies), storage HTTPS-only + minimum TLS 1.2, managed identities on Automation Account and Recovery Vault, soft delete and purge protection on Key Vault, blob soft delete on storage, all network ACLs allowing Azure services
- **Diagnostic Settings:** Key Vault logs (allLogs category group + metrics), Storage Account metrics, Blob service logs (read/write/delete + metrics), Recovery Vault logs (allLogs + Health metrics), Activity Log (allLogs) - all sent to Log Analytics
- **ARM JSON Generation:** Valid azuredeploy.json (16.7KB) compiled from Bicep for Azure Portal Deploy button compatibility
- **Parameters File:** dev.parameters.json with cost-efficient defaults (90-day retention, $1000 budget, 48-hour TTL, alerts@example.com placeholder)
- **Architecture Diagram:** Updated architecture.mmd to accurately reflect 7 deployed resources organized by function (Monitoring/Observability, Governance/Automation, Security/Compliance, Business Continuity, Network Infrastructure)
- **Bicep Validation:** Successfully compiles with az bicep build (only BCP334 warning for action group short name minimum length - acceptable)
- **Resource Naming:** Consistent patterns using ${prefix}-${uniqueString(resourceGroup().id)}` suffix, abbreviations follow Azure CAF standards (log-, aa-, kv-, st, ag-, budget-, rsv-, nw-)
- **Scope Change from Scaffold:** Changed from subscription scope (management groups, policy assignments) to resource group scope (deployable via standard Deploy to Azure button without elevated permissions)
- **Budget Implementation:** Fixed utcNow() error in budget start date (can only be used in parameter defaults) - changed to static '2024-01-01' start date
- **Network Watcher Handling:** Documented as auto-created resource by Azure (exists in NetworkWatcherRG), included resource ID as output for completeness
- **Outputs:** workspaceId, keyVaultUri, storageAccountName, automationAccountId, recoveryVaultId, budgetName, actionGroupId, networkWatcherId, deployedResources array (6 resources), deploymentTimestamp
- **Cost Target:** ~$15-30/day (mostly Log Analytics ingestion + Recovery Services Vault storage)
- **Quality Bar:** Matches Wave 1 patterns quality - complete resource definitions, no TODOs, valid syntax, comprehensive outputs, proper tagging, security by default

### 2026-03-31: Microservices on AKS Pattern Infrastructure Complete
- **Deliverable:** Complete, production-ready Bicep template for Microservices on Azure Kubernetes Service pattern
- **Pattern Architecture:** AKS cluster with Azure CNI networking, managed identity, Container Registry integration, Key Vault secrets, and comprehensive monitoring
- **Resources Deployed:**
  - AKS cluster (Kubernetes 1.29, system node pool with 2x Standard_B2s nodes, Azure CNI networking, VNet integration)
  - Azure Container Registry (Basic SKU for cost efficiency, admin user disabled, Azure Services bypass)
  - Key Vault (RBAC authorization, soft delete 90 days, purge protection enabled, public access with Azure Services bypass)
  - Virtual Network (10.1.0.0/16 with 2 subnets: AKS subnet 10.1.0.0/20, Services subnet 10.1.16.0/24)
  - Log Analytics workspace (30-day retention, PerGB2018 SKU, resource permissions enabled)
  - Application Insights (connected to Log Analytics, workspace-based ingestion mode)
- **AKS Features:** 
  - RBAC enabled with Azure AD integration (managed AAD, Azure RBAC enabled)
  - Workload Identity enabled (OIDC issuer profile for pod identity)
  - Azure CNI networking with Azure Network Policy (service CIDR 10.2.0.0/16)
  - OMS agent addon for Container Insights (Log Analytics integration with AAD auth)
  - Azure Key Vault Secrets Provider addon (CSI driver with secret rotation every 2 minutes)
  - System node pool (2 nodes, Standard_B2s, 30 max pods, no auto-scaling for cost control)
  - Standard load balancer SKU
- **Security Features:**
  - Managed identities throughout (AKS system assigned identity + kubelet identity)
  - RBAC role assignments: AKS kubelet identity → AcrPull on ACR, AKS managed identity → Key Vault Secrets User
  - Key Vault RBAC authorization (no access policies), soft delete + purge protection
  - ACR admin user disabled, private container registry pattern ready
  - VNet subnets with private endpoint network policies disabled (ready for private endpoints)
- **Monitoring & Observability:**
  - Container Insights (OMS agent) sending metrics and logs to Log Analytics
  - Application Insights for application-level telemetry
  - Auto-scaler profile configured (10-minute delays for scale-down operations)
- **ARM JSON Generation:** Valid azuredeploy.json (14.47 KB) compiled from Bicep for Azure Portal Deploy button
- **Parameters File:** dev.parameters.json with cost-efficient defaults (2 nodes, B2s VMs, Basic ACR, Kubernetes 1.29, 48-hour TTL)
- **Architecture Diagram:** Updated architecture.mmd to accurately reflect 6 deployed resources with VNet topology, subnet details, RBAC relationships, CSI driver integration
- **Bicep Validation:** Successfully compiles with az bicep build (only BCP334 warning for ACR name minimum length - acceptable for generated names)
- **Resource Naming:** Consistent patterns using ${prefix}-${uniqueString(resourceGroup().id)} suffix, abbreviations follow Azure CAF standards (aks-, acr, kv-, vnet-, log-, appi-)
- **Outputs:** aksClusterName, aksClusterFqdn, acrLoginServer, keyVaultUri, workspaceId, appInsightsInstrumentationKey, appInsightsConnectionString, vnetId, aksSubnetId, getCredentialsCommand, deployedResources array (6 resources), deploymentTimestamp
- **Cost Target:** ~$80-150/day (AKS nodes are main driver: 2x B2s ~$60-70/day, Log Analytics ~$10-20/day, ACR Basic ~$5/day, other services <$10/day)
- **Quality Bar:** Matches Wave 1 and Wave 2 quality - complete resource definitions, no TODOs, valid syntax, comprehensive outputs, proper tagging, security by default
- **Pattern Comparison:** Removed Application Gateway from scaffold (adds ~$125/day cost), focused on core microservices infrastructure with ingress controller pattern (deploy NGINX/Traefik to AKS after provisioning for ~$0 cost)

### 2026-04-01: Zero Trust Network Access Pattern Infrastructure Complete
- **Deliverable:** Complete, production-ready Bicep template for Zero Trust Network Access pattern with comprehensive security controls
- **Pattern Architecture:** Defense-in-depth architecture with Application Gateway WAF v2, Azure Firewall, Private Link, NSGs with deny-all defaults, and VNet segmentation
- **Resources Deployed:**
  - Virtual Network (10.0.0.0/16 with 4 subnets: AppGateway 10.0.1.0/24, Firewall 10.0.2.0/24, AppIntegration 10.0.3.0/24, PrivateEndpoint 10.0.4.0/24)
  - Application Gateway (WAF_v2 tier, 2 instances, OWASP 3.2 ruleset, configurable Prevention/Detection mode, health probes)
  - Azure Firewall (Standard tier, network rules for HTTP/HTTPS, application rules for Azure services)
  - 3 Network Security Groups (AppGateway subnet: allows GatewayManager + HTTP/HTTPS; App subnet: VNet-only inbound; PE subnet: VNet-only inbound)
  - Route Table (directs app subnet traffic through firewall for east-west inspection)
  - App Service Plan (B1 Basic Linux, reserved for Linux containers)
  - Web App (Node.js 20 LTS, VNet integration with app subnet delegation, public access disabled, HTTPS only, TLS 1.2 minimum, alwaysOn enabled)
  - Private Endpoint (connects to Web App, deployed in dedicated PE subnet)
  - Private DNS Zone (privatelink.azurewebsites.net with VNet link and DNS zone group for automatic registration)
  - Log Analytics workspace (30-day retention, PerGB2018 SKU for cost monitoring)
  - 2 Public IPs (Standard SKU for Application Gateway and Azure Firewall)
- **Zero Trust Principles Implemented:**
  - **Verify Explicitly:** WAF inspects all inbound traffic with OWASP 3.2 rules, Firewall inspects all outbound/east-west traffic
  - **Least Privilege Access:** NSGs deny all inbound by default, only allow internal VNet traffic, Web App has no public endpoint
  - **Assume Breach:** Defense-in-depth layers (WAF → NSG → Firewall → Private Link), route table forces traffic inspection, network segmentation isolates components
- **Security Features:**
  - WAF in configurable Prevention/Detection mode (parameter: enableWafPrevention, default: true)
  - Application Gateway with backend health probes (30s interval, HTTPS protocol, picks hostname from backend)
  - Azure Firewall with network rules (allow HTTP/HTTPS from app subnet) and application rules (allow Azure services FQDNs)
  - Route table automatically configured with firewall private IP as next hop (breaks circular dependency via child route resource)
  - Web App with VNet integration (subnet delegation to Microsoft.Web/serverFarms), public access disabled, minimum TLS 1.2
  - Private Endpoint with automatic DNS registration (privatelink DNS zone + VNet link + zone group)
  - NSG rules: AppGateway allows GatewayManager (65200-65535), HTTP (80), HTTPS (443); App/PE subnets allow VNet inbound only, deny all else
- **Networking Architecture:**
  - 4 dedicated subnets (AppGateway, Firewall, AppIntegration with delegation + route table, PrivateEndpoint)
  - AppIntegrationSubnet has Microsoft.Web/serverFarms delegation for VNet integration, attached route table for firewall routing
  - PrivateEndpointSubnet has privateEndpointNetworkPolicies disabled for private link support
  - Web App uses vnetRouteAllEnabled to force all outbound traffic through VNet (including to Azure services)
- **Circular Dependency Resolution:** Route table created with empty routes array, firewall deployed, then route added as child resource (Microsoft.Network/routeTables/routes) to break VNet → RouteTable → Firewall cycle
- **ARM JSON Generation:** Valid azuredeploy.json (30.08 KB) compiled from Bicep for Azure Portal Deploy button
- **Parameters File:** dev.parameters.json with cost-efficient defaults (enableWafPrevention: true, 48-hour TTL)
- **Architecture Diagram:** Updated architecture.mmd to show complete topology with 4 subnets, NSGs, route table, firewall traffic flow, private link connection, VNet integration
- **Bicep Validation:** Successfully compiles with az bicep build (warnings only, no errors)
- **Resource Naming:** Consistent patterns using ${prefix}- suffix, abbreviations follow Azure CAF standards (vnet-, nsg-, agw-, pip-, fw-, waf-, log-, rt-, asp-, app-, pe-, private DNS zone)
- **Outputs:** vnetId, appGatewayPublicIp, appGatewayFqdn, firewallPrivateIp, webAppName, webAppHostName, webAppPrivateEndpoint, privateDnsZoneName, wafMode, deployedResources array (13 resources), deploymentTimestamp
- **Cost Target:** ~$35-60/day (Application Gateway WAF_v2 ~$125/mo base + $ .008/hr/unit = ~$130/mo, Azure Firewall Standard ~$1.25/hr = ~$900/mo, App Service B1 ~$13/mo, total ~$1050-1800/mo or $35-60/day - cost drivers are AppGW WAF and Firewall)
- **Quality Bar:** Matches all previous patterns - complete resource definitions, no TODOs, valid syntax, comprehensive outputs, proper tagging, security by default, production-ready
- **Pattern Decisions:** Firewall always deployed (not optional) because route table depends on it, WAF mode configurable via parameter, Web App uses VNet integration + Private Endpoint for double isolation

### 2026-04-01T10:33:23Z : Data Analytics Pipeline Pattern Complete
- **Pattern:** data-analytics-pipeline - Final pattern implementation (8th of 8 patterns)
- **Resources Deployed:** 
  - Azure Data Lake Storage Gen2 (HNS enabled, hot tier, TLS 1.2, 2 containers: raw + curated)
  - Azure Synapse Analytics Workspace (managed identity, managed VNet, serverless SQL pool built-in)
  - Azure Data Factory (managed identity, orchestration engine)
  - Azure Key Vault (RBAC auth, soft delete, stores SQL admin password)
  - Log Analytics workspace (30-day retention, diagnostics for Synapse + ADF)
  - Optional Synapse Spark Pool (3-10 node auto-scale, 15min auto-pause) - disabled by default due to cost
- **Security Posture:**
  - Managed identities on Synapse and ADF for passwordless authentication
  - RBAC role assignments: Synapse → Storage Blob Data Contributor, ADF → Storage Blob Data Contributor
  - Key Vault stores SQL admin credentials with RBAC-based access control
  - HTTPS-only storage, minimal TLS 1.2, public blob access disabled
  - Data Lake firewall allows Azure services, managed VNet for Synapse
  - Diagnostic settings route Synapse and ADF logs to Log Analytics
- **Parameters:** location, prefix, tags (owner/workload/environment/ttlHours), sqlAdminLogin (default: 'sqladmin'), sqlAdminPassword (secure), enableSynapseSparkPool (bool, default: false)
- **Outputs:** synapseWorkspaceUrl, dataFactoryName, dataLakeStorageEndpoint, keyVaultUri, workspaceId, resourceGroupName, deployedResources array, deploymentTimestamp
- **Naming Convention:** Globally unique names using uniqueString() - {prefix}adls{hash}, {prefix}synw{hash}, {prefix}adf{hash}, {prefix}kv{hash12}
- **Cost Model:** ~\-30/day (Synapse workspace + serverless SQL is pay-per-query), ~\-150/day if Spark pool enabled - designed for cost-conscious demos
- **Architecture Diagram:** Updated architecture.mmd with top-down flow showing orchestration (ADF), storage zones (Data Lake), analytics engines (Synapse serverless + Spark), security (Key Vault, Log Analytics), and consumption layer (Power BI, Apps, ML)
- **Bicep Quality:** Clean build, no warnings, all parameters annotated with @description, standard outputs, proper resource dependencies, conditional Spark pool deployment
- **ARM Compilation:** azuredeploy.json generated (15KB) for Azure Portal "Deploy to Azure" button compatibility
- **Parameter File:** dev.parameters.json updated with sqlAdminLogin, sqlAdminPassword, enableSynapseSparkPool, and standard tags
- **Pattern Status:** Production-ready, fully deployable, serverless SQL pool included (no extra cost), Spark pool optional (expensive add-on)
- **Key Design Decision:** Default to serverless SQL only (cost-effective), Spark pool opt-in via parameter (expensive but powerful for big data processing)
