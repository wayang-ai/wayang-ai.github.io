---
layout: default
title: Debugger API
---

# Debugger API

Standalone runtime now exposes debugger endpoints via `wayang-debugger`.

Base path:

- `/api/v1/debug/projects/{projectId}/executions/{executionId}`

## Endpoints

- `GET /events`
- `GET /telemetry`
- `GET /lineage`
- `GET /snapshot`

These endpoints reuse the same execution data as Projects API and are intended for UI troubleshooting workflows.

## Examples

Get raw execution events:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/debug/projects/{projectId}/executions/{executionId}/events"
```

Get telemetry with filters:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/debug/projects/{projectId}/executions/{executionId}/telemetry?groupBy=nodeId&sort=tasksExecuted:desc&limit=20"
```

Get lineage focused projection:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/debug/projects/{projectId}/executions/{executionId}/lineage?view=compact&include=executionContext,status,updatedAt"
```

Get one-shot snapshot for debugging:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/debug/projects/{projectId}/executions/{executionId}/snapshot?includeRaw=true&eventsLimit=200"
```

`snapshot` includes:

- `status`: execution status payload
- `events`: execution timeline events
- `telemetry`: aggregated telemetry payload
- `lineage`: sub-workflow lineage payload

## Runtime Wiring Notes

The debugger module is wired in standalone mode with:

- dependency: `tech.kayys.wayang:wayang-debugger`
- index config:
  - `quarkus.index-dependency.wayang-debugger.group-id=tech.kayys.wayang`
  - `quarkus.index-dependency.wayang-debugger.artifact-id=wayang-debugger`
