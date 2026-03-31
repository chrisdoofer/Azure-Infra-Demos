import type { Metadata } from 'next';
import Link from 'next/link';
import './globals.css';

export const metadata: Metadata = {
  title: 'Azure Pattern Demo Portal',
  description: 'Browse and deploy Azure architecture patterns with one-click deployment',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <div className="min-h-screen flex flex-col">
          <header className="bg-[#1B1A19] sticky top-0 z-50">
            <div className="max-w-content mx-auto px-6 lg:px-8">
              <div className="flex items-center justify-between h-16">
                <Link href="/" className="flex items-center gap-3">
                  <svg className="w-8 h-8 text-white" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M11.5 2L2 9l1.5 1.5 8-6.5 8 6.5L21 9l-9.5-7zm0 5L2 14l1.5 1.5 8-6.5 8 6.5L21 14l-9.5-7zm0 5L2 19l1.5 1.5 8-6.5 8 6.5L21 19l-9.5-7z"/>
                  </svg>
                  <div>
                    <h1 className="text-[20px] leading-[28px] font-semibold text-white">Azure Pattern Demo Portal</h1>
                  </div>
                </Link>
                <nav className="flex items-center gap-8">
                  <Link 
                    href="/" 
                    className="text-[14px] font-normal text-white hover:text-azure-light transition-colors"
                  >
                    Patterns
                  </Link>
                  <a 
                    href="https://github.com/chrbenne/Azure-Infra-Demos"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-[14px] font-normal text-white hover:text-azure-light transition-colors flex items-center gap-2"
                  >
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                      <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
                    </svg>
                    GitHub
                  </a>
                </nav>
              </div>
            </div>
          </header>

          <main className="flex-1 bg-neutral-page">
            {children}
          </main>

          <footer className="bg-neutral-subtle border-t border-neutral-divider mt-12">
            <div className="max-w-content mx-auto px-6 lg:px-8 py-8">
              <div className="text-center space-y-2">
                <p className="text-[12px] leading-[16px] text-neutral-text-secondary">
                  <strong className="font-semibold">Disclaimer:</strong> These patterns are provided as educational examples. 
                  Review costs, security settings, and compliance requirements before deploying to production.
                </p>
                <p className="text-[12px] leading-[16px] text-neutral-text-disabled">
                  Based on <a 
                    href="https://learn.microsoft.com/azure/architecture/" 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="text-azure hover:text-azure-hover underline"
                  >
                    Azure Architecture Center
                  </a> guidance.
                </p>
              </div>
            </div>
          </footer>
        </div>
      </body>
    </html>
  );
}
