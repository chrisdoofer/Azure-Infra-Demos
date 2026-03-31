import { notFound } from 'next/navigation';
import Link from 'next/link';
import { loadPatterns, getPatternBySlug, getCategoryLabel, getCategoryColor } from '@/lib/patterns';
import DeployButton from '@/components/DeployButton';
import CostBadge from '@/components/CostBadge';
import ComplexityIndicator from '@/components/ComplexityIndicator';
import TalkTrackViewer from '@/components/TalkTrackViewer';

export async function generateStaticParams() {
  const patterns = loadPatterns();
  return patterns.map((pattern) => ({
    slug: pattern.slug,
  }));
}

export default function PatternDetailPage({ params }: { params: { slug: string } }) {
  const pattern = getPatternBySlug(params.slug);

  if (!pattern) {
    notFound();
  }

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link 
        href="/"
        className="inline-flex items-center gap-2 text-sm text-azure-600 hover:text-azure-700 mb-6"
      >
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
        </svg>
        Back to catalogue
      </Link>

      <div className="bg-white border border-gray-200 rounded-lg p-8 mb-6">
        <div className="flex items-start justify-between mb-4">
          <span className={`px-3 py-1 text-sm font-medium rounded-full ${getCategoryColor(pattern.category)}`}>
            {getCategoryLabel(pattern.category)}
          </span>
          <div className="flex items-center gap-4">
            <CostBadge costBand={pattern.estimatedCostBand} showLabel />
            <ComplexityIndicator complexity={pattern.complexity} showLabel />
          </div>
        </div>

        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          {pattern.title}
        </h1>

        <p className="text-lg text-gray-700 mb-6">
          {pattern.summary}
        </p>

        <div className="flex flex-wrap gap-2 mb-6">
          {pattern.tags.map((tag) => (
            <span
              key={tag}
              className="px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded-full"
            >
              #{tag}
            </span>
          ))}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6 p-4 bg-gray-50 rounded-lg">
          <div>
            <p className="text-sm text-gray-600 mb-1">Deploy Time</p>
            <p className="text-lg font-semibold text-gray-900">
              ~{pattern.typicalDeployTimeMinutes} minutes
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600 mb-1">Last Reviewed</p>
            <p className="text-lg font-semibold text-gray-900">
              {new Date(pattern.lastReviewedDate).toLocaleDateString()}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600 mb-1">Source</p>
            <a 
              href={pattern.sourceUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-lg font-semibold text-azure-600 hover:text-azure-700 flex items-center gap-1"
            >
              Architecture Center
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
            </a>
          </div>
        </div>

        {pattern.deploymentModesSupported.length > 0 ? (
          <div className="flex gap-4">
            <DeployButton 
              templatePath={pattern.templatePath}
              patternName={pattern.title}
            />
          </div>
        ) : (
          <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <p className="text-sm text-yellow-800">
              <strong>Note:</strong> This pattern is currently being prepared for deployment. 
              Check back soon or visit the source documentation.
            </p>
          </div>
        )}
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-8 mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Azure Services</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {pattern.primaryServices.map((service) => (
            <div 
              key={service}
              className="flex items-center gap-3 p-3 bg-azure-50 rounded-lg"
            >
              <div className="w-2 h-2 bg-azure-500 rounded-full"></div>
              <span className="text-gray-900 font-medium">{service}</span>
            </div>
          ))}
        </div>
      </div>

      {pattern.deploymentModesSupported.includes('actions') && (
        <div className="bg-white border border-gray-200 rounded-lg p-8 mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">
            Deploy via GitHub Actions
          </h2>
          <p className="text-gray-700 mb-4">
            This pattern supports automated deployment through GitHub Actions. 
            Use these example inputs in your workflow:
          </p>
          <div className="bg-gray-50 rounded-lg p-4 overflow-x-auto">
            <pre className="text-sm">
              <code>{JSON.stringify(pattern.actionsWorkflowInputsExample, null, 2)}</code>
            </pre>
          </div>
        </div>
      )}

      <div className="mb-6">
        <TalkTrackViewer 
          content=""
          patternTitle={pattern.title}
        />
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-8 mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Cost & Guardrails</h2>
        <div className="space-y-4">
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Estimated Cost</h3>
            <p className="text-gray-700">
              This pattern is classified as <strong>{pattern.estimatedCostBand} cost</strong>. 
              Actual costs will vary based on:
            </p>
            <ul className="list-disc list-inside text-gray-700 mt-2 space-y-1">
              <li>Resource SKUs and sizing</li>
              <li>Data transfer and storage volumes</li>
              <li>Region selection</li>
              <li>Usage patterns and scale</li>
            </ul>
          </div>
          <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-800">
              <strong>Tip:</strong> Use <a 
                href="https://azure.microsoft.com/pricing/calculator/" 
                target="_blank" 
                rel="noopener noreferrer"
                className="underline"
              >
                Azure Pricing Calculator
              </a> for detailed cost estimates before deployment.
            </p>
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-8">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Teardown Instructions</h2>
        <p className="text-gray-700 mb-4">
          To avoid ongoing charges, delete the resource group when you're done testing:
        </p>
        <div className="bg-gray-50 rounded-lg p-4">
          <code className="text-sm">
            az group delete --name &lt;resource-group-name&gt; --yes --no-wait
          </code>
        </div>
        <p className="text-sm text-gray-600 mt-4">
          Alternatively, delete the resource group through the Azure Portal under Resource Groups.
        </p>
      </div>
    </div>
  );
}
