---
layout: default
title: Sandbox Runtime
---

# Sandbox Runtime

Isolated execution environments for AI agent workflows with configurable security and resource management.

---

## Overview

The Wayang Sandbox Runtime provides secure, isolated execution environments for running AI agent workflows. It enables safe execution of untrusted or multi-tenant workflows while maintaining high performance and flexibility.

### Key Benefits

- **🔒 Security** - Multiple isolation strategies from lightweight ClassLoader to strong container-based isolation
- **⚡ Performance** - Optimized for minimal overhead with sub-100ms startup times
- **🎯 Flexibility** - Choose the right isolation level for your use case
- **📊 Resource Control** - Fine-grained CPU, memory, and thread quotas
- **🏢 Multi-Tenancy** - Tenant-scoped sandboxes with complete isolation
- **🔍 Observability** - Comprehensive metrics, logging, and health monitoring

---

## Isolation Strategies

Wayang supports multiple isolation strategies to match your security and performance requirements.

### ClassLoader Isolation (Default)

Lightweight isolation using custom ClassLoaders and Java SecurityManager.

**Best for**: Trusted code, development, high-performance scenarios

| Characteristic | Value |
|----------------|-------|
| Startup Time | < 100ms |
| Memory Overhead | ~10MB |
| CPU Overhead | < 5% |
| Isolation Strength | Medium |

```properties
wayang.sandbox.default-provider=classloader
wayang.sandbox.classloader.max-sandboxes=100
wayang.sandbox.classloader.security-manager-enabled=true
```

### Container Isolation (Docker)

Strong OS-level isolation using Docker containers with cgroups and namespaces.

**Best for**: Untrusted code, production, multi-tenant SaaS

| Characteristic | Value |
|----------------|-------|
| Startup Time | 1-5s |
| Memory Overhead | ~50MB |
| CPU Overhead | 10-20% |
| Isolation Strength | High |

```properties
wayang.sandbox.default-provider=container
wayang.sandbox.container.docker-host=unix:///var/run/docker.sock
wayang.sandbox.container.max-sandboxes=50
wayang.sandbox.container.network-enabled=false
```

### WASM Isolation (Optional)

Portable execution using WebAssembly with WasmEdge runtime.

**Best for**: Edge deployments, cross-platform workloads

| Characteristic | Value |
|----------------|-------|
| Startup Time | < 500ms |
| Memory Overhead | ~20MB |
| CPU Overhead | 5-10% |
| Isolation Strength | High |

```properties
wayang.sandbox.wasm.enabled=true
wayang.sandbox.wasm.max-sandboxes=25
wayang.sandbox.wasm.wasmedge-lib-path=/usr/lib/libwasmedge.so
```

---

## Security Policies

Configure fine-grained security policies for sandbox execution.

### Security Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **MINIMAL** | Basic resource limits only | Development, trusted code |
| **STANDARD** | File system and network restrictions | Default production |
| **HIGH** | Comprehensive restrictions, read-only FS | Untrusted workflows |
| **MAXIMUM** | Complete isolation, minimal syscalls | Highly sensitive code |

### File System Access

- **NONE** - No file system access
- **READ_ONLY** - Read-only access to specified paths
- **READ_WRITE** - Read-write access to specified paths
- **FULL** - Full access (not recommended)

### Network Access

- **NONE** - No network access (default)
- **LOCALHOST_ONLY** - Only localhost/loopback
- **ALLOWLIST_ONLY** - Specific hosts/ports only
- **FULL** - Full network access (not recommended)

### Example Security Configuration

```java
SecurityPolicy policy = SecurityPolicy.builder()
    .fileSystemAccess(SecurityPolicy.FileSystemAccess.READ_ONLY)
    .addAllowedPath("/data/workflows")
    .networkAccess(SecurityPolicy.NetworkAccess.NONE)
    .allowSystemExit(false)
    .allowReflection(true)
    .allowNativeCalls(false)
    .addDeniedClass("java.lang.Runtime")
    .build();
```

---

## Resource Quotas

Set precise resource limits for sandbox execution.

### Available Quotas

| Resource | Unit | Default | Description |
|----------|------|---------|-------------|
| CPU | millicores | 500 | 1000 = 1 CPU core |
| Memory | MB | 512 | Maximum heap size |
| Disk | MB | 1024 | Storage space limit |
| Threads | count | 8 | Maximum concurrent threads |
| File Descriptors | count | 64 | Open file handle limit |
| Network Bandwidth | Mbps | 0 | 0 = disabled |
| Execution Time | seconds | 1800 | Maximum duration |

