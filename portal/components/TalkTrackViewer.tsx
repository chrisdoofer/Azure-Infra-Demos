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
    <div className="bg-white border border-gray-200 rounded-lg overflow-hidden">
      <div className="bg-gray-50 px-6 py-4 border-b border-gray-200 flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-900">Talk Track</h3>
        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="px-3 py-1.5 text-sm text-gray-700 hover:text-gray-900 border border-gray-300 rounded hover:bg-gray-100 transition-colors"
            title="Copy to clipboard"
          >
            Copy
          </button>
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="px-3 py-1.5 text-sm text-gray-700 hover:text-gray-900 border border-gray-300 rounded hover:bg-gray-100 transition-colors"
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
          <p className="text-gray-500 italic">
            Talk track not yet available for {patternTitle}.
          </p>
        )}
      </div>
      {!isExpanded && content && (
        <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-white to-transparent pointer-events-none" />
      )}
    </div>
  );
}
