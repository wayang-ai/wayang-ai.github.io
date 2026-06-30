---
layout: default
title: Executor Integrations
---

# Executor Integrations

Wayang provides a powerful executor system with seamless integration between Vector, Graph, Memory, RAG, and Gollek Multimodal components.

---

## Overview

The Executor Integration system enables unified retrieval and storage across multiple backends:

- **Vector Executor**: Semantic similarity search using embeddings
- **Graph Executor**: Relationship-based reasoning and traversal
- **Memory Executor**: Multi-level memory (working, episodic, semantic, long-term)
- **RAG Executor**: Retrieval-Augmented Generation with hybrid retrieval
- **Gollek Multimodal**: GPU-accelerated inference with streaming support

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Wayang Executor Platform                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │     RAG      │  │   Memory     │  │    Vector    │  │
│  │   Executor   │  │   Executor   │  │   Executor   │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │           │
│         └─────────────────┼─────────────────┘           │
│                           │                              │
│         ┌─────────────────┼─────────────────┐           │
│         │                 │                 │           │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐     │
│  │   Vector    │  │   Graph     │  │   Gollek    │     │
│  │  Adapter    │  │  Adapter    │  │  Multimodal │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Executor Types

### Vector Executor

Semantic similarity search using vector embeddings.

**Best For:**
- Finding similar content by meaning
- Question answering from documents
- Semantic deduplication
- Content recommendation

**Supported Backends:**
- In-Memory (development/testing)
- FAISS (high-performance)
- PGVector (PostgreSQL integration)
- Milvus (large-scale)
- Qdrant (feature-rich)

**Example:**
```java
@Inject
VectorStore vectorStore;

// Search by similarity
VectorQuery query = VectorQuery.builder()
    .query("What is machine learning?")
    .topK(5)
    .threshold(0.7)
    .build();

List<VectorEntry> results = vectorStore.search(query);
```

[Learn more](executors/vector)

---

### Graph Executor

Relationship-based storage and multi-hop reasoning.

**Best For:**
- Knowledge graphs
- Concept relationships
- Multi-hop reasoning
- Structured knowledge
- Citation networks

**Supported Backends:**
- In-Memory (development/testing)
- Neo4j (production graph database)

**Example:**
```java
@Inject
GraphStore graphStore;

// Find related concepts
List<Relationship> relationships = graphStore.getRelationships(
    nodeId,
    GraphStore.Direction.OUTGOING
);

// Multi-hop path finding
List<List<Node>> paths = graphStore.findPaths(
    startNodeId,
    endNodeId,
    3  // max hops
);
```

[Learn more](executors/graph)

---

### Memory Executor

Multi-level memory system for AI agents.

**Memory Types:**
- **Working Memory**: Current context and task state
- **Episodic Memory**: Conversation history and experiences
- **Semantic Memory**: Facts and knowledge
- **Long-term Memory**: Persistent knowledge storage

**Example:**
```java
@Inject
SemanticMemoryExecutor semanticMemory;

// Store semantic memory
Memory memory = Memory.builder()
    .type(MemoryType.SEMANTIC)
    .content("Machine learning is a subset of AI")
    .build();

semanticMemory.store(memory);

// Search by similarity
List<Memory> results = semanticMemory.search(
    "What is ML?",
    5,
    0.7
);
```

[Learn more](executors/memory)

---

### RAG Executor

Retrieval-Augmented Generation with hybrid retrieval capabilities.

**Features:**
- Dense retrieval (vector-based)
- Sparse retrieval (keyword-based)
- Hybrid retrieval (combined)
- Multi-hop reasoning (graph-based)
- Memory-augmented retrieval

**Example:**
```java
@Inject
RetrievalExecutor ragRetriever;

// Retrieve relevant context
RagQuery query = RagQuery.builder()
    .query("How do transformers work?")
    .topK(5)
    .strategy(SearchStrategy.HYBRID)
    .build();

RagResult result = ragRetriever.retrieve(query);
```

[Learn more](executors/rag)

---

## Integration Patterns

### Pattern 1: Vector-Memory Integration

Use vector store for semantic memory retrieval:

```java
@Inject
VectorMemoryAdapter vectorMemory;

// Store memories with embeddings
vectorMemory.storeMemories(memories);

// Search by similarity
List<Memory> similar = vectorMemory.searchSimilarMemories(
    query,
    5  // topK
);
```

