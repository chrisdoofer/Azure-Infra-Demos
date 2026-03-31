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
      'low': 'text-semantic-success',
      'medium': 'text-semantic-warning-text',
      'high': 'text-[#D83B01]',
      'very-high': 'text-semantic-danger',
    };
    return colors[band];
  };

  const getCostBg = (band: CostBand): string => {
    const bgs: Record<CostBand, string> = {
      'low': 'bg-[#E5F0D3]',
      'medium': 'bg-semantic-warning-bg',
      'high': 'bg-[#FFEAE5]',
      'very-high': 'bg-[#FFEBE9]',
    };
    return bgs[band];
  };

  return (
    <span 
      className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-[12px] font-normal ${getCostColor(costBand)} ${getCostBg(costBand)}`}
      title={getCostBandLabel(costBand)}
    >
      <span>{getCostSymbols(costBand)}</span>
      {showLabel && <span>{costBand}</span>}
    </span>
  );
}
