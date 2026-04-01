'use client';

import { useState } from 'react';

interface BicepViewerProps {
  content: string;
  patternTitle: string;
}

export default function BicepViewer({ content, patternTitle }: BicepViewerProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(content);
  };

  const lines = content.split('\n');
  const previewLines = lines.slice(0, 15).join('\n');

  return (
    <div className="bg-neutral-white border border-neutral-border-default rounded-md overflow-hidden shadow-card">
      <div className="bg-neutral-subtle px-6 py-4 border-b border-neutral-divider flex items-center justify-between">
        <h3 className="text-[16px] leading-[22px] font-semibold text-neutral-text-primary">
          Infrastructure Code (Bicep)
        </h3>
        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="px-3 py-1.5 text-[14px] text-neutral-text-primary hover:text-neutral-text-primary border border-neutral-border-default rounded hover:bg-neutral-divider transition-colors"
            title="Copy entire Bicep source"
          >
            Copy
          </button>
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="px-3 py-1.5 text-[14px] text-neutral-text-primary hover:text-neutral-text-primary border border-neutral-border-default rounded hover:bg-neutral-divider transition-colors"
          >
            {isExpanded ? 'Collapse' : 'Expand'}
          </button>
        </div>
      </div>
      <div className="relative">
        <div 
          className={`overflow-x-auto ${
            isExpanded ? '' : 'max-h-[400px] overflow-hidden'
          }`}
        >
          <pre className="p-6 text-[12px] leading-[18px] font-mono bg-neutral-page">
            <code className="text-neutral-text-primary">
              {isExpanded ? content : previewLines}
            </code>
          </pre>
        </div>
        {!isExpanded && (
          <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-neutral-page to-transparent pointer-events-none" />
        )}
      </div>
      {!isExpanded && (
        <div className="px-6 py-3 bg-neutral-subtle border-t border-neutral-divider">
          <p className="text-[12px] text-neutral-text-secondary">
            Showing first {Math.min(15, lines.length)} of {lines.length} lines. Click Expand to see full source.
          </p>
        </div>
      )}
    </div>
  );
}
