'use client';

import type { PatternCategory, CostBand } from '@/types/pattern';
import { getCategories, getCostBands, getCategoryLabel } from '@/lib/patterns';

interface FilterBarProps {
  selectedCategories: PatternCategory[];
  selectedCostBands: CostBand[];
  complexityRange: [number, number];
  onCategoriesChange: (categories: PatternCategory[]) => void;
  onCostBandsChange: (costBands: CostBand[]) => void;
  onComplexityRangeChange: (range: [number, number]) => void;
  onClearAll: () => void;
}

export default function FilterBar({
  selectedCategories,
  selectedCostBands,
  complexityRange,
  onCategoriesChange,
  onCostBandsChange,
  onComplexityRangeChange,
  onClearAll,
}: FilterBarProps) {
  const categories = getCategories();
  const costBands = getCostBands();

  const toggleCategory = (category: PatternCategory) => {
    if (selectedCategories.includes(category)) {
      onCategoriesChange(selectedCategories.filter(c => c !== category));
    } else {
      onCategoriesChange([...selectedCategories, category]);
    }
  };

  const toggleCostBand = (costBand: CostBand) => {
    if (selectedCostBands.includes(costBand)) {
      onCostBandsChange(selectedCostBands.filter(c => c !== costBand));
    } else {
      onCostBandsChange([...selectedCostBands, costBand]);
    }
  };

  const activeFilterCount = 
    selectedCategories.length + 
    selectedCostBands.length + 
    (complexityRange[0] !== 1 || complexityRange[1] !== 5 ? 1 : 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-gray-700">Filters</h3>
        {activeFilterCount > 0 && (
          <button
            onClick={onClearAll}
            className="text-sm text-azure-600 hover:text-azure-700 font-medium"
          >
            Clear all ({activeFilterCount})
          </button>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Category
        </label>
        <div className="flex flex-wrap gap-2">
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => toggleCategory(category)}
              className={`px-3 py-1.5 text-sm rounded-full border transition-colors ${
                selectedCategories.includes(category)
                  ? 'bg-azure-500 text-white border-azure-500'
                  : 'bg-white text-gray-700 border-gray-300 hover:border-azure-500'
              }`}
            >
              {getCategoryLabel(category)}
            </button>
          ))}
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Cost Band
        </label>
        <div className="flex flex-wrap gap-2">
          {costBands.map((costBand) => (
            <button
              key={costBand}
              onClick={() => toggleCostBand(costBand)}
              className={`px-3 py-1.5 text-sm rounded-full border transition-colors ${
                selectedCostBands.includes(costBand)
                  ? 'bg-azure-500 text-white border-azure-500'
                  : 'bg-white text-gray-700 border-gray-300 hover:border-azure-500'
              }`}
            >
              {costBand}
            </button>
          ))}
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Complexity: {complexityRange[0]} - {complexityRange[1]}
        </label>
        <div className="flex items-center gap-4">
          <input
            type="range"
            min="1"
            max="5"
            value={complexityRange[0]}
            onChange={(e) => onComplexityRangeChange([parseInt(e.target.value), complexityRange[1]])}
            className="flex-1"
          />
          <input
            type="range"
            min="1"
            max="5"
            value={complexityRange[1]}
            onChange={(e) => onComplexityRangeChange([complexityRange[0], parseInt(e.target.value)])}
            className="flex-1"
          />
        </div>
        <div className="flex justify-between text-xs text-gray-500 mt-1">
          <span>Beginner</span>
          <span>Expert</span>
        </div>
      </div>
    </div>
  );
}
