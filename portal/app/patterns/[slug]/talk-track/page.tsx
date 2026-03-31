import fs from 'fs';
import path from 'path';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { loadPatterns, getPatternBySlug } from '@/lib/patterns';
import ReactMarkdown from 'react-markdown';

export async function generateStaticParams() {
  const patterns = loadPatterns();
  return patterns.map((pattern) => ({
    slug: pattern.slug,
  }));
}

export default function TalkTrackPage({ params }: { params: { slug: string } }) {
  const pattern = getPatternBySlug(params.slug);

  if (!pattern) {
    notFound();
  }

  // Load talk track markdown content at build time
  let talkTrackContent = '';
  try {
    const talkTrackPath = path.join(process.cwd(), '..', 'patterns', params.slug, 'talk-track.md');
    talkTrackContent = fs.readFileSync(talkTrackPath, 'utf-8');
  } catch {
    // Talk track file may not exist for scaffold patterns
    talkTrackContent = '';
  }

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-6 flex items-center justify-between">
        <Link 
          href={`/patterns/${pattern.slug}/`}
          className="inline-flex items-center gap-2 text-sm text-azure-600 hover:text-azure-700"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to pattern
        </Link>
        
        <button
          onClick={() => window.print()}
          className="px-4 py-2 bg-azure-500 text-white rounded-lg hover:bg-azure-600 transition-colors flex items-center gap-2"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
          </svg>
          Print
        </button>
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          {pattern.title} — Talk Track
        </h1>
        <p className="text-gray-600 mb-8">
          Customer-ready presentation guide and business value narrative
        </p>

        <div className="markdown-content">
          {talkTrackContent ? (
            <ReactMarkdown>{talkTrackContent}</ReactMarkdown>
          ) : (
            <div className="text-center py-12">
              <svg className="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <h3 className="text-lg font-medium text-gray-900 mb-2">Talk Track Coming Soon</h3>
              <p className="text-gray-600">
                The customer-ready talk track for this pattern is currently being developed.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
