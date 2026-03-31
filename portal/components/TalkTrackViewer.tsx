'use client';

import { useState } from 'react';
import ReactMarkdown from 'react-markdown';

interface TalkTrackViewerProps {
  content: string;
  patternTitle: string;
}

export default function TalkTrackViewer({ content, patternTitle }: TalkTrackViewerProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(content);
  };

  return (
    <div className="bg-neutral-white border border-neutral-border-default rounded-md overflow-hidden shadow-card">
      <div className="bg-neutral-subtle px-6 py-4 border-b border-neutral-divider flex items-center justify-between">
        <h3 className="text-[16px] leading-[22px] font-semibold text-neutral-text-primary">Talk Track</h3>
        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="px-3 py-1.5 text-[14px] text-neutral-text-primary hover:text-neutral-text-primary border border-neutral-border-default rounded hover:bg-neutral-divider transition-colors"
            title="Copy to clipboard"
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
      <div 
        className={`px-6 py-4 markdown-content overflow-hidden transition-all ${
          isExpanded ? 'max-h-none' : 'max-h-96'
        }`}
      >
        {content ? (
          <ReactMarkdown>{content}</ReactMarkdown>
        ) : (
          <p className="text-neutral-text-disabled italic text-[14px]">
            Talk track not yet available for {patternTitle}.
          </p>
        )}
      </div>
      {!isExpanded && content && (
        <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-neutral-white to-transparent pointer-events-none" />
      )}
    </div>
  );
}
