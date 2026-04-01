import { siteConfig } from '@/config/site';

interface ActionsDeploySectionProps {
  patternSlug: string;
  patternTitle: string;
  workflowInputsExample: Record<string, string>;
}

export default function ActionsDeploySection({ 
  patternSlug, 
  patternTitle,
  workflowInputsExample 
}: ActionsDeploySectionProps) {
  const workflowUrl = `https://github.com/${siteConfig.githubOwner}/${siteConfig.githubRepo}/actions/workflows/deploy-${patternSlug}.yml`;

  return (
    <div className="bg-neutral-white border border-neutral-border-default rounded-md p-8 shadow-card">
      <h2 className="text-[20px] leading-[28px] font-semibold text-neutral-text-primary mb-4">
        Deploy via GitHub Actions
      </h2>
      <p className="text-[14px] text-neutral-text-secondary mb-6">
        Run the automated deployment workflow from your fork of this repository.
      </p>

      <div className="mb-6">
        <a
          href={workflowUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-4 py-2 bg-azure text-neutral-white rounded hover:bg-azure-hover transition-colors text-[14px] font-semibold"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
          </svg>
          Run Workflow
        </a>
      </div>

      <div className="mb-6">
        <h3 className="text-[16px] leading-[22px] font-semibold text-neutral-text-primary mb-3">
          Deployment Steps
        </h3>
        <ol className="space-y-2 text-[14px] text-neutral-text-secondary">
          <li className="flex items-start gap-2">
            <span className="flex items-center justify-center w-6 h-6 bg-azure text-neutral-white rounded-full text-[12px] font-semibold flex-shrink-0">
              1
            </span>
            <span>
              <strong className="font-semibold text-neutral-text-primary">Fork this repository</strong> to your GitHub account
            </span>
          </li>
          <li className="flex items-start gap-2">
            <span className="flex items-center justify-center w-6 h-6 bg-azure text-neutral-white rounded-full text-[12px] font-semibold flex-shrink-0">
              2
            </span>
            <span>
              <strong className="font-semibold text-neutral-text-primary">Configure Azure OIDC credentials</strong> in your repository secrets (
              <a 
                href={`https://github.com/${siteConfig.githubOwner}/${siteConfig.githubRepo}/blob/${siteConfig.defaultBranch}/SECURITY.md`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-azure hover:text-azure-hover underline"
              >
                see SECURITY.md
              </a>
              )
            </span>
          </li>
          <li className="flex items-start gap-2">
            <span className="flex items-center justify-center w-6 h-6 bg-azure text-neutral-white rounded-full text-[12px] font-semibold flex-shrink-0">
              3
            </span>
            <span>
              Go to <strong className="font-semibold text-neutral-text-primary">Actions → "Deploy: {patternTitle}"</strong> → Run workflow
            </span>
          </li>
          <li className="flex items-start gap-2">
            <span className="flex items-center justify-center w-6 h-6 bg-azure text-neutral-white rounded-full text-[12px] font-semibold flex-shrink-0">
              4
            </span>
            <span>
              Fill in parameters and click <strong className="font-semibold text-neutral-text-primary">"Run workflow"</strong>
            </span>
          </li>
        </ol>
      </div>

      <div className="mb-6">
        <h3 className="text-[16px] leading-[22px] font-semibold text-neutral-text-primary mb-3">
          Recommended Workflow Inputs
        </h3>
        <div className="bg-neutral-subtle rounded-md p-4 overflow-x-auto border border-neutral-border-default">
          <pre className="text-[12px] leading-[18px] font-mono">
            <code className="text-neutral-text-primary">
              {JSON.stringify(workflowInputsExample, null, 2)}
            </code>
          </pre>
        </div>
      </div>

      <div className="p-4 bg-azure-lightest border border-azure-light rounded-md">
        <p className="text-[14px] text-neutral-text-primary">
          <strong className="font-semibold">Note:</strong> See{' '}
          <a 
            href={`https://github.com/${siteConfig.githubOwner}/${siteConfig.githubRepo}/blob/${siteConfig.defaultBranch}/SECURITY.md`}
            target="_blank"
            rel="noopener noreferrer"
            className="text-azure hover:text-azure-hover underline"
          >
            SECURITY.md
          </a>
          {' '}for detailed OIDC setup instructions.
        </p>
      </div>
    </div>
  );
}
