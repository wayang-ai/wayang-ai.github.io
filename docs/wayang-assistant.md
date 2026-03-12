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
- **Troubleshoot Errors**: Submit error messages and receive step-by-step fixes with references using the internal knowledge base.
- **Interactive Chat**: Maintain stateful conversations with session support.

---

## API Endpoints

Base path: `/api/v1/assistant`

### Interactive Chat (Recommended)

Wayang Assistant supports stateful chat sessions with history and document retrieval (RAG).

```bash
curl -X POST http://localhost:31713/api/v1/assistant/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "user-session-123",
    "message": "How do I build a RAG workflow in Wayang?"
  }'
```

The response includes:
- `reply`: The assistant's text response.
- `relevantDocs`: A list of referenced documents with score, title, and URL.
- `history`: Previous conversation turns.

### Ask a question (Stateless)

```bash
curl -X POST http://localhost:31713/api/v1/assistant/ask \
  -H 'Content-Type: application/json' \
  -d '{
    "question": "How does WayangSpec relate to WorkflowSpec?"
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

Wayang Assistant is optimized for internal usage with high-performance local inference.

Add or override in `application.properties`:

```properties
# Default Model Configuration
gollek.models.default-model=Qwen/Qwen2.5-0.5B-Instruct
gollek.models.default-provider=gguf
gollek.models.auto-download-enabled=true

# Assistant Parameters
wayang.assistant.max-doc-results=10
wayang.assistant.max-web-results=5
```

### Local Model Weights
By default, the assistant will automatically download weights from Hugging Face if not found in the local cache (`~/.wayang/models` or as configured).

---

## Runtime Support

The Wayang Assistant and its underlying inference engine (Gollek) are built for **Java 25** and **Quarkus 3.32.2+**, ensuring compatibility with modern JVM features.

---

## Notes

- The assistant relies on official docs (`wayang.github.io`) and local source code metadata for authoritative answers.
- For air-gapped deployments, pre-load the model weights and disable auto-download (`gollek.models.auto-download-enabled=false`).

---

## Related

- [Schema Catalog and WayangSpec](./schema-catalog)
- [Projects API](./projects-api)
- [Standalone Troubleshooting](./standalone-troubleshooting)
