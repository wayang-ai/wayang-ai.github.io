---
layout: default
title: Vector Executor
---

# Vector Executor

Semantic similarity search using vector embeddings for AI agent memory and RAG.

---

## Overview

The Vector Executor provides dense retrieval capabilities using vector embeddings, enabling semantic search across memories, documents, and knowledge bases.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Vector Executor                        │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Embedding   │  │   Vector     │  │   Similarity │  │
│  │  Generator   │  │   Index      │  │   Search     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   Vector Stores                          │
├──────────────┬──────────────┬──────────────┬───────────┤
│  In-Memory   │    FAISS     │   PGVector   │  Milvus   │
└──────────────┴──────────────┴──────────────┴───────────┘
```

---

## Supported Backends

### In-Memory Vector Store

**Best For:** Development, testing, small datasets (<10K entries)

```properties
wayang.vector.store.type=inmemory
```

**Features:**
- Fast setup, no external dependencies
- O(n) search complexity
- Thread-safe implementation

---

### FAISS Vector Store

**Best For:** High-performance production (>1M entries)

```properties
wayang.vector.store.type=faiss
wayang.vector.store.faiss.index-type=HNSW
wayang.vector.store.faiss.dimension=768
```

**Features:**
- Approximate Nearest Neighbor search
- O(log n) complexity
- GPU acceleration support

---

### PGVector Store

**Best For:** PostgreSQL deployments (>100K entries)

```properties
wayang.vector.store.type=pgvector
wayang.vector.store.pgvector.url=jdbc:postgresql://localhost:5432/wayang
wayang.vector.store.pgvector.username=wayang
wayang.vector.store.pgvector.password=secret
```

**Features:**
- Integrated with PostgreSQL
- SQL + vector queries
- ACID compliance

---

### Milvus Vector Store

**Best For:** Large-scale deployments (>10M entries)

```properties
wayang.vector.store.type=milvus
wayang.vector.store.milvus.uri=http://localhost:19530
```

**Features:**
- Distributed architecture
- Horizontal scaling
- Multi-modal support

---

### Qdrant Vector Store

**Best For:** Feature-rich production deployments

```properties
wayang.vector.store.type=qdrant
wayang.vector.store.qdrant.url=http://localhost:6333
```

**Features:**
- Rich filtering
- Payload support
- REST API

---

## Usage Examples

### Basic Vector Search

```java
@Inject
VectorStore vectorStore;

// Create query
VectorQuery query = VectorQuery.builder()
    .query("What is machine learning?")
    .topK(5)
    .threshold(0.7)
    .build();

// Search
List<VectorEntry> results = vectorStore.search(query);

results.forEach(entry -> {
    System.out.println("Content: " + entry.getContent());
    System.out.println("Score: " + entry.getScore());
});
```

---

### Store Entries

```java
// Create entries
List<VectorEntry> entries = List.of(
    VectorEntry.builder()
        .id("doc-1")
        .content("Machine learning is a subset of AI")
        .metadata(Map.of("source", "wiki", "topic", "AI"))
        .build(),
    VectorEntry.builder()
        .id("doc-2")
        .content("Neural networks use layers of neurons")
        .metadata(Map.of("source", "wiki", "topic", "ML"))
        .build()
);

// Store
vectorStore.store(entries);
```

---

### Search with Filters

```java
VectorQuery query = VectorQuery.builder()
    .query("neural networks")
    .topK(5)
    .build();

Map<String, Object> filters = Map.of(
    "topic", "ML",
    "source", "wiki"
);

List<VectorEntry> results = vectorStore.search(query, filters);
```

---

### Delete Entries

```java
// Delete by IDs
vectorStore.delete(List.of("doc-1", "doc-2"));

