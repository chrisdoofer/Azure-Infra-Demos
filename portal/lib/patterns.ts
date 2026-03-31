import patternsData from '@/data/patterns.json';
import type { Pattern, FilterState, SortField, SortDirection, PatternCategory, CostBand } from '@/types/pattern';

export function loadPatterns(): Pattern[] {
  return patternsData as Pattern[];
}

export function getPatternBySlug(slug: string): Pattern | undefined {
  const patterns = loadPatterns();
  return patterns.find(p => p.slug === slug);
}

export function filterPatterns(patterns: Pattern[], filters: FilterState): Pattern[] {
  return patterns.filter(pattern => {
    const searchLower = filters.search.toLowerCase();
    const matchesSearch = !filters.search || 
      pattern.title.toLowerCase().includes(searchLower) ||
      pattern.summary.toLowerCase().includes(searchLower) ||
      pattern.tags.some(tag => tag.toLowerCase().includes(searchLower)) ||
      pattern.primaryServices.some(service => service.toLowerCase().includes(searchLower));

    const matchesCategory = filters.categories.length === 0 || 
      filters.categories.includes(pattern.category);

    const matchesCost = filters.costBands.length === 0 || 
      filters.costBands.includes(pattern.estimatedCostBand);

    const matchesComplexity = pattern.complexity >= filters.complexityMin && 
      pattern.complexity <= filters.complexityMax;

    return matchesSearch && matchesCategory && matchesCost && matchesComplexity;
  });
}

export function sortPatterns(
  patterns: Pattern[], 
  sortBy: SortField, 
  direction: SortDirection
): Pattern[] {
  const sorted = [...patterns].sort((a, b) => {
    let comparison = 0;
    
    switch (sortBy) {
      case 'title':
        comparison = a.title.localeCompare(b.title);
        break;
      case 'cost':
        const costOrder: Record<CostBand, number> = { 
          'low': 1, 
          'medium': 2, 
          'high': 3, 
          'very-high': 4 
        };
        comparison = costOrder[a.estimatedCostBand] - costOrder[b.estimatedCostBand];
        break;
      case 'complexity':
        comparison = a.complexity - b.complexity;
        break;
      case 'deployTime':
        comparison = a.typicalDeployTimeMinutes - b.typicalDeployTimeMinutes;
        break;
    }
    
    return direction === 'asc' ? comparison : -comparison;
  });
  
  return sorted;
}

export function getCategories(): PatternCategory[] {
  return ['networking', 'compute', 'data', 'security', 'monitoring', 'governance', 'ai-ml', 'web'];
}

export function getCostBands(): CostBand[] {
  return ['low', 'medium', 'high', 'very-high'];
}

export function getCategoryLabel(category: PatternCategory): string {
  const labels: Record<PatternCategory, string> = {
    'networking': 'Networking',
    'compute': 'Compute',
    'data': 'Data',
    'security': 'Security',
    'monitoring': 'Monitoring',
    'governance': 'Governance',
    'ai-ml': 'AI & ML',
    'web': 'Web',
  };
  return labels[category];
}

export function getCategoryColor(category: PatternCategory): string {
  const colors: Record<PatternCategory, string> = {
    'networking': 'bg-blue-100 text-blue-800',
    'compute': 'bg-green-100 text-green-800',
    'data': 'bg-purple-100 text-purple-800',
    'security': 'bg-red-100 text-red-800',
    'monitoring': 'bg-yellow-100 text-yellow-800',
    'governance': 'bg-gray-100 text-gray-800',
    'ai-ml': 'bg-pink-100 text-pink-800',
    'web': 'bg-indigo-100 text-indigo-800',
  };
  return colors[category];
}

export function getComplexityLabel(complexity: number): string {
  const labels: Record<number, string> = {
    1: 'Beginner',
    2: 'Intermediate',
    3: 'Advanced',
    4: 'Expert',
    5: 'Master',
  };
  return labels[complexity] || 'Unknown';
}

export function getCostBandLabel(costBand: CostBand): string {
  const labels: Record<CostBand, string> = {
    'low': '$10-50/month',
    'medium': '$50-200/month',
    'high': '$200-1000/month',
    'very-high': '$1000+/month',
  };
  return labels[costBand];
}
