export const siteConfig = {
  // CHANGE THESE to match your GitHub repo
  githubOwner: 'chrisdoofer',
  githubRepo: 'Azure-Infra-Demos',
  defaultBranch: 'master',
  
  // Template hosting strategy:
  // 'github-pages' — templates served via GitHub Pages (works for private repos)
  // 'github-raw' — templates served via raw.githubusercontent.com (requires public repo)
  templateHosting: 'github-raw' as 'github-pages' | 'github-raw',
  
  // Computed base URLs
  get pagesBaseUrl() {
    return `https://${this.githubOwner}.github.io/${this.githubRepo}`;
  },
  get rawBaseUrl() {
    return `https://raw.githubusercontent.com/${this.githubOwner}/${this.githubRepo}/${this.defaultBranch}`;
  },
  get templateBaseUrl() {
    return this.templateHosting === 'github-pages' ? this.pagesBaseUrl : this.rawBaseUrl;
  },
};