// Delete by filters
Map<String, Object> filters = Map.of("topic", "obsolete");
vectorStore.deleteByFilters(filters);
```

---

## Configuration Reference

### General Settings

| Property | Default | Description |
|----------|---------|-------------|
| `wayang.vector.store.type` | `inmemory` | Vector store backend |
| `wayang.vector.similarity-threshold` | `0.7` | Minimum similarity score |
| `wayang.vector.top-k` | `5` | Default number of results |

### PGVector Settings

| Property | Default | Description |
|----------|---------|-------------|
| `wayang.vector.store.pgvector.url` | - | PostgreSQL JDBC URL |
| `wayang.vector.store.pgvector.username` | - | Database username |
| `wayang.vector.store.pgvector.password` | - | Database password |
| `wayang.vector.store.pgvector.table` | `vectors` | Vector table name |

### FAISS Settings

| Property | Default | Description |
|----------|---------|-------------|
| `wayang.vector.store.faiss.index-type` | `HNSW` | Index type (HNSW, IVF, etc.) |
| `wayang.vector.store.faiss.dimension` | `768` | Embedding dimension |
| `wayang.vector.store.faiss.metric` | `cosine` | Distance metric |

---

## Performance Optimization

### Indexing Strategies

**For Small Datasets (<10K):**
- Use In-Memory store
- No index needed

**For Medium Datasets (10K-1M):**
- Use PGVector with HNSW index
- Set `ef_search = 64`

**For Large Datasets (>1M):**
- Use FAISS with IVF index
- Set nprobe = 10-20

### Batch Operations

```java
// Batch store (recommended)
List<VectorEntry> entries = getEntries(); // 100-1000 entries
vectorStore.store(entries);

// Batch delete
List<String> ids = getIdsToDelete();
vectorStore.delete(ids);
```

### Caching

```java
@Inject
ResponseCacheService cache;

public List<VectorEntry> searchWithCache(String query) {
    // Check cache
    Optional<List<VectorEntry>> cached = cache.get(query);
    if (cached.isPresent()) {
        return cached.get();
    }
    
    // Search and cache
    VectorQuery vectorQuery = VectorQuery.builder()
        .query(query)
        .topK(5)
        .build();
    
    List<VectorEntry> results = vectorStore.search(vectorQuery);
    cache.put(query, results);
    
    return results;
}
```

---

## Integration with Memory

See [Vector-Memory Integration](vector-memory-integration) for storing memories as vectors.

```java
@Inject
VectorMemoryAdapter vectorMemory;

// Store memories with embeddings
vectorMemory.storeMemories(memories);

// Search memories by similarity
List<Memory> results = vectorMemory.searchSimilarMemories(query, 5);
```

---

## Integration with RAG

See [RAG Integration](rag) for using vector store in RAG pipelines.

```java
@Inject
RetrievalExecutor ragRetriever;

// Vector-based retrieval
RagQuery query = RagQuery.builder()
    .query("How do transformers work?")
    .topK(5)
    .strategy(SearchStrategy.DENSE)
    .build();

RagResult result = ragRetriever.retrieve(query);
```

---

## Troubleshooting

### Low Similarity Scores

**Problem**: All results have scores < 0.5

**Solutions**:
1. Lower threshold: `wayang.vector.similarity-threshold=0.5`
2. Check embedding model consistency
3. Verify query is well-formed

### Slow Search Performance

**Problem**: Search takes >100ms

**Solutions**:
1. Use appropriate index (HNSW for large datasets)
2. Reduce topK parameter
3. Add metadata filters to reduce search space
4. Consider FAISS for >100K entries

### Out of Memory

**Problem**: In-memory store consumes too much RAM

**Solutions**:
1. Switch to PGVector or FAISS
2. Implement pagination
3. Use disk-based storage

---

## Resources

- [Executor Integrations Overview](executor-integrations)
- [Vector-Memory Integration](vector-memory-integration)
- [RAG Documentation](rag)
- [FAISS Documentation](https://faiss.ai/)
- [PGVector Documentation](https://github.com/pgvector/pgvector)

---

[Back to Executors](executors/) &nbsp; [Graph Executor](graph)
