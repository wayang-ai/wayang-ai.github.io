---
layout: default
title: Graph Executor
---

# Graph Executor

Relationship-based storage and multi-hop reasoning for AI agent knowledge graphs.

---

## Overview

The Graph Executor provides graph-based storage as an alternative (and complement) to vector storage, enabling:
- Knowledge graph storage and querying
- Relationship-based reasoning
- Multi-hop traversal
- Structured data representation

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Graph Executor                         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │     Node     │  │  Relationship│  │    Path      │  │
│  │   Manager    │  │   Manager    │  │   Finder     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   Graph Stores                           │
├───────────────────────────┬─────────────────────────────┤
│      In-Memory            │         Neo4j               │
│   (Development)           │      (Production)           │
└───────────────────────────┴─────────────────────────────┘
```

---

## Supported Backends

### In-Memory Graph Store

**Best For:** Development, testing, small graphs (<100K nodes)

```properties
wayang.graph.store.type=inmemory
```

**Features:**
- Fast setup, no external dependencies
- Thread-safe using ConcurrentHashMap
- O(1) node/relationship lookups

---

### Neo4j Graph Store

**Best For:** Production knowledge graphs (>1M nodes)

```properties
wayang.graph.store.type=neo4j
wayang.graph.store.neo4j.uri=bolt://localhost:7687
wayang.graph.store.neo4j.username=neo4j
wayang.graph.store.neo4j.password=password
wayang.graph.store.neo4j.database=neo4j
```

**Features:**
- Cypher query language support
- ACID compliance
- Horizontal scaling with Neo4j Fabric
- Graph algorithms library

---

## Core Concepts

### Nodes

Nodes represent entities in the graph:

```java
Node person = Node.builder()
    .label("Person")
    .property("name", "John")
    .property("age", 30)
    .metadata(Map.of("source", "import"))
    .build();
```

### Relationships

Relationships connect nodes with typed edges:

```java
Relationship knows = Relationship.builder()
    .startNodeId(personId)
    .endNodeId(otherPersonId)
    .type("KNOWS")
    .property("since", "2020")
    .build();
```

### Directions

Relationship traversal directions:
- `OUTGOING`: From start node to end node
- `INCOMING`: From end node to start node
- `BOTH`: Both directions

---

## Usage Examples

### Basic Graph Operations

```java
@Inject
GraphStore graphStore;

// Add node
Node node = Node.builder()
    .label("Concept")
    .property("name", "Machine Learning")
    .build();

String nodeId = graphStore.addNode(node);

// Add relationship
Relationship rel = Relationship.builder()
    .startNodeId(nodeId)
    .endNodeId(otherNodeId)
    .type("RELATED_TO")
    .build();

graphStore.addRelationship(rel);

// Get node
Optional<Node> found = graphStore.getNode(nodeId);

// Get relationships
List<Relationship> rels = graphStore.getRelationships(
    nodeId,
    GraphStore.Direction.OUTGOING
);
```

---

### Find Nodes by Label

```java
// Find all nodes with label
List<Node> people = graphStore.findNodesByLabel("Person");

// Find by property
List<Node> adults = graphStore.findNodesByProperty(
    "Person",
    "age",
    18
);
```

---

### Path Finding

```java
// Find all paths between two nodes
List<List<Node>> paths = graphStore.findPaths(
    startNodeId,
    endNodeId,
    3  // max depth
);

paths.forEach(path -> {
    System.out.println("Path length: " + path.size());
    path.forEach(node -> 
        System.out.println("  - " + node.getProperty("name"))
    );
});
```

---

### Cypher Queries (Neo4j)

```java
// Execute Cypher query
Map<String, Object> params = Map.of("name", "John");
List<Map<String, Object>> results = graphStore.executeCypher(
    "MATCH (p:Person {name: $name}) RETURN p",
    params
);
```

---

### Update and Delete

```java
// Update node
Node updated = Node.builder()
    .id(nodeId)
    .label("Person")
    .property("name", "Jane")
    .property("age", 31)
    .build();

graphStore.updateNode(nodeId, updated);

// Delete node (and relationships)
graphStore.deleteNode(nodeId);

// Delete relationship
graphStore.deleteRelationship(relationshipId);
```

---

## Graph-Memory Integration

Store memories as graph nodes with relationships:

```java
@Inject
GraphMemoryAdapter graphMemory;

// Store memory as node
String nodeId = graphMemory.storeMemory(memory);

// Store with relationships
List<Memory> memories = getMemories();
List<MemoryRelationship> rels = getRelationships();

graphMemory.storeMemoriesWithRelationships(memories, rels);

// Find related memories
List<Memory> related = graphMemory.findRelatedMemories(
    nodeId,
    "RELATED_TO",
    2  // hops
);

// Find paths between memories
List<List<Memory>> paths = graphMemory.findMemoryPaths(
    fromMemoryId,
    toMemoryId,
    3
);
```

[Learn more](graph-memory-integration)

---

## Graph-RAG Integration

Use graph for multi-hop RAG retrieval:

```java
@Inject
RagGraphIntegration ragGraph;

