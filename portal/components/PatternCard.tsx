import Link from 'next/link';
import type { Pattern } from '@/types/pattern';
import { getCategoryLabel, getCategoryColor } from '@/lib/patterns';
import CostBadge from './CostBadge';
import ComplexityIndicator from './ComplexityIndicator';

interface PatternCardProps {
  pattern: Pattern;
}

export default function PatternCard({ pattern }: PatternCardProps) {
  const displayServices = pattern.primaryServices.slice(0, 4);
  const remainingCount = pattern.primaryServices.length - 4;

  return (
    <Link href={`/patterns/${pattern.slug}/`} className="block h-full">
      <div className="h-full bg-white border border-gray-200 rounded-lg p-6 card-hover">
        <div className="flex items-start justify-between mb-3">
          <span className={`px-3 py-1 text-xs font-medium rounded-full ${getCategoryColor(pattern.category)}`}>
            {getCategoryLabel(pattern.category)}
          </span>
          <CostBadge costBand={pattern.estimatedCostBand} />
        </div>

        <h3 className="text-xl font-semibold text-gray-900 mb-2 line-clamp-2">
          {pattern.title}
        </h3>

        <p className="text-gray-600 text-sm mb-4 line-clamp-2">
          {pattern.summary}
        </p>

        <div className="flex flex-wrap gap-1.5 mb-4">
          {displayServices.map((service) => (
            <span
              key={service}
              className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded"
            >
              {service}
            </span>
          ))}
          {remainingCount > 0 && (
            <span className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded">
              +{remainingCount} more
            </span>
          )}
        </div>

        <div className="flex items-center justify-between pt-4 border-t border-gray-200">
          <ComplexityIndicator complexity={pattern.complexity} />
          <div className="flex items-center gap-1 text-sm text-gray-600">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{pattern.typicalDeployTimeMinutes} min</span>
          </div>
        </div>

        {pattern.deploymentModesSupported.length > 0 && (
          <div className="mt-3 flex items-center gap-1">
            <svg className="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            <span className="text-xs text-green-600 font-medium">Ready to deploy</span>
          </div>
        )}
      </div>
    </Link>
  );
}
