#!/usr/bin/env tsx
import * as fs from 'fs';
import * as path from 'path';
import * as readline from 'readline';

interface Pattern {
  slug: string;
  name: string;
  category: string;
  services: string[];
  costBand: string;
  complexity: string;
  sourceUrl: string;
  summary: string;
  status: string;
}

interface Catalog {
  version: string;
  lastUpdated: string;
  patterns: Pattern[];
}

const PATTERNS_DIR = path.join(__dirname, '..', 'patterns');
const CATALOG_PATH = path.join(PATTERNS_DIR, 'catalog', 'patterns.json');
const TEMPLATE_DIR = path.join(PATTERNS_DIR, '_template');

const REQUIRED_FILES = [
  'main.bicep',
  'README.md',
  'talk-track.md',
  'architecture.mmd',
  'parameters/dev.parameters.json'
];

function slugify(name: string): string {
  return name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

function loadCatalog(): Catalog {
  if (!fs.existsSync(CATALOG_PATH)) {
    return {
      version: '1.0.0',
      lastUpdated: new Date().toISOString(),
      patterns: []
    };
  }
  return JSON.parse(fs.readFileSync(CATALOG_PATH, 'utf-8'));
}

function saveCatalog(catalog: Catalog): void {
  catalog.lastUpdated = new Date().toISOString();
  fs.mkdirSync(path.dirname(CATALOG_PATH), { recursive: true });
  fs.writeFileSync(CATALOG_PATH, JSON.stringify(catalog, null, 2));
  console.log(`✅ Catalog saved to ${CATALOG_PATH}`);
}

function createPatternDirectory(pattern: Pattern): void {
  const patternDir = path.join(PATTERNS_DIR, pattern.slug);
  
  if (fs.existsSync(patternDir)) {
    console.log(`⚠️  Directory already exists: ${patternDir}`);
    return;
  }

  // Create directory structure
  fs.mkdirSync(path.join(patternDir, 'parameters'), { recursive: true });
  
  // Copy template files
  const templateFiles = [
    'main.bicep',
    'README.md',
    'talk-track.md',
    'architecture.mmd',
    'parameters/dev.parameters.json'
  ];

  for (const file of templateFiles) {
    const templatePath = path.join(TEMPLATE_DIR, file);
    const targetPath = path.join(patternDir, file);
    
    if (fs.existsSync(templatePath)) {
      let content = fs.readFileSync(templatePath, 'utf-8');
      
      // Replace template placeholders
      content = content
        .replace(/{PATTERN_NAME}/g, pattern.name)
        .replace(/{PATTERN_SLUG}/g, pattern.slug)
        .replace(/{PATTERN_SUMMARY}/g, pattern.summary)
        .replace(/{PATTERN_CATEGORY}/g, pattern.category)
        .replace(/{PATTERN_SERVICES}/g, pattern.services.join(', '));
      
      fs.mkdirSync(path.dirname(targetPath), { recursive: true });
      fs.writeFileSync(targetPath, content);
    }
  }

  console.log(`✅ Created pattern directory: ${patternDir}`);
}

async function promptUser(question: string): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

async function createPattern(): Promise<void> {
  console.log('\n📝 Create New Pattern\n');

  const name = await promptUser('Pattern name: ');
  const slug = await promptUser(`Slug [${slugify(name)}]: `) || slugify(name);
  const category = await promptUser('Category (reference-architecture/solution-idea/quickstart): ');
  const servicesInput = await promptUser('Services (comma-separated): ');
  const services = servicesInput.split(',').map(s => s.trim());
  const costBand = await promptUser('Cost band (low/medium/high): ');
  const complexity = await promptUser('Complexity (beginner/intermediate/advanced): ');
  const sourceUrl = await promptUser('Source URL (Architecture Center): ');
  const summary = await promptUser('Summary: ');

  const pattern: Pattern = {
    slug,
    name,
    category,
    services,
    costBand,
    complexity,
    sourceUrl,
    summary,
    status: 'scaffold'
  };

  const catalog = loadCatalog();
  
  // Check for duplicates
  if (catalog.patterns.some(p => p.slug === slug)) {
    console.error(`❌ Pattern with slug "${slug}" already exists`);
    return;
  }

  catalog.patterns.push(pattern);
  saveCatalog(catalog);
  createPatternDirectory(pattern);

  console.log('\n✅ Pattern created successfully!');
}

function listPatterns(): void {
  const catalog = loadCatalog();
  
  if (catalog.patterns.length === 0) {
    console.log('No patterns found.');
    return;
  }

  console.log(`\n📋 Patterns (${catalog.patterns.length} total)\n`);
  console.log('Status | Slug | Name');
  console.log('-------|------|-----');
  
  for (const pattern of catalog.patterns) {
    const statusIcon = pattern.status === 'complete' ? '✅' : 
                       pattern.status === 'scaffold' ? '📋' : '⚠️';
    console.log(`${statusIcon} ${pattern.status.padEnd(8)} | ${pattern.slug.padEnd(30)} | ${pattern.name}`);
  }
  
  console.log('');
}

function validatePatterns(): void {
  const catalog = loadCatalog();
  let errors = 0;

  console.log('\n🔍 Validating patterns...\n');

  for (const pattern of catalog.patterns) {
    const patternDir = path.join(PATTERNS_DIR, pattern.slug);
    
    if (!fs.existsSync(patternDir)) {
      console.error(`❌ ${pattern.slug}: Directory not found`);
      errors++;
      continue;
    }

    for (const file of REQUIRED_FILES) {
      const filePath = path.join(patternDir, file);
      if (!fs.existsSync(filePath)) {
        console.error(`❌ ${pattern.slug}: Missing ${file}`);
        errors++;
      }
    }
  }

  // Check for orphaned directories
  const catalogSlugs = new Set(catalog.patterns.map(p => p.slug));
  const dirs = fs.readdirSync(PATTERNS_DIR, { withFileTypes: true })
    .filter(d => d.isDirectory() && !d.name.startsWith('_') && d.name !== 'catalog')
    .map(d => d.name);

  for (const dir of dirs) {
    if (!catalogSlugs.has(dir)) {
      console.warn(`⚠️  Orphaned directory: ${dir} (not in catalog)`);
      errors++;
    }
  }

  if (errors === 0) {
    console.log('✅ All patterns validated successfully!');
  } else {
    console.error(`\n❌ Found ${errors} validation errors`);
    process.exit(1);
  }
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const command = args[0];

  switch (command) {
    case 'create':
      await createPattern();
      break;
    case 'list':
      listPatterns();
      break;
    case 'validate':
      validatePatterns();
      break;
    default:
      console.log(`
Azure Infrastructure Demos - Catalog Builder

Usage:
  npm run catalog create    - Create a new pattern
  npm run catalog list      - List all patterns
  npm run catalog validate  - Validate pattern directories

Options:
  create    Interactive pattern creation wizard
  list      Display all patterns with status
  validate  Check pattern integrity
      `);
  }
}

main().catch(console.error);