// Hybrid retrieval (vector + graph)
RagResult result = ragGraph.retrieveHybrid(
    query,
    5,  // vector topK
    2   // graph hops
);

// Multi-hop retrieval
List<List<RagChunk>> paths = ragGraph.retrieveMultiHop(
    "neural-networks",
    "backpropagation",
    3
);

// Retrieve by relationship type
List<RagChunk> chunks = ragGraph.retrieveByRelationship(
    entityId,
    "HAS_PART"
);
```

[Learn more](rag-graph-integration)

---

## Configuration Reference

### General Settings

| Property | Default | Description |
|----------|---------|-------------|
| `wayang.graph.store.type` | `inmemory` | Graph store backend |
| `wayang.graph.similarity-threshold` | `0.7` | Default similarity threshold |

### Neo4j Settings

| Property | Default | Description |
|----------|---------|-------------|
| `wayang.graph.store.neo4j.uri` | - | Neo4j Bolt URI |
| `wayang.graph.store.neo4j.username` | - | Neo4j username |
| `wayang.graph.store.neo4j.password` | - | Neo4j password |
| `wayang.graph.store.neo4j.database` | `neo4j` | Database name |

---

## Performance Optimization

### Indexing

**Neo4j:**
```cypher
// Create index on label property
CREATE INDEX FOR (n:Person) ON (n.name);

// Create index on relationship type
CREATE INDEX FOR ()-[r:KNOWS]->() ON (r.since);
```

### Batch Operations

```java
// Batch add nodes
List<Node> nodes = getNodes();
graphStore.addNodes(nodes);

// Batch add relationships
List<Relationship> rels = getRelationships();
graphStore.addRelationships(rels);
```

### Query Optimization

**Use specific labels:**
```cypher
// Good
MATCH (p:Person {name: "John"})

// Avoid (scans all nodes)
MATCH (n {name: "John"})
```

**Limit traversal depth:**
```cypher
// Good (limited)
MATCH path = (a)-[*1..3]-(b)

// Avoid (unbounded)
MATCH path = (a)-[*]-(b)
```

---

## Use Cases

### Knowledge Graph

```java
// Store concepts and relationships
Node concept = Node.builder()
    .label("Concept")
    .property("name", "Machine Learning")
    .build();

Node related = Node.builder()
    .label("Concept")
    .property("name", "Neural Networks")
    .build();

Relationship relates = Relationship.builder()
    .startNodeId(concept.getId())
    .endNodeId(related.getId())
    .type("RELATED_TO")
    .property("strength", 0.9)
    .build();
```

### Citation Network

```java
// Store papers and citations
Node paper = Node.builder()
    .label("Paper")
    .property("title", "Attention Is All You Need")
    .property("year", 2017)
    .build();

Relationship cites = Relationship.builder()
    .startNodeId(citingPaperId)
    .endNodeId(paper.getId())
    .type("CITES")
    .build();
```

### Conversation Graph

```java
// Store conversation turns as nodes
Node turn = Node.builder()
    .label("ConversationTurn")
    .property("speaker", "user")
    .property("text", "What is ML?")
    .property("timestamp", Instant.now())
    .build();

Relationship next = Relationship.builder()
    .startNodeId(currentTurnId)
    .endNodeId(nextTurnId)
    .type("NEXT_TURN")
    .build();
```

---

## Vector vs Graph

| Feature | Vector | Graph |
|---------|--------|-------|
| **Primary Strength** | Semantic similarity | Relationship traversal |
| **Query Type** | "Find similar to X" | "Find connected to X" |
| **Best For** | Semantic search | Multi-hop reasoning |
| **Explainability** | ⭐⭐ | ⭐⭐⭐⭐⭐ |

[Detailed Comparison](graph-vs-vector)

---

## Troubleshooting

### Slow Traversal

**Problem**: Multi-hop queries are slow

**Solutions**:
1. Limit max depth to 2-3 hops
2. Add indexes on relationship types
3. Use relationship type filters
4. Consider Neo4j for large graphs

### Memory Issues

**Problem**: In-memory store consumes too much RAM

**Solutions**:
1. Switch to Neo4j
2. Implement pagination
3. Use graph pruning for old nodes

### Cypher Query Errors

**Problem**: Cypher queries fail

**Solutions**:
1. Verify Neo4j connection
2. Check Cypher syntax
3. Use parameterized queries
4. Check Neo4j logs

---

## Resources

- [Executor Integrations Overview](executor-integrations)
- [Graph-Memory Integration](graph-memory-integration)
- [RAG-Graph Integration](rag-graph-integration)
- [Graph vs Vector Comparison](graph-vs-vector)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [Cypher Query Language](https://neo4j.com/docs/cypher-manual/)

---

[Back to Executors](executors/) &nbsp; [Vector Executor](vector)
