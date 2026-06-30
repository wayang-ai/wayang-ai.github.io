---
layout: default
title: Sandbox Architecture
---

# Sandbox Runtime Architecture

Visual guide to the Wayang Sandbox Runtime architecture and components.

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "Wayang Platform"
        A[Workflow Engine] --> B[Sandbox Manager]
        C[Plugin System] --> B
        D[Memory Services] --> B
    end
    
    subgraph "Sandbox Manager"
        B --> E[Provider Registry]
        B --> F[Lifecycle Management]
        B --> G[Resource Monitor]
        B --> H[Security Enforcer]
    end
    
    subgraph "Isolation Providers"
        E --> I[ClassLoader Provider]
        E --> J[Container Provider]
        E --> K[WASM Provider]
    end
    
    subgraph "Sandbox Instances"
        I --> L[Sandbox 1<br/>ClassLoader]
        I --> M[Sandbox 2<br/>ClassLoader]
        J --> N[Sandbox 3<br/>Docker]
        K --> O[Sandbox 4<br/>WASM]
    end
    
    subgraph "Isolation Layers"
        L --> P[Isolated ClassLoader<br/>SecurityManager]
        N --> Q[Docker Container<br/>cgroups + namespaces]
        O --> R[WasmEdge Runtime<br/>Sandboxed WASM]
    end
    
    subgraph "Host System"
        P --> S[JVM]
        Q --> T[Docker Daemon]
        R --> U[WasmEdge]
        S --> V[Operating System]
        T --> V
        U --> V
    end
```

---

## Sandbox Lifecycle

```mermaid
sequenceDiagram
    participant Client
    participant SM as Sandbox Manager
    participant P as Provider
    participant SI as Sandbox Instance
    
    Client->>SM: createSandbox(config)
    SM->>P: createSandbox(config)
    P->>SI: instantiate()
    SI-->>P: instance
    P-->>SM: instance
    SM-->>Client: SandboxInstance
    
    Note over SI: State: INITIALIZING
    SI->>SI: initialize()
    Note over SI: State: READY
    
    Client->>SI: execute(context)
    Note over SI: State: RUNNING
    SI->>SI: executeWorkflow()
    SI-->>Client: ExecutionResult
    Note over SI: State: READY
    
    Client->>SI: pause()
    Note over SI: State: PAUSED
    
    Client->>SI: resume()
    Note over SI: State: READY
    
    Client->>SI: terminate()
    Note over SI: State: TERMINATING
    SI->>SI: cleanup()
    Note over SI: State: TERMINATED
```

---

## Security Architecture

```mermaid
graph TB
    subgraph "Security Layers"
        A[Client Request] --> B[API Gateway]
        B --> C[Authentication]
        C --> D[Authorization]
        D --> E[Sandbox Manager]
    end
    
    subgraph "Sandbox Security"
        E --> F[Security Policy]
        F --> G[Resource Quotas]
        F --> H[Access Control]
    end
    
    subgraph "ClassLoader Isolation"
        G --> I[Isolated ClassLoader]
        H --> J[SecurityManager]
        I --> K[Blocked Classes]
        J --> L[Permission Checks]
    end
    
    subgraph "Container Isolation"
        G --> M[cgroups limits]
        H --> N[namespace isolation]
        M --> O[Read-only FS]
        N --> P[Network Policies]
    end
    
    subgraph "Host Protection"
        K --> Q[JVM Security]
        L --> Q
        O --> R[OS Security]
        P --> R
    end
```

---

## Multi-Tenant Architecture

```mermaid
graph TB
    subgraph "Tenant A"
        A1[Workflow A] --> A2[Sandbox A1]
        A1 --> A3[Sandbox A2]
        A2 --> A4[Memory A]
        A3 --> A4
        A4 --> A5[Vector Store A]
    end
    
    subgraph "Tenant B"
        B1[Workflow B] --> B2[Sandbox B1]
        B1 --> B3[Sandbox B2]
        B2 --> B4[Memory B]
        B3 --> B4
        B4 --> B5[Vector Store B]
    end
    
    subgraph "Tenant C"
        C1[Workflow C] --> C2[Sandbox C1]
        C2 --> C3[Memory C]
        C3 --> C4[Vector Store C]
    end
    
    A2 --> D[Sandbox Manager]
    A3 --> D
    B2 --> D
    B3 --> D
    C2 --> D
    
    D --> E[Resource Quota Enforcer]
    D --> F[Tenant Isolation Boundary]
    D --> G[Audit Logger]
