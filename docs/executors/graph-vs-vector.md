---
layout: default
title: Graph vs Vector
---

# Graph vs Vector for Memory and RAG

Choosing the right storage backend for your AI agent's memory and RAG system.

---

## Overview

Both Graph and Vector databases can serve as storage backends for Memory and RAG systems, but they excel at different use cases.

---

## Quick Comparison

| Feature | Vector Database | Graph Database |
|---------|-----------------|----------------|
| **Primary Strength** | Semantic similarity | Relationship traversal |
| **Query Type** | "Find similar to X" | "Find connected to X" |
| **Data Model** | Embeddings (vectors) | Nodes + Relationships |
| **Best For** | Semantic search | Multi-hop reasoning |
| **Scalability** | Millions of vectors | Millions of relationships |
| **Latency** | O(log n) for ANN | O(1) for direct connections |
| **Explainability** | ⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## When to Use Vector

### Semantic Memory Search

```java
// Find memories with similar meaning
List<Memory> similar = vectorMemory.searchSimilarMemories(
    "What is machine learning?",
    5
);
// Returns: Memories about ML, AI, neural networks, etc.
```

### RAG Document Retrieval

```java
// Find documents semantically similar to query
VectorQuery query = VectorQuery.builder()
    .query("How does transformer work?")
    .topK(5)
    .build();

List<VectorEntry> results = vectorStore.search(query);
// Returns: Documents about transformers, attention, BERT, etc.
```

**Best Use Cases:**
- Finding similar content by meaning
- Question answering from documents
- Semantic deduplication
- Content recommendation

[Learn more](vector)

---

## When to Use Graph

### Relationship-Based Memory

```java
// Find memories connected to a concept
Node concept = graphStore.getNode("machine-learning");
List<Relationship> relationships = graphStore.getRelationships(
    concept.getId(), 
    Direction.OUTGOING
);
// Returns: KNOWS_ABOUT, RELATED_TO, PREREQUISITE_OF relationships
```

### Multi-Hop RAG

```java
// Find information through relationship traversal
List<List<Node>> paths = graphStore.findPaths(
    "neural-networks",  // Start
    "backpropagation",  // End
    3                   // Max hops
);
// Returns: All connection paths between concepts
```

**Best Use Cases:**
- Knowledge graphs
- Concept relationships
- Multi-hop reasoning
- Structured knowledge
- Citation networks

[Learn more](graph)

---

## Hybrid Approach (Recommended)

Combine both for best results:

```java
// 1. Use vector for initial semantic search
List<Memory> semanticResults = vectorMemory.searchSimilarMemories(query, 10);

// 2. Use graph for relationship expansion
for (Memory memory : semanticResults) {
    Node node = graphStore.getNode(memory.getId());
    List<Relationship> related = graphStore.getRelationships(
        node.getId(), 
        Direction.OUTGOING
    );
    // Add related memories to results
}

// 3. Combine and rerank
List<Memory> combined = combineAndRerank(semanticResults, graphResults);
```

---

## Architecture Comparison

### Vector-Based Architecture

```
┌──────────────┐
│    Query     │
└──────┬───────┘
       │
┌──────▼───────┐
│  Embedding   │
│   Model      │
└──────┬───────┘
       │
┌──────▼───────┐
│ Vector Store │
│  (FAISS,     │
│   PGVector)  │
└──────┬───────┘
       │
┌──────▼───────┐
│   Similar    │
│   Documents  │
└──────────────┘
```

### Graph-Based Architecture

```
┌──────────────┐
│    Query     │
└──────┬───────┘
       │
┌──────▼───────┐
│  Entity      │
│  Extraction  │
└──────┬───────┘
       │
┌──────▼───────┐
│ Graph Store  │
│  (Neo4j,     │
│   Memgraph)  │
└──────┬───────┘
       │
┌──────▼───────┐
│  Connected   │
│  Knowledge   │
└──────────────┘
```

---

## Performance Comparison

