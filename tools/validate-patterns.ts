#!/usr/bin/env tsx
import * as fs from 'fs';
import * as path from 'path';

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

interface ValidationResult {
  passed: boolean;
  errors: string[];
  warnings: string[];
}

const PATTERNS_DIR = path.join(__dirname, '..', 'patterns');
const CATALOG_PATH = path.join(PATTERNS_DIR, 'catalog', 'patterns.json');

const REQUIRED_FILES = [
  'main.bicep',
  'README.md',
  'talk-track.md',
  'architecture.mmd',
  'parameters/dev.parameters.json'
];

const REQUIRED_BICEP_PARAMS = ['location', 'prefix', 'tags'];

const REQUIRED_TALK_TRACK_SECTIONS = [
  '## 1. Opening Hook',
  '## 2. Business Context',
  '## 3. The Challenge',
  '## 4. Solution Overview',
  '## 5. Architecture Walkthrough',
  '## 6. Key Components',
  '## 7. Security & Compliance',
  '## 8. Scalability & Performance',
  '## 9. Cost Optimization',
  '## 10. Deployment Process',
  '## 11. Monitoring & Operations',
  '## 12. Real-World Example',
  '## 13. Common Pitfalls',
  '## 14. Next Steps',
  '## 15. Call to Action'
];

function loadCatalog(): Catalog | null {
  if (!fs.existsSync(CATALOG_PATH)) {
    return null;
  }
  try {
    return JSON.parse(fs.readFileSync(CATALOG_PATH, 'utf-8'));
  } catch (error) {
    return null;
  }
}

function validateCatalogSchema(catalog: Catalog): ValidationResult {
  const result: ValidationResult = { passed: true, errors: [], warnings: [] };

  if (!catalog.version) {
    result.errors.push('Catalog missing version field');
    result.passed = false;
  }

  if (!catalog.lastUpdated) {
    result.errors.push('Catalog missing lastUpdated field');
    result.passed = false;
  }

  if (!Array.isArray(catalog.patterns)) {
    result.errors.push('Catalog patterns field is not an array');
    result.passed = false;
    return result;
  }

  const validCategories = ['reference-architecture', 'solution-idea', 'quickstart'];
  const validCostBands = ['low', 'medium', 'high'];
  const validComplexities = ['beginner', 'intermediate', 'advanced'];
  const validStatuses = ['scaffold', 'in-progress', 'complete'];

  for (const pattern of catalog.patterns) {
    if (!pattern.slug) {
      result.errors.push(`Pattern missing slug: ${JSON.stringify(pattern)}`);
      result.passed = false;
    }
    if (!pattern.name) {
      result.errors.push(`Pattern ${pattern.slug || 'unknown'}: Missing name`);
      result.passed = false;
    }
    if (!validCategories.includes(pattern.category)) {
      result.errors.push(`Pattern ${pattern.slug}: Invalid category "${pattern.category}"`);
      result.passed = false;
    }
    if (!Array.isArray(pattern.services) || pattern.services.length === 0) {
      result.errors.push(`Pattern ${pattern.slug}: Services must be a non-empty array`);
      result.passed = false;
    }
    if (!validCostBands.includes(pattern.costBand)) {
      result.errors.push(`Pattern ${pattern.slug}: Invalid cost band "${pattern.costBand}"`);
      result.passed = false;
    }
    if (!validComplexities.includes(pattern.complexity)) {
      result.errors.push(`Pattern ${pattern.slug}: Invalid complexity "${pattern.complexity}"`);
      result.passed = false;
    }
    if (!pattern.sourceUrl || !pattern.sourceUrl.startsWith('http')) {
      result.errors.push(`Pattern ${pattern.slug}: Invalid or missing sourceUrl`);
      result.passed = false;
    }
    if (!pattern.summary) {
      result.warnings.push(`Pattern ${pattern.slug}: Missing summary`);
    }
    if (!validStatuses.includes(pattern.status)) {
      result.errors.push(`Pattern ${pattern.slug}: Invalid status "${pattern.status}"`);
      result.passed = false;
    }
  }

  return result;
}

function validatePatternDirectory(pattern: Pattern): ValidationResult {
  const result: ValidationResult = { passed: true, errors: [], warnings: [] };
  const patternDir = path.join(PATTERNS_DIR, pattern.slug);

  // Check directory exists
  if (!fs.existsSync(patternDir)) {
    result.errors.push(`Directory not found: ${patternDir}`);
    result.passed = false;
    return result;
  }

  // Check required files
  for (const file of REQUIRED_FILES) {
    const filePath = path.join(patternDir, file);
    if (!fs.existsSync(filePath)) {
      result.errors.push(`Missing required file: ${file}`);
      result.passed = false;
    }
  }

  return result;
}

function validateBicepFile(pattern: Pattern): ValidationResult {
  const result: ValidationResult = { passed: true, errors: [], warnings: [] };
  const bicepPath = path.join(PATTERNS_DIR, pattern.slug, 'main.bicep');

  if (!fs.existsSync(bicepPath)) {
    return result; // Already caught by directory validation
  }

  const content = fs.readFileSync(bicepPath, 'utf-8');

  // Check for required parameters
  for (const param of REQUIRED_BICEP_PARAMS) {
    const paramRegex = new RegExp(`param\\s+${param}\\s+`, 'm');
    if (!paramRegex.test(content)) {
      result.errors.push(`main.bicep missing required parameter: ${param}`);
      result.passed = false;
    }
  }

  // Check for @description decorators
  const paramLines = content.split('\n').filter(line => line.trim().startsWith('param '));
  for (const line of paramLines) {
    const match = line.match(/param\s+(\w+)/);
    if (match) {
      const paramName = match[1];
      const descRegex = new RegExp(`@description\\([^)]+\\)\\s*param\\s+${paramName}`, 's');
      if (!descRegex.test(content)) {
        result.warnings.push(`Parameter ${paramName} missing @description decorator`);
      }
    }
  }

  return result;
}

