import { getComplexityLabel } from '@/lib/patterns';

interface ComplexityIndicatorProps {
  complexity: 1 | 2 | 3 | 4 | 5;
  showLabel?: boolean;
}

export default function ComplexityIndicator({ complexity, showLabel = false }: ComplexityIndicatorProps) {
  return (
    <div className="inline-flex items-center gap-2" title={getComplexityLabel(complexity)}>
      <div className="flex items-center gap-0.5">
        {[1, 2, 3, 4, 5].map((level) => (
          <div
            key={level}
            className={`w-2 h-2 rounded-full ${
              level <= complexity 
                ? 'bg-azure-500' 
                : 'bg-gray-300'
            }`}
          />
        ))}
      </div>
      {showLabel && (
        <span className="text-sm text-gray-600">
          {getComplexityLabel(complexity)}
        </span>
      )}
    </div>
  );
}