**Use Case:** Semantic memory with fast similarity search

[View Guide](executors/vector-memory-integration)

---

### Pattern 2: Graph-Memory Integration

Use graph for relationship-based memory:

```java
@Inject
GraphMemoryAdapter graphMemory;

// Store memory as node
String nodeId = graphMemory.storeMemory(memory);

// Find related memories
List<Memory> related = graphMemory.findRelatedMemories(
    nodeId,
    "RELATED_TO",
    2  // hops
);
```

**Use Case:** Knowledge graphs and concept relationships

[View Guide](executors/graph-memory-integration)

---

### Pattern 3: RAG-Memory Integration

Combine RAG retrieval with memory:

```java
@Inject
RagMemoryIntegration ragMemory;

// Retrieve from both RAG and memory
RagResult result = ragMemory.retrieveWithMemory(
    query,
    5,  // RAG topK
    5   // Memory topK
);
```

**Use Case:** Memory-augmented RAG for comprehensive answers

[View Guide](executors/rag-memory-integration)

---

### Pattern 4: RAG-Graph Integration

Multi-hop reasoning for RAG:

```java
@Inject
RagGraphIntegration ragGraph;

// Hybrid retrieval (vector + graph)
RagResult result = ragGraph.retrieveHybrid(
    query,
    5,  // vector topK
    2   // graph hops
);
```

**Use Case:** Research assistants, knowledge base navigation

[View Guide](executors/rag-graph-integration)

---

## Vector vs Graph Comparison

| Feature | Vector | Graph |
|---------|--------|-------|
| **Primary Strength** | Semantic similarity | Relationship traversal |
| **Query Type** | "Find similar to X" | "Find connected to X" |
| **Data Model** | Embeddings (vectors) | Nodes + Relationships |
| **Best For** | Semantic search | Multi-hop reasoning |
| **Scalability** | Millions of vectors | Millions of relationships |
| **Latency** | O(log n) for ANN | O(1) for direct connections |
| **Explainability** | ⭐⭐ | ⭐⭐⭐⭐⭐ |

### When to Use Each

| Scenario | Choose | Why |
|----------|--------|-----|
| Customer Support QA | Vector | Semantic similarity |
| Knowledge Graph | Graph | Explicit relationships |
| Research Assistant | Hybrid | Papers + citations |
| Educational Content | Graph | Concept relationships |
| Document Search | Vector | Meaning-based |
| Navigation | Graph | Structure traversal |

[Detailed Comparison](executors/graph-vs-vector)

---

## Configuration

### Vector Store Configuration

```properties
# Vector store type
wayang.vector.store.type=pgvector

# PGVector configuration
wayang.vector.store.pgvector.url=jdbc:postgresql://localhost:5432/wayang
wayang.vector.store.pgvector.username=wayang
wayang.vector.store.pgvector.password=secret

# Search settings
wayang.vector.similarity-threshold=0.7
wayang.vector.top-k=5
```

### Graph Store Configuration

```properties
# Graph store type
wayang.graph.store.type=neo4j

# Neo4j configuration
wayang.graph.store.neo4j.uri=bolt://localhost:7687
wayang.graph.store.neo4j.username=neo4j
wayang.graph.store.neo4j.password=password
```

### Memory Configuration

```properties
# Enable memory types
wayang.memory.semantic.enabled=true
wayang.memory.episodic.enabled=true
wayang.memory.working.enabled=true
wayang.memory.longterm.enabled=true

# Vector integration
wayang.memory.vector.integration.enabled=true
wayang.memory.vector.similarity-threshold=0.7
```

### RAG Configuration

```properties
# RAG settings
wayang.rag.enabled=true
wayang.rag.retrieval.top-k=5
wayang.rag.retrieval.threshold=0.7
wayang.rag.generation.model=llama-3.2-3b

# Integration settings
wayang.rag.memory.integration.enabled=true
wayang.rag.memory.weight=0.5
```

---

## Performance Considerations

### Vector Performance

| Store Type | Scale | Latency | Best For |
|------------|-------|---------|----------|
| In-Memory | <10K | <1ms | Development |
| FAISS | >1M | <10ms | Production |
| PGVector | >100K | <50ms | PostgreSQL deployments |
| Milvus | >10M | <20ms | Large-scale |
| Qdrant | >1M | <15ms | Feature-rich |

