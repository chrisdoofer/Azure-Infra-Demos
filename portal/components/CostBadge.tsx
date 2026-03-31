import type { CostBand } from '@/types/pattern';
import { getCostBandLabel } from '@/lib/patterns';

interface CostBadgeProps {
  costBand: CostBand;
  showLabel?: boolean;
}

export default function CostBadge({ costBand, showLabel = false }: CostBadgeProps) {
  const getCostSymbols = (band: CostBand): string => {
    const symbols: Record<CostBand, string> = {
      'low': '$',
      'medium': '$$',
      'high': '$$$',
      'very-high': '$$$$',
    };
    return symbols[band];
  };

  const getCostColor = (band: CostBand): string => {
    const colors: Record<CostBand, string> = {
      'low': 'text-green-600',
      'medium': 'text-yellow-600',
      'high': 'text-orange-600',
      'very-high': 'text-red-600',
    };
    return colors[band];
  };

  return (
    <span 
      className={`inline-flex items-center gap-1 font-semibold ${getCostColor(costBand)}`}
      title={getCostBandLabel(costBand)}
    >
      <span className="text-lg">{getCostSymbols(costBand)}</span>
      {showLabel && <span className="text-sm">{costBand}</span>}
    </span>
  );
}