### Example Quota Configuration

```java
ResourceQuotas quotas = ResourceQuotas.builder()
    .cpuMillicores(1000)        // 1 CPU core
    .memoryMB(1024)             // 1 GB RAM
    .diskMB(2048)               // 2 GB disk
    .maxThreads(16)             // 16 threads
    .maxFileDescriptors(128)    // 128 files
    .networkBandwidthMbps(10)   // 10 Mbps
    .maxExecutionTimeSeconds(3600) // 1 hour
    .build();
```

---

## REST API

Complete HTTP API for sandbox management.

### Endpoints

#### System Health

```bash
GET /api/sandbox/health
```

Response:
```json
{
  "totalProviders": 2,
  "availableProviders": 2,
  "totalSandboxes": 5,
  "activeSandboxes": 3,
  "errorSandboxes": 0,
  "timestamp": 1234567890,
  "healthy": true
}
```

#### List Providers

```bash
GET /api/sandbox/providers
```

#### Create Sandbox

```bash
POST /api/sandbox/instances
Content-Type: application/json

{
  "name": "my-sandbox",
  "isolationStrategy": "CLASSLOADER",
  "securityLevel": "STANDARD",
  "cpuMillicores": 500,
  "memoryMB": 512,
  "diskMB": 1024,
  "maxThreads": 8,
  "environmentVariables": {
    "TENANT_ID": "tenant-123"
  }
}
```

#### List Instances

```bash
GET /api/sandbox/instances?tenantId={tenantId}&state={state}
```

#### Get Instance Details

```bash
GET /api/sandbox/instances/{sandboxId}
```

#### Terminate Sandbox

```bash
DELETE /api/sandbox/instances/{sandboxId}
```

#### Pause Sandbox

```bash
POST /api/sandbox/instances/{sandboxId}/pause
```

#### Resume Sandbox

```bash
POST /api/sandbox/instances/{sandboxId}/resume
```

#### Execute Workflow

```bash
POST /api/sandbox/instances/{sandboxId}/execute
Content-Type: application/json

{
  "workflowId": "workflow-123",
  "inputData": {
    "key": "value"
  }
}
```

#### Get Metrics

```bash
GET /api/sandbox/instances/{sandboxId}/metrics
```

---

## Usage Examples

### Programmatic (Java)

```java
import jakarta.inject.Inject;
import tech.kayys.wayang.sandbox.manager.SandboxManager;
import tech.kayys.wayang.sandbox.spi.*;

public class SandboxExample {
    
    @Inject
    SandboxManager sandboxManager;
    
    public void executeWorkflow() {
        // Create sandbox configuration
        SandboxConfig config = SandboxConfig.builder()
            .name("my-sandbox")
            .isolationStrategy(SandboxConfig.IsolationStrategy.CLASSLOADER)
            .securityLevel(SandboxConfig.SecurityLevel.STANDARD)
            .resourceQuotas(ResourceQuotas.defaultQuotas())
            .addEnvironmentVariable("TENANT_ID", "tenant-123")
            .build();
        
        // Create sandbox instance
        SandboxInstance sandbox = sandboxManager.createSandbox(config)
            .await().atMost(Duration.ofSeconds(30));
        
        try {
            // Execute workflow
            SandboxExecutionContext context = SandboxExecutionContext.builder()
                .workflowId("workflow-123")
                .addInput("message", "Hello, Sandbox!")
                .build();
            
            SandboxExecutionResult result = sandbox.execute(context)
                .await().atMost(Duration.ofMinutes(5));
            
            if (result.isSuccess()) {
                System.out.println("Success: " + result.getResult());
            } else {
                System.err.println("Failed: " + result.getError());
            }
        } finally {
            // Always terminate sandbox
            sandbox.terminate().await().atMost(Duration.ofSeconds(10));
        }
    }
}
```

### cURL Examples

