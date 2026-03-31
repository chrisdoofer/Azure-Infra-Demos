import { siteConfig } from '@/config/site';

interface DeployButtonProps {
  templatePath: string;
  patternName: string;
  variant?: 'primary' | 'secondary';
}

export default function DeployButton({ 
  templatePath, 
  patternName,
  variant = 'primary' 
}: DeployButtonProps) {
  const baseClasses = "inline-flex items-center gap-2 px-6 py-2 rounded font-normal transition-colors focus:outline-none focus:ring-2 focus:ring-azure focus:ring-offset-1 text-[14px] h-8";
  const variantClasses = variant === 'primary'
    ? "bg-azure text-white hover:bg-azure-hover"
    : "bg-neutral-white text-azure border border-neutral-border-strong hover:bg-neutral-subtle";

  const templateUrl = `${siteConfig.templateBaseUrl}/${templatePath}`;
  const encodedUrl = encodeURIComponent(templateUrl);
  const deployUrl = `https://portal.azure.com/#create/Microsoft.Template/uri/${encodedUrl}`;

  return (
    <a
      href={deployUrl}
      target="_blank"
      rel="noopener noreferrer"
      className={`${baseClasses} ${variantClasses}`}
      title={`Deploy ${patternName} to Azure Portal`}
    >
      <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
        <path d="M11.5 2L2 9l1.5 1.5 8-6.5 8 6.5L21 9l-9.5-7zm0 5L2 14l1.5 1.5 8-6.5 8 6.5L21 14l-9.5-7zm0 5L2 19l1.5 1.5 8-6.5 8 6.5L21 19l-9.5-7z"/>
      </svg>
      <span>Deploy to Azure</span>
      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
      </svg>
    </a>
  );
}
