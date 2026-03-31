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
      <div className="h-full bg-neutral-white border border-neutral-border-default rounded-md p-6 card-hover shadow-card">
        <div className="flex items-start justify-between mb-3">
          <span className={`px-3 py-1 text-[12px] leading-[16px] font-normal rounded-full ${getCategoryColor(pattern.category)}`}>
            {getCategoryLabel(pattern.category)}
          </span>
          <CostBadge costBand={pattern.estimatedCostBand} />
        </div>

        <h3 className="text-[16px] leading-[22px] font-semibold text-neutral-text-primary mb-2 line-clamp-2">
          {pattern.title}
        </h3>

        <p className="text-[14px] leading-[20px] text-neutral-text-secondary mb-4 line-clamp-2">
          {pattern.summary}
        </p>

        <div className="flex flex-wrap gap-1.5 mb-4">
          {displayServices.map((service) => (
            <span
              key={service}
              className="px-2 py-1 text-[12px] bg-neutral-subtle text-neutral-text-primary rounded"
            >
              {service}
            </span>
          ))}
          {remainingCount > 0 && (
            <span className="px-2 py-1 text-[12px] bg-neutral-subtle text-neutral-text-primary rounded">
              +{remainingCount} more
            </span>
          )}
        </div>

        <div className="flex items-center justify-between pt-4 border-t border-neutral-divider">
          <ComplexityIndicator complexity={pattern.complexity} />
          <div className="flex items-center gap-1 text-[14px] text-neutral-text-secondary">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{pattern.typicalDeployTimeMinutes} min</span>
          </div>
        </div>

        {pattern.deploymentModesSupported.length > 0 && (
          <div className="mt-3 flex items-center gap-1">
            <svg className="w-4 h-4 text-semantic-success" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            <span className="text-[12px] text-semantic-success font-normal">Ready to deploy</span>
          </div>
        )}
      </div>
    </Link>
  );
}
