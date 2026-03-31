export type PatternCategory = 
  | 'networking' 
  | 'compute' 
  | 'data' 
  | 'security' 
  | 'monitoring' 
  | 'governance' 
  | 'ai-ml' 
  | 'web';

export type CostBand = 'low' | 'medium' | 'high' | 'very-high';

export type DeploymentMode = 'portal' | 'actions';

export interface Pattern {
  id: string;
  slug: string;
  title: string;
  summary: string;
  sourceUrl: string;
  category: PatternCategory;
  tags: string[];
  primaryServices: string[];
  estimatedCostBand: CostBand;
  complexity: 1 | 2 | 3 | 4 | 5;
  typicalDeployTimeMinutes: number;
  deploymentModesSupported: DeploymentMode[];
  templatePath: string;
  actionsWorkflowInputsExample: Record<string, string>;
  lastReviewedDate: string;
}

export interface FilterState {
  search: string;
  categories: PatternCategory[];
  costBands: CostBand[];
  complexityMin: number;
  complexityMax: number;
}

export type SortField = 'title' | 'cost' | 'complexity' | 'deployTime';
export type SortDirection = 'asc' | 'desc';
