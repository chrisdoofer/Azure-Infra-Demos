'use client';

import { useState, useMemo } from 'react';
import { loadPatterns, filterPatterns, sortPatterns } from '@/lib/patterns';
import type { FilterState, SortField, SortDirection } from '@/types/pattern';
import PatternCard from '@/components/PatternCard';
import SearchBar from '@/components/SearchBar';
import FilterBar from '@/components/FilterBar';

export default function HomePage() {
  const allPatterns = loadPatterns();

  const [filters, setFilters] = useState<FilterState>({
    search: '',
    categories: [],
    costBands: [],
    complexityMin: 1,
    complexityMax: 5,
  });

  const [sortBy, setSortBy] = useState<SortField>('title');
  const [sortDirection, setSortDirection] = useState<SortDirection>('asc');
  const [showFilters, setShowFilters] = useState(false);

  const filteredAndSortedPatterns = useMemo(() => {
    const filtered = filterPatterns(allPatterns, filters);
    return sortPatterns(filtered, sortBy, sortDirection);
  }, [allPatterns, filters, sortBy, sortDirection]);

  const handleClearFilters = () => {
    setFilters({
      search: '',
      categories: [],
      costBands: [],
      complexityMin: 1,
      complexityMax: 5,
    });
  };

  const handleSortChange = (field: SortField) => {
    if (sortBy === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortDirection('asc');
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">
          Azure Architecture Patterns
        </h2>
        <p className="text-gray-600">
          Browse production-ready patterns with one-click deployment to Azure
        </p>
      </div>

      <div className="mb-6">
        <SearchBar
          value={filters.search}
          onChange={(value) => setFilters({ ...filters, search: value })}
        />
      </div>

      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
            <span className="text-sm font-medium">
              Filters
              {(filters.categories.length + filters.costBands.length > 0) && 
                ` (${filters.categories.length + filters.costBands.length})`
              }
            </span>
          </button>
          
          <div className="flex items-center gap-2">
            <span className="text-sm text-gray-600">Sort by:</span>
            <select
              value={sortBy}
              onChange={(e) => handleSortChange(e.target.value as SortField)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-azure-500 focus:border-azure-500"
            >
              <option value="title">Name</option>
              <option value="cost">Cost</option>
              <option value="complexity">Complexity</option>
              <option value="deployTime">Deploy Time</option>
            </select>
            <button
              onClick={() => setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc')}
              className="p-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              title={sortDirection === 'asc' ? 'Ascending' : 'Descending'}
            >
              <svg 
                className={`w-4 h-4 transition-transform ${sortDirection === 'desc' ? 'rotate-180' : ''}`} 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 15l7-7 7 7" />
              </svg>
            </button>
          </div>
        </div>

        <p className="text-sm text-gray-600">
          Showing <strong>{filteredAndSortedPatterns.length}</strong> of <strong>{allPatterns.length}</strong> patterns
        </p>
      </div>

      {showFilters && (
        <div className="mb-6 p-6 bg-white border border-gray-200 rounded-lg">
          <FilterBar
            selectedCategories={filters.categories}
            selectedCostBands={filters.costBands}
            complexityRange={[filters.complexityMin, filters.complexityMax]}
            onCategoriesChange={(categories) => setFilters({ ...filters, categories })}
            onCostBandsChange={(costBands) => setFilters({ ...filters, costBands })}
            onComplexityRangeChange={([min, max]) => 
              setFilters({ ...filters, complexityMin: min, complexityMax: max })
            }
            onClearAll={handleClearFilters}
          />
        </div>
      )}

      {filteredAndSortedPatterns.length === 0 ? (
        <div className="text-center py-12">
          <svg className="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No patterns found</h3>
          <p className="text-gray-600 mb-4">
            Try adjusting your search or filters
          </p>
          <button
            onClick={handleClearFilters}
            className="px-4 py-2 bg-azure-500 text-white rounded-lg hover:bg-azure-600 transition-colors"
          >
            Clear all filters
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredAndSortedPatterns.map((pattern) => (
            <PatternCard key={pattern.id} pattern={pattern} />
          ))}
        </div>
      )}
    </div>
  );
}