| Operation | Vector | Graph |
|-----------|--------|-------|
| Semantic Search | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Relationship Query | ⭐ | ⭐⭐⭐⭐⭐ |
| Multi-Hop Traversal | ⭐ | ⭐⭐⭐⭐⭐ |
| Scalability | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Explainability | ⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## Use Case Examples

### Vector: Customer Support RAG

```java
// Customer asks: "How do I reset my password?"
VectorQuery query = VectorQuery.builder()
    .query("password reset")
    .topK(5)
    .build();

// Returns: Similar support articles about password reset
List<VectorEntry> articles = vectorStore.search(query);
```

### Graph: Knowledge Base Navigation

```java
// User explores: "Tell me about neural networks"
Node nn = graphStore.findNodesByProperty(
    "Concept", "name", "neural-networks"
).get(0);

// Get related concepts
List<Relationship> related = graphStore.getRelationships(
    nn.getId(),
    GraphStore.Direction.OUTGOING
);
// Returns: HAS_PART → layers, REQUIRES → backpropagation, etc.
```

### Hybrid: Research Assistant

```java
// 1. Vector: Find relevant papers
List<Paper> papers = vectorSearch("transformer architecture", 10);

// 2. Graph: Find citation network
for (Paper paper : papers) {
    List<Citation> citations = graphStore.getCitations(paper.getId());
    // Build citation graph
}

// 3. Combine for comprehensive answer
```

---

## Configuration

### Vector Configuration

```properties
# Vector store for semantic search
wayang.vector.store.type=pgvector
wayang.vector.store.pgvector.url=jdbc:postgresql://localhost:5432/wayang
wayang.vector.similarity-threshold=0.7
wayang.vector.top-k=5
```

### Graph Configuration

```properties
# Graph store for relationships
wayang.graph.store.type=neo4j
wayang.graph.store.neo4j.uri=bolt://localhost:7687
wayang.graph.store.neo4j.username=neo4j
wayang.graph.store.neo4j.password=password
```

### Hybrid Configuration

```properties
# Enable both
wayang.vector.store.enabled=true
wayang.graph.store.enabled=true

# Weight between vector and graph
wayang.hybrid.vector-weight=0.6
wayang.hybrid.graph-weight=0.4
```

---

## Decision Matrix

| Requirement | Choose | Why |
|-------------|--------|-----|
| "Find similar documents" | Vector | Semantic similarity |
| "Find related concepts" | Graph | Relationship traversal |
| "Show me the connection path" | Graph | Multi-hop reasoning |
| "Search by meaning" | Vector | Embedding-based |
| "Navigate knowledge structure" | Graph | Explicit relationships |
| "Answer questions from docs" | Vector | Semantic retrieval |
| "Reason about relationships" | Graph | Graph traversal |
| "Best of both worlds" | **Hybrid** ✓ | Comprehensive |

---

## Recommendations

### For Memory Systems

| Memory Type | Choose | Why |
|-------------|--------|-----|
| Semantic Memory | Vector | Similarity-based retrieval |
| Episodic Memory | Graph | Temporal/contextual links |
| Working Memory | Both | Fast access + relationships |
| Long-term Memory | Hybrid | Comprehensive storage |

### For RAG Systems

| Use Case | Choose | Why |
|----------|--------|-----|
| Document QA | Vector | Semantic retrieval |
| Knowledge Base | Graph | Structured knowledge |
| Research Assistant | Hybrid | Papers + citations |
| Customer Support | Vector | Similar questions |
| Educational | Graph | Concept relationships |

---

## Conclusion

**Vector** and **Graph** are complementary, not competing:

- **Vector** = Semantic understanding (meaning)
- **Graph** = Structural understanding (relationships)

**Best Practice:** Use both in a hybrid architecture for comprehensive retrieval!

---

## Resources

- [Vector Executor](vector)
- [Graph Executor](graph)
- [Executor Integrations](executor-integrations)
- [Vector-Memory Integration](vector-memory-integration)
- [Graph-Memory Integration](graph-memory-integration)

---

[Back to Executors](executors/) &nbsp; [Executor Integrations](executor-integrations)