```bash
# Create a sandbox
curl -X POST http://localhost:8080/api/sandbox/instances \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test-sandbox",
    "isolationStrategy": "CLASSLOADER",
    "securityLevel": "STANDARD",
    "memoryMB": 512
  }'

# List all sandboxes
curl http://localhost:8080/api/sandbox/instances

# Get sandbox metrics
curl http://localhost:8080/api/sandbox/instances/{sandboxId}/metrics

# Pause a sandbox
curl -X POST http://localhost:8080/api/sandbox/instances/{sandboxId}/pause

# Terminate a sandbox
curl -X DELETE http://localhost:8080/api/sandbox/instances/{sandboxId}
```

### Python Example

```python
import requests

SANDBOX_BASE = "http://localhost:8080/api/sandbox"

def create_sandbox():
    response = requests.post(
        f"{SANDBOX_BASE}/instances",
        json={
            "name": "python-sandbox",
            "isolationStrategy": "CLASSLOADER",
            "memoryMB": 512
        }
    )
    return response.json()["id"]

def execute_workflow(sandbox_id, workflow_id, input_data):
    response = requests.post(
        f"{SANDBOX_BASE}/instances/{sandbox_id}/execute",
        json={
            "workflowId": workflow_id,
            "inputData": input_data
        }
    )
    return response.json()

def terminate_sandbox(sandbox_id):
    requests.delete(f"{SANDBOX_BASE}/instances/{sandbox_id}")

# Usage
sandbox_id = create_sandbox()
try:
    result = execute_workflow(sandbox_id, "my-workflow", {"key": "value"})
    print(f"Result: {result}")
finally:
    terminate_sandbox(sandbox_id)
```

---

## Multi-Tenancy

Support multiple tenants with isolated sandboxes:

```java
public class MultiTenantExample {
    
    @Inject
    SandboxManager sandboxManager;
    
    public Map<String, SandboxInstance> createTenantSandboxes(List<String> tenantIds) {
        Map<String, SandboxInstance> sandboxes = new ConcurrentHashMap<>();
        
        for (String tenantId : tenantIds) {
            SandboxConfig config = SandboxConfig.builder()
                .name("tenant-" + tenantId + "-sandbox")
                .addEnvironmentVariable("TENANT_ID", tenantId)
                .isolationStrategy(SandboxConfig.IsolationStrategy.CLASSLOADER)
                .build();
            
            SandboxInstance sandbox = sandboxManager.createSandbox(config)
                .await().atMost(Duration.ofSeconds(30));
            
            sandboxes.put(tenantId, sandbox);
        }
        
        return sandboxes;
    }
    
    public void executeTenantWorkflow(String tenantId, String workflowId, 
                                       Map<String, Object> inputData) {
        List<SandboxInstance> tenantSandboxes = sandboxManager.getTenantSandboxes(tenantId);
        
        if (tenantSandboxes.isEmpty()) {
            throw new IllegalStateException("No sandbox for tenant: " + tenantId);
        }
        
        SandboxInstance sandbox = tenantSandboxes.get(0);
        
        SandboxExecutionContext context = SandboxExecutionContext.builder()
            .workflowId(workflowId)
            .inputData(inputData)
            .tenantId(tenantId)
            .build();
        
        SandboxExecutionResult result = sandbox.execute(context)
            .await().atMost(Duration.ofMinutes(10));
        
        // Process result...
    }
    
    public void cleanupTenant(String tenantId) {
        sandboxManager.terminateTenantSandboxes(tenantId)
            .await().atMost(Duration.ofSeconds(30));
    }
}
```

---

## Monitoring & Observability

### Metrics (Prometheus)

The sandbox runtime exposes metrics via Prometheus:

```bash
curl http://localhost:8080/q/metrics
```

Key metrics:
- `sandbox_provider_active_instances` - Active sandboxes per provider
- `sandbox_provider_total_created` - Total sandboxes created
- `sandbox_execution_duration_seconds` - Execution duration histogram
- `sandbox_resource_cpu_usage_percent` - CPU usage per sandbox
- `sandbox_resource_memory_usage_mb` - Memory usage per sandbox
- `sandbox_health_status` - Overall system health

### Distributed Tracing

All sandbox operations are traced with OpenTelemetry:

- `sandbox.create` - Sandbox creation
- `sandbox.execute` - Workflow execution
- `sandbox.terminate` - Sandbox termination
- `sandbox.pause` / `sandbox.resume` - Lifecycle operations

### Health Monitoring

```java
SandboxSystemHealth health = sandboxManager.getSystemHealth()
    .await().atMost(Duration.ofSeconds(5));

if (!health.isHealthy()) {
    log.error("Sandbox system unhealthy: {}", health);
    // Alert operations team
}
```

