# Website Documentation Update - Sandbox Runtime

## Summary

Added comprehensive documentation for the new **Wayang Sandbox Runtime** to the website at `website/wayang.github.io`.

## Files Updated

### 1. New Documentation Page
- **`docs/sandbox-runtime.md`** - Complete Sandbox Runtime documentation
  - Overview and key benefits
  - Isolation strategies (ClassLoader, Container, WASM)
  - Security policies and levels
  - Resource quotas
  - REST API reference
  - Usage examples (Java, cURL, Python)
  - Multi-tenancy guide
  - Monitoring and observability
  - Configuration reference
  - Best practices
  - Troubleshooting

### 2. Documentation Index
- **`docs/index.md`** - Updated to include Sandbox Runtime
  - Added to "Executors & Integrations" section
  - Added to "Core Features" section

### 3. Features Page
- **`features/index.md`** - Updated platform features
  - Added "Sandbox Runtime" to Execution Engine features
  - Added "Sandbox Execution" to Platform Features table
  - Added "Multi-Tenancy" to Platform Features table

## Documentation Structure

The Sandbox Runtime documentation follows the same structure as other Wayang docs:

```markdown
---
layout: default
title: Sandbox Runtime
---

# Sandbox Runtime

## Overview
## Isolation Strategies
## Security Policies
## Resource Quotas
## REST API
## Usage Examples
## Multi-Tenancy
## Monitoring & Observability
## Configuration Reference
## Best Practices
## Integration with Wayang Platform
## Troubleshooting
## Additional Resources
```

## Key Topics Covered

### Isolation Strategies
- ClassLoader Isolation (default, lightweight)
- Container Isolation (Docker, strong security)
- WASM Isolation (optional, portable)

### Security Features
- 4 security levels (MINIMAL to MAXIMUM)
- File system access control
- Network access control
- System call restrictions
- Custom SecurityManager

### Resource Management
- CPU quotas (millicores)
- Memory limits (MB)
- Disk quotas (MB)
- Thread limits
- File descriptor limits
- Execution timeouts
- Network bandwidth control

### REST API
Complete HTTP API with endpoints for:
- System health monitoring
- Provider management
- Sandbox lifecycle (create, terminate, pause, resume)
- Workflow execution
- Metrics and monitoring

### Multi-Tenancy
- Tenant-scoped sandboxes
- Isolated execution per tenant
- Tenant-based resource tracking
- Cleanup utilities

## Integration Points

The documentation links to:
- GitHub source code
- Module README.md
- QUICKSTART.md
- INTEGRATION_GUIDE.md
- MODULE_SUMMARY.md

## Next Steps

Consider adding:
1. Tutorial video or screencast
2. Interactive API examples (Swagger/OpenAPI)
3. More integration examples with popular frameworks
4. Performance benchmarking data
5. Case studies from production deployments

## Related Files

The actual implementation is at:
- `wayang/runtime/wayang-sandbox-runtime/` - Module source code
- `wayang/pom.xml` - Updated to include sandbox module

## Testing

To verify the documentation:

1. Start the Jekyll server:
   ```bash
   cd website/wayang.github.io
   ./start-server.sh
   ```

2. Navigate to:
   - http://localhost:4000/docs/sandbox-runtime
   - http://localhost:4000/docs/
   - http://localhost:4000/features/

3. Verify all links work correctly
4. Check formatting and code block rendering

## Build & Deploy

The website uses Jekyll and is hosted on GitHub Pages.

```bash
# Build locally
cd website/wayang.github.io
bundle install
bundle exec jekyll build

# The built site is in _site/ directory
# Push to main branch to deploy to GitHub Pages
```