### Graph Performance

| Store Type | Scale | Latency | Best For |
|------------|-------|---------|----------|
| In-Memory | <100K | <1ms | Development |
| Neo4j | >10M | <50ms | Production |

### Hybrid Performance

For hybrid retrieval (vector + graph):
- **Vector first, then graph expansion**: Fast initial retrieval
- **Parallel retrieval**: Best latency
- **Weighted combination**: Balance precision/recall

---

## Best Practices

1. **Choose the Right Backend**
   - Vector for semantic search
   - Graph for relationships
   - Hybrid for comprehensive retrieval

2. **Tune Similarity Thresholds**
   - Start with 0.7 for vector similarity
   - Adjust based on use case

3. **Implement Caching**
   - Cache frequent queries
   - Use response caching for RAG

4. **Monitor Performance**
   - Track retrieval latency
   - Monitor memory usage
   - Set up alerts

5. **Use Appropriate TopK**
   - Vector: 5-10 for most cases
   - Graph: 2-3 hops maximum
   - Hybrid: Balance between sources

---

## Troubleshooting

### Low Similarity Scores

**Problem**: Retrieved results have low similarity

**Solutions**:
- Lower similarity threshold (default: 0.7)
- Use better embedding models
- Increase topK parameter

### Slow Graph Traversal

**Problem**: Multi-hop queries are slow

**Solutions**:
- Limit max hops to 2-3
- Add indexes on relationship types
- Use path constraints

### Memory Overload

**Problem**: Too much context for generation

**Solutions**:
- Reduce topK
- Use summarization
- Implement context compression

---

## Gollek Multimodal Executor

GPU-accelerated multimodal inference with streaming support.

**Best For:**
- High-performance text inference
- Real-time streaming responses
- Vision-language processing
- Batch processing

**Supported Backends:**
- GGUF/llama.cpp (CPU/GPU)
- ONNX Runtime (CPU/GPU)
- NVIDIA CUDA (A100, H100, RTX)
- Apple Metal (M1, M2, M3)

**Performance:**
- Throughput: 300 req/s (GPU)
- P95 Latency: <2000ms
- Time to First Token: <500ms
- Memory Allocation: 0.5ms (10x improvement)

**Example:**
```java
@Inject
GollekIntegrationService gollekIntegration;

// Text inference
Uni<String> response = gollekIntegration.executeTextInference(
    "llama-3.2-3b-instruct",
    "Explain quantum computing",
    config
);

// Streaming
Multi<String> stream = gollekIntegration.executeStreamingInference(
    "llama-3.2-3b-instruct",
    "Tell me a story",
    config
);

// Multimodal (Vision)
Uni<String> vision = gollekIntegration.executeMultimodalInference(
    "llava-13b-gguf",
    "What's in this image?",
    imageData,
    config
);
```

**Monitoring:**
- 20+ metrics exposed
- Health checks (UP/DEGRADED/DOWN)
- 9 alert types
- Prometheus + Grafana integration

[Learn more](./gollek-integration)

---

## Resources

- [Vector Executor Documentation](executors/vector)
- [Graph Executor Documentation](executors/graph)
- [Memory Documentation](executors/memory)
- [RAG Documentation](executors/rag)
- **[Gollek Multimodal Documentation](gollek-integration)**
- [Vector-Memory Integration Guide](executors/vector-memory-integration)
- [Graph-Memory Integration Guide](executors/graph-memory-integration)
- [RAG Integration Guide](executors/rag-integration)
- [Gollek-Wayang Integration Guide](GOLLEK_WAYANG_INTEGRATION_GUIDE.md)

---

## Enhancement History

- **[Phase 1: Integration Testing](/docs/phase1-completion)** - 41 tests created
- **[Phase 2: Performance Optimization](/docs/phase2-completion)** - 3x throughput improvement
- **[Phase 3: Production Hardening](/docs/phase3-completion)** - Complete monitoring
- **[Phase 4: Production Deployment](/docs/phase4-completion)** - Production ready
- **[Complete Enhancement History](/docs/enhancement-history)** - All phases

---

[Back to Documentation](/docs/) &nbsp; [View Executors](executors/)
