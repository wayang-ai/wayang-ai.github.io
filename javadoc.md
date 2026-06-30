---
layout: default
title: Javadoc API Reference
---

# Javadoc API Reference

Browse the complete Java API documentation for the Wayang AI Platform.

## Overview

The Javadoc documentation provides detailed API reference for all Wayang modules including:

- **Core APIs** - Project management, workflow definitions, and execution contracts
- **Control Plane** - Designer services, agent management, and audit logging
- **Executors** - Agent, EIP, embedding, guardrails, HITL, memory, RAG, and tool executors
- **Schema & Vault** - Schema registry and secure credential management
- **Plugin System** - Plugin SPI and registry interfaces

## Accessing the Javadoc

The Javadoc is generated as part of the Maven build process and is available as static HTML files.

### Online Documentation

Visit the [Javadoc Reference](/javadoc/index.html) to browse the API documentation online.

### Generate Locally

To generate the Javadoc locally:

```bash
cd wayang-platform/wayang
mvn javadoc:aggregate-no-fork -DskipTests -Dmaven.test.skip=true -Dcompiler.skipMainCompilation=true
```

Or use the convenience script:

```bash
cd website/wayang.github.io/javadoc
./generate-javadoc.sh
```

The generated Javadoc will be available in `website/wayang.github.io/javadoc/`.

## Key Packages

### Core Modules

| Module | Package | Description |
|--------|---------|-------------|
| wayang-project-api | `tech.kayys.wayang.project.api` | Project and workflow descriptors |
| wayang-api | `tech.kayys.wayang.control.api` | REST API resources |
| wayang-control-core | `tech.kayys.wayang.control` | Control plane services |
| wayang-schema-core | `tech.kayys.wayang.schema` | Schema registry and catalog |

### Executors

| Module | Package | Description |
|--------|---------|-------------|
| agent-executor | `tech.kayys.wayang.executor.agent` | Agent execution engine |
| eip-core | `tech.kayys.wayang.eip` | Enterprise integration patterns |
| guardrails-core | `tech.kayys.wayang.guardrail` | Input/output guardrails |
| hitl-core | `tech.kayys.wayang.hitl` | Human-in-the-loop execution |
| memory-core | `tech.kayys.wayang.memory` | Memory and context management |
| rag-core | `tech.kayys.wayang.rag` | Retrieval-augmented generation |
| tool-core | `tech.kayys.wayang.tool` | Tool execution and MCP |

## Troubleshooting

Having issues generating or viewing the Javadoc? See the [Javadoc Troubleshooting Guide](./javadoc-troubleshooting.html) for solutions to common problems.

### Quick Fixes

**Compilation errors:** Run `mvn clean install -DskipTests` first

**OutOfMemoryError:** Set `export MAVEN_OPTS="-Xmx4g"`

**404 in Jekyll:** Run `bundle exec jekyll clean` and rebuild

## Related Documentation

- [Projects API Guide](./projects-api.html)
- [Schema Catalog](./schema-catalog.html)
- [Agent Skills](./agent-skills.html)
- [RAG API](./rag.html)
- [MCP Integration](./mcp.html)
- [Javadoc Troubleshooting](./javadoc-troubleshooting.html)