---

## Configuration Reference

### application.properties

```properties
# Enable sandbox runtime
wayang.sandbox.enabled=true

# Default provider (classloader, container, wasm)
wayang.sandbox.default-provider=classloader

# Maximum concurrent sandboxes
wayang.sandbox.max-concurrent-sandboxes=100

# Default timeout (seconds)
wayang.sandbox.default-timeout-seconds=300

# ClassLoader provider
wayang.sandbox.classloader.max-sandboxes=100
wayang.sandbox.classloader.security-manager-enabled=true

# Container provider
wayang.sandbox.container.docker-host=unix:///var/run/docker.sock
wayang.sandbox.container.max-sandboxes=50
wayang.sandbox.container.default-image=wayang-sandbox-runtime:latest
wayang.sandbox.container.network-enabled=false
wayang.sandbox.container.auto-cleanup=true

# WASM provider
wayang.sandbox.wasm.enabled=false
wayang.sandbox.wasm.max-sandboxes=25
wayang.sandbox.wasm.wasmedge-lib-path=

# Security defaults
wayang.sandbox.security.default-level=STANDARD
wayang.sandbox.security.default-fs-access=READ_ONLY
wayang.sandbox.security.default-network-access=NONE

# Resource quota defaults
wayang.sandbox.quotas.default-cpu-millicores=500
wayang.sandbox.quotas.default-memory-mb=512
wayang.sandbox.quotas.default-disk-mb=1024
wayang.sandbox.quotas.default-max-threads=8
```

---

## Best Practices

### 1. Choose Appropriate Isolation

- **Development**: ClassLoader (fast, lightweight)
- **Production (trusted)**: ClassLoader with security manager
- **Production (untrusted)**: Container (strong isolation)
- **Multi-tenant SaaS**: Container per tenant

### 2. Apply Least Privilege

```java
SecurityPolicy policy = SecurityPolicy.builder()
    .fileSystemAccess(SecurityPolicy.FileSystemAccess.READ_ONLY)
    .networkAccess(SecurityPolicy.NetworkAccess.NONE)
    .allowSystemExit(false)
    .allowNativeCalls(false)
    .build();
```

### 3. Set Resource Limits

Always configure CPU and memory quotas to prevent resource exhaustion.

### 4. Monitor and Alert

Regularly check system health and resource usage metrics.

### 5. Cleanup Resources

Always terminate sandboxes when done to free resources.

---

## Integration with Wayang Platform

The sandbox runtime integrates seamlessly with:

- **Gamelan Orchestration** - Execute workflows in isolated environments
- **Plugin System** - Safe plugin loading and execution
- **Memory Services** - Isolated memory per tenant
- **Guardrails** - Security policy enforcement
- **RAG** - Isolated vector search and retrieval

---

## Troubleshooting

### Sandbox Creation Fails

**Problem**: "Maximum number of sandboxes reached"

**Solution**: Increase limit or terminate unused sandboxes:
```properties
wayang.sandbox.classloader.max-sandboxes=200
```

### Docker Provider Unavailable

**Problem**: "Docker client not initialized"

**Solution**:
1. Ensure Docker daemon is running: `docker ps`
2. Check Docker socket permissions
3. Verify Docker host configuration

### Execution Timeout

**Problem**: Workflow execution times out

**Solution**:
1. Increase timeout in config
2. Optimize workflow performance
3. Check resource quotas

---

## Additional Resources

- **[Quick Start Guide](https://github.com/bhangun/wayang/blob/main/wayang/runtime/wayang-sandbox-runtime/QUICKSTART.md)** - Get started quickly
- **[README](https://github.com/bhangun/wayang/blob/main/wayang/runtime/wayang-sandbox-runtime/README.md)** - Comprehensive documentation
- **[Integration Guide](https://github.com/bhangun/wayang/blob/main/wayang/runtime/wayang-sandbox-runtime/INTEGRATION_GUIDE.md)** - Integration examples
- **[Module Summary](https://github.com/bhangun/wayang/blob/main/wayang/runtime/wayang-sandbox-runtime/MODULE_SUMMARY.md)** - Architecture overview
- **[Sandbox Architecture](./sandbox-architecture.md)** - Visual architecture diagrams

---

[← Back to Documentation](./index.md)
