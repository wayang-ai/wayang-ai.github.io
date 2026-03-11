---
layout: default
title: Wayang Assistant
---

# Wayang Assistant

Wayang Assistant is an AI-powered helper for building Wayang projects, answering questions about Wayang, and troubleshooting errors. It uses the official documentation and optional web search to provide up-to-date guidance.

---

## What It Does

- **Ask About Wayang**: Get answers on capabilities, architecture, schemas, and usage.
- **Generate Projects**: Describe intent in natural language and receive a ready-to-use Wayang project structure.
- **Troubleshoot Errors**: Submit error messages and receive step-by-step fixes with references.

---

## API Endpoints

Base path: `/api/v1/assistant`

### Ask a question

```bash
curl -X POST http://localhost:31713/api/v1/assistant/ask \
  -H 'Content-Type: application/json' \
  -d '{
    "question": "How does WayangSpec relate to WorkflowSpec?"
  }'
```

### Generate a project

```bash
curl -X POST http://localhost:31713/api/v1/assistant/generate-project \
  -H 'Content-Type: application/json' \
  -d '{
    "intent": "Build a customer support workflow with a router and human approval"
  }'
```

### Troubleshoot an error

```bash
curl -X POST http://localhost:31713/api/v1/assistant/troubleshoot \
  -H 'Content-Type: application/json' \
  -d '{
    "errorMessage": "Unsatisfied dependency for type ControlPlaneExecutorRegistry"
  }'
```

### Capabilities

```bash
curl http://localhost:31713/api/v1/assistant/capabilities
```

---

## Configuration

Add or override in `application.properties`:

```properties
wayang.assistant.max-doc-results=10
wayang.assistant.max-web-results=5
wayang.assistant.default-provider=tech.kayys/anthropic-provider
wayang.assistant.fallback-provider=tech.kayys/openai-provider
```

---

## Notes

- The assistant relies on official docs (`wayang.github.io`) for authoritative answers.
- For enterprise deployments, restrict assistant access to internal docs and disable external web search if needed.

---

## Related

- [Schema Catalog and WayangSpec](./schema-catalog)
- [Projects API](./projects-api)
- [Standalone Troubleshooting](./standalone-troubleshooting)