function validateTalkTrack(pattern: Pattern): ValidationResult {
  const result: ValidationResult = { passed: true, errors: [], warnings: [] };
  const talkTrackPath = path.join(PATTERNS_DIR, pattern.slug, 'talk-track.md');

  if (!fs.existsSync(talkTrackPath)) {
    return result; // Already caught by directory validation
  }

  const content = fs.readFileSync(talkTrackPath, 'utf-8');

  for (const section of REQUIRED_TALK_TRACK_SECTIONS) {
    if (!content.includes(section)) {
      result.errors.push(`talk-track.md missing required section: ${section}`);
      result.passed = false;
    }
  }

  return result;
}

function validateParametersFile(pattern: Pattern): ValidationResult {
  const result: ValidationResult = { passed: true, errors: [], warnings: [] };
  const paramsPath = path.join(PATTERNS_DIR, pattern.slug, 'parameters', 'dev.parameters.json');

  if (!fs.existsSync(paramsPath)) {
    return result; // Already caught by directory validation
  }

  try {
    const params = JSON.parse(fs.readFileSync(paramsPath, 'utf-8'));
    
    if (!params.$schema) {
      result.warnings.push('parameters file missing $schema');
    }
    
    if (!params.contentVersion) {
      result.warnings.push('parameters file missing contentVersion');
    }
    
    if (!params.parameters || typeof params.parameters !== 'object') {
      result.errors.push('parameters file missing or invalid parameters object');
      result.passed = false;
    }
  } catch (error) {
    result.errors.push(`Invalid JSON in parameters file: ${error}`);
    result.passed = false;
  }

  return result;
}

function checkOrphanedDirectories(catalog: Catalog): ValidationResult {
  const result: ValidationResult = { passed: true, errors: [], warnings: [] };
  const catalogSlugs = new Set(catalog.patterns.map(p => p.slug));

  try {
    const dirs = fs.readdirSync(PATTERNS_DIR, { withFileTypes: true })
      .filter(d => d.isDirectory() && !d.name.startsWith('_') && d.name !== 'catalog')
      .map(d => d.name);

    for (const dir of dirs) {
      if (!catalogSlugs.has(dir)) {
        result.warnings.push(`Orphaned directory: ${dir} (not in catalog)`);
      }
    }
  } catch (error) {
    result.errors.push(`Failed to read patterns directory: ${error}`);
    result.passed = false;
  }

  return result;
}

function main(): void {
  console.log('🔍 Azure Infrastructure Demos - Pattern Validation\n');

  let allPassed = true;
  let totalErrors = 0;
  let totalWarnings = 0;

  // Load catalog
  const catalog = loadCatalog();
  if (!catalog) {
    console.error('❌ Failed to load catalog from:', CATALOG_PATH);
    process.exit(1);
  }

  console.log(`📋 Found ${catalog.patterns.length} patterns in catalog\n`);

  // Validate catalog schema
  console.log('Validating catalog schema...');
  const catalogResult = validateCatalogSchema(catalog);
  if (!catalogResult.passed) {
    console.error('❌ Catalog schema validation failed:');
    catalogResult.errors.forEach(e => console.error(`   - ${e}`));
    allPassed = false;
  } else {
    console.log('✅ Catalog schema valid');
  }
  totalErrors += catalogResult.errors.length;
  totalWarnings += catalogResult.warnings.length;
  catalogResult.warnings.forEach(w => console.warn(`   ⚠️  ${w}`));
  console.log('');

  // Validate each pattern
  for (const pattern of catalog.patterns) {
    console.log(`Validating pattern: ${pattern.slug}`);
    
    const dirResult = validatePatternDirectory(pattern);
    const bicepResult = validateBicepFile(pattern);
    const talkTrackResult = validateTalkTrack(pattern);
    const paramsResult = validateParametersFile(pattern);

    const patternPassed = dirResult.passed && bicepResult.passed && 
                          talkTrackResult.passed && paramsResult.passed;

    if (patternPassed) {
      console.log(`✅ ${pattern.slug} - All checks passed`);
    } else {
      console.error(`❌ ${pattern.slug} - Validation failed:`);
      [...dirResult.errors, ...bicepResult.errors, ...talkTrackResult.errors, ...paramsResult.errors]
        .forEach(e => console.error(`   - ${e}`));
      allPassed = false;
    }

    const allWarnings = [...dirResult.warnings, ...bicepResult.warnings, 
                         ...talkTrackResult.warnings, ...paramsResult.warnings];
    allWarnings.forEach(w => console.warn(`   ⚠️  ${w}`));

    totalErrors += dirResult.errors.length + bicepResult.errors.length + 
                   talkTrackResult.errors.length + paramsResult.errors.length;
    totalWarnings += allWarnings.length;

    console.log('');
  }

  // Check for orphaned directories
  console.log('Checking for orphaned directories...');
  const orphanResult = checkOrphanedDirectories(catalog);
  orphanResult.warnings.forEach(w => console.warn(`⚠️  ${w}`));
  totalWarnings += orphanResult.warnings.length;
  console.log('');

  // Summary
  console.log('═'.repeat(60));
  console.log('Validation Summary:');
  console.log(`Total Errors: ${totalErrors}`);
  console.log(`Total Warnings: ${totalWarnings}`);
  console.log('═'.repeat(60));

  if (allPassed && totalErrors === 0) {
    console.log('\n✅ All validations passed!');
    process.exit(0);
  } else {
    console.log('\n❌ Validation failed. Please fix the errors above.');
    process.exit(1);
  }
}

main();
