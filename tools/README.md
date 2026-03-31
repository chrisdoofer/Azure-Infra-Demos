# Pattern Management Tools

This directory contains automation tools for managing Azure infrastructure demo patterns.

## Tools

### catalog-builder.ts

Interactive CLI for creating and managing pattern catalog entries.

**Commands:**

```bash
# Create a new pattern (interactive wizard)
npm run catalog create

# List all patterns with status
npm run catalog list

# Validate pattern directories
npm run catalog validate
```

**Features:**
- Interactive prompts for pattern metadata
- Automatic directory scaffolding from template
- Pattern registration in catalog JSON
- Slug generation from pattern names

### validate-patterns.ts

Comprehensive validation for pattern integrity and compliance.

**Usage:**

```bash
npm run validate
```

**Validation Checks:**
1. **Catalog Schema**: Validates patterns.json structure and required fields
2. **Pattern Directories**: Ensures all required files exist
3. **Bicep Parameters**: Verifies required parameters (location, prefix, tags)
4. **Talk Track Sections**: Confirms all 15 required sections present
5. **Parameter Files**: Validates JSON schema and structure
6. **Orphaned Directories**: Detects directories not registered in catalog

**Exit Codes:**
- `0`: All validations passed
- `1`: Validation errors found

## Setup

```bash
# Install dependencies
npm install

# Run validation
npm run validate

# List patterns
npm run catalog list
```

## Pattern Creation Workflow

1. **Run catalog builder:**
   ```bash
   npm run catalog create
   ```

2. **Answer prompts:**
   - Pattern name
   - Category (reference-architecture, solution-idea, quickstart)
   - Services (comma-separated)
   - Cost band (low, medium, high)
   - Complexity (beginner, intermediate, advanced)
   - Source URL
   - Summary

3. **Scaffold generated:**
   - `/patterns/{slug}/main.bicep`
   - `/patterns/{slug}/README.md`
   - `/patterns/{slug}/talk-track.md`
   - `/patterns/{slug}/architecture.mmd`
   - `/patterns/{slug}/parameters/dev.parameters.json`

4. **Customize pattern:**
   - Add Bicep resources to main.bicep
   - Update README with deployment instructions
   - Complete talk track sections
   - Draw architecture diagram in Mermaid

5. **Validate:**
   ```bash
   npm run validate
   ```

6. **Update status:**
   - Edit `patterns/catalog/patterns.json`
   - Change status from "scaffold" → "in-progress" → "complete"

## Required Files Per Pattern

Each pattern must have:
- ✅ `main.bicep` - Infrastructure as Code
- ✅ `README.md` - Pattern documentation
- ✅ `talk-track.md` - Presentation guide (15 sections)
- ✅ `architecture.mmd` - Mermaid diagram
- ✅ `parameters/dev.parameters.json` - Parameter file

## Catalog Schema

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-03-31T00:00:00Z",
  "patterns": [
    {
      "slug": "pattern-name",
      "name": "Human-Readable Name",
      "category": "reference-architecture|solution-idea|quickstart",
      "services": ["Service 1", "Service 2"],
      "costBand": "low|medium|high",
      "complexity": "beginner|intermediate|advanced",
      "sourceUrl": "https://learn.microsoft.com/...",
      "summary": "Brief description",
      "status": "scaffold|in-progress|complete"
    }
  ]
}
```

## Dependencies

- **tsx**: TypeScript execution without build step
- **typescript**: Type checking and language features
- **Node.js**: Runtime environment (v18+ recommended)

## Maintenance

### Adding a New Pattern

Use `npm run catalog create` instead of manual creation.

### Updating Template

Edit files in `/patterns/_template/` to change default scaffolding.

### Modifying Validation Rules

Edit `validate-patterns.ts` to add/remove validation checks.

## Troubleshooting

**"Pattern already exists"**
- Check `patterns/catalog/patterns.json` for duplicate slugs
- Delete existing directory if recreating

**"Validation failed"**
- Run `npm run validate` to see specific errors
- Fix missing files or required parameters
- Ensure all talk-track sections present

**"Module not found"**
- Run `npm install` to install dependencies
- Ensure you're in the `/tools` directory

## Contributing

1. Make changes to tools
2. Test with existing patterns
3. Update this README if adding new features
4. Document validation rules
