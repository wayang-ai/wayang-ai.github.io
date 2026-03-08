---
layout: default
title: Standalone Troubleshooting
---

# Standalone API Routing and Troubleshooting

## API Routing Note

`/api/v1/projects*` is now implemented in the core API module (`wayang/core/wayang-api`) and consumed by standalone runtime.

Primary resource classes:

- `tech.kayys.wayang.control.api.ProjectResource`
- `tech.kayys.wayang.runtime.standalone.resource.ProjectExecutionsResource`

Use this property to keep route registration unambiguous:

```properties
wayang.runtime.standalone.projects-resource.enabled=true
```

## Startup Troubleshooting

### 1) `ClassNotFoundException` for `ControlPlane*Registry`

Symptom:

```text
Caused by: java.lang.ClassNotFoundException: ControlPlaneNodeRegistry
```

Cause:

- stale/corrupted compiled classes in `target/`
- stale local SNAPSHOT jars after incremental changes
- standalone index dependency still points to legacy artifact name

Fix:

```bash
# Rebuild and reinstall core modules used by runtime
mvn -f wayang/core/wayang-control-core/pom.xml -DskipTests -nsu clean install
mvn -f wayang/core/wayang-api/pom.xml -DskipTests -nsu clean install

# Rebuild standalone runtime cleanly
mvn -f wayang/runtime/wayang-runtime-standalone/pom.xml -DskipTests -nsu clean compile
```

Ensure runtime indexes the centralized API artifact:

```properties
quarkus.index-dependency.wayang-api.group-id=tech.kayys.wayang
quarkus.index-dependency.wayang-api.artifact-id=wayang-api
```

### 2) `Pad letter 'p' must be followed by valid pad pattern`

Symptom:

```text
IllegalArgumentException: Pad letter 'p' must be followed by valid pad pattern
```

Cause:

- malformed log format expression parsing

Fix:

```properties
quarkus.log.file.format=%d{yyyy-MM-dd HH:mm:ss,SSS} %-5p [%c{2.}] (%t) %s%e%n
```

Avoid nested `${...}` defaults containing `%d{...}` or `%c{...}` in the same expression.

## Telemetry Quickstart

Use these commands to inspect execution telemetry quickly.

### 1) Base Aggregation

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry"
```

### 2) Time Window + Node Filter

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?from=2026-03-07T00:00:00Z&to=2026-03-07T01:00:00Z&nodeId=orchestrator-node-1"
```

### 3) Grouped View

Group by node:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?groupBy=nodeId"
```

Group by event type, sorted and limited:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?groupBy=type&sort=tasksExecuted:desc&limit=5"
```

### 4) Include Raw Events for Debugging

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?includeRaw=true"
```

### 5) What to Look At First

- `counters.delegationFailures` and `counters.delegationTimeouts` for stability issues
- `latestBudget.maxAgentLatencyMs` and `latestBudget.maxRetriesPerDelegation` for guardrail tuning
- grouped output (`groupBy=nodeId`) to identify the hottest/failing node

## Debugger Snapshot Quickstart

For one-shot troubleshooting payloads (status + events + telemetry + lineage), use:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/debug/projects/{projectId}/executions/{executionId}/snapshot?includeRaw=true&eventsLimit=200"
```

Related debug endpoints:

- `/api/v1/debug/projects/{projectId}/executions/{executionId}/events`
- `/api/v1/debug/projects/{projectId}/executions/{executionId}/telemetry`
- `/api/v1/debug/projects/{projectId}/executions/{executionId}/lineage`
- `/api/v1/debug/projects/{projectId}/executions/{executionId}/snapshot`