```

---

## Resource Management Flow

```mermaid
sequenceDiagram
    participant Client
    participant SM as Sandbox Manager
    participant Q as Quota Enforcer
    participant M as Metrics Collector
    participant SI as Sandbox Instance
    
    Client->>SM: createSandbox(quotas)
    SM->>Q: validateQuotas(quotas)
    Q-->>SM: quotas valid
    SM->>SI: create(quotas)
    
    loop Every 5 seconds
        SI->>M: reportMetrics()
        M->>Q: checkQuotas(metrics)
        alt Quota Exceeded
            Q->>SI: throttle()
            Q->>SM: alertQuotaExceeded()
        else Within Quota
            M->>SM: updateMetrics()
        end
    end
    
    SM->>M: collectMetrics()
    SM-->>Client: exposeMetrics()
```

---

## Provider Selection Strategy

```mermaid
graph LR
    A[Workflow Request] --> B{Security Required?}
    B -->|High| C{Untrusted Code?}
    B -->|Standard| D{Performance Critical?}
    B -->|Minimal| E[ClassLoader]
    
    C -->|Yes| F[Container]
    C -->|No| G{Portable Needed?}
    
    D -->|Yes| E
    D -->|No| H{Docker Available?}
    
    G -->|Yes| I[WASM]
    G -->|No| E
    
    H -->|Yes| F
    H -->|No| E
    
    E --> J[Execute]
    F --> J
    I --> J
```

---

## API Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as SandboxResource
    participant SM as SandboxManager
    participant P as Provider
    participant SI as SandboxInstance
    
    Client->>API: POST /api/sandbox/instances
    API->>SM: createSandbox(config)
    SM->>P: createSandbox(config)
    P->>SI: instantiate()
    SI-->>P: instance
    P-->>SM: instance
    SM-->>API: instance
    API-->>Client: 201 Created + Instance
    
    Client->>API: GET /api/sandbox/instances/{id}
    API->>SM: getSandbox(id)
    SM-->>API: instance
    API-->>Client: 200 OK + Instance
    
    Client->>API: POST /api/sandbox/instances/{id}/execute
    API->>SM: getSandbox(id)
    SM-->>API: instance
    API->>SI: execute(context)
    SI-->>API: result
    API-->>Client: 200 OK + Result
    
    Client->>API: DELETE /api/sandbox/instances/{id}
    API->>SM: terminateSandbox(id)
    SM->>SI: terminate()
    SI-->>SM: terminated
    SM-->>API: success
    API-->>Client: 204 No Content
```

---

## Observability Stack

```mermaid
graph TB
    subgraph "Sandbox Runtime"
        A[Sandbox Instances] --> B[Metrics Collector]
        A --> C[Log Aggregator]
        A --> D[Trace Generator]
    end
    
    subgraph "Metrics Pipeline"
        B --> E[Micrometer]
        E --> F[Prometheus]
        F --> G[Grafana]
    end
    
    subgraph "Logging Pipeline"
        C --> H[Structured Logs]
        H --> I[Log Collector]
        I --> J[Elasticsearch]
        J --> K[Kibana]
    end
    
    subgraph "Tracing Pipeline"
        D --> L[OpenTelemetry]
        L --> M[Jaeger/Zipkin]
        M --> N[Distributed Traces]
    end
    
    subgraph "Alerting"
        F --> O[Alert Manager]
        J --> O
        O --> P[Notifications]
    end
```

---

## Deployment Patterns

### Single Node Deployment

```mermaid
graph TB
    A[Wayang Standalone] --> B[Sandbox Runtime]
    B --> C[ClassLoader Provider]
    B --> D[Container Provider]
    C --> E[Sandbox Instances]
    D --> F[Docker Containers]
    E --> G[JVM]
    F --> H[Docker Daemon]
    G --> I[Host OS]
    H --> I
```

### Multi-Node Cluster Deployment

```mermaid
graph TB
    A[Load Balancer] --> B[Node 1]
    A --> C[Node 2]
    A --> D[Node 3]
    
    B --> E[Sandbox Manager]
    C --> F[Sandbox Manager]
    D --> G[Sandbox Manager]
    
    E --> H[Container Provider]
    F --> I[Container Provider]
    G --> J[Container Provider]
    
    H --> K[Docker Cluster]
    I --> K
    J --> K
    
    K --> L[Node 4]
    K --> M[Node 5]
    K --> N[Node 6]
```

---

[← Back to Sandbox Runtime](./sandbox-runtime.md)
