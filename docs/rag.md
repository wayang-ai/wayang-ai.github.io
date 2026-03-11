---
layout: default
title: RAG API
---

# RAG API (Standalone)

RAG execution is exposed through the project execution API by running a workflow/spec that includes a `rag-executor` node.

Execute a RAG query via project execution:

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/executions" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: community" \
  -d '{
    "name": "rag-query-run",
    "spec": {
      "workflow": {
        "name": "rag-query-workflow",
        "nodes": [
          {
            "id": "rag_1",
            "type": "rag-executor",
            "configuration": {
              "tenantId": "community",
              "query": "What is Wayang?",
              "collection": "knowledge",
              "topK": 5,
              "minSimilarity": 0.6,
              "temperature": 0.2,
              "maxTokens": 512
            }
          }
        ]
      }
    }
  }'
```

Expected RAG node output fields:

```json
{
  "success": true,
  "tenantId": "community",
  "query": "What is Wayang?",
  "answer": "...",
  "sources": [],
  "citations": [],
  "sourceDocuments": [],
  "metadata": {},
  "timestamp": "2026-03-05T16:20:00Z",
  "durationMs": 123,
  "retrievedDocs": 4,
  "tokensGenerated": 90
}
```

If `tenantId` or `collection` is omitted, runtime defaults are used (`default-tenant` and `default`).

## Embedding Providers

Wayang AI defaults to **Gollek** for local embedding generation using GGUF models.

Supported embedding providers:
- **Gollek** (default): High-performance local embedding using GGUF. Default model: `Qwen/Qwen2.5-0.5B-Instruct`.
- **OpenAI**: Hosted embeddings via OpenAI API.
- **HuggingFace**: Remote embeddings via HuggingFace Inference API.

Configure the embedding provider in your properties file:
```properties
wayang.embedding.provider=gollek
wayang.embedding.model=Qwen/Qwen2.5-0.5B-Instruct
```

## Built-In Vector Stores

Wayang AI natively supports **FAISS** out-of-the-box as its default vector search backend, utilizing the JDK 25 Foreign Function & Memory (FFM) API for maximum performance without external dependencies. 

Other supported vector stores:
- **FAISS** (default): High-performance C++ backend.
- **In-Memory**: Standard Java-based exact vector search (dev/testing).
- **PGVector**: PostgreSQL extension for production workloads.
- **Pinecone**, **Chroma**, **Qdrant**, **Milvus**: Supported via standard configuration options.

Configure the backend in your properties file:
```properties
wayang.vector.store.type=faiss
```

## Admin Endpoint

RAG plugin admin status endpoint:

```bash
curl -X GET "http://localhost:31713/admin/rag/plugins?tenantId=community" \
  -H "accept: application/json" \
  -H "x-admin-key: <your-admin-key>"
```

Required admin config keys:

```properties
rag.runtime.admin.api-key=<primary-key>
rag.runtime.admin.api-key-secondary=<optional-secondary-key>
```

## Troubleshooting

1. `success=false` with `Missing required field: query`
   - Ensure node config includes `query` (or fallback keys like `question`/`prompt`).
2. Low recall / weak retrieval quality
   - Tune `topK`, `minSimilarity`, and verify `collection`.
3. `401 Unauthorized` on `/admin/rag/plugins`
   - Check `x-admin-key`.
4. `403 Forbidden` on `/admin/rag/plugins`
   - Configure `rag.runtime.admin.api-key`.
