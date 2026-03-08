---
layout: default
title: Telemetry API
---

# Telemetry API

Execution telemetry is available from:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry"
```

## Query Parameters

- `from`: ISO-8601 timestamp lower bound (inclusive), example: `2026-03-07T00:00:00Z`
- `to`: ISO-8601 timestamp upper bound (inclusive)
- `nodeId`: filter to a single node id
- `type`: filter by event type (for example `NODE_COMPLETED`)
- `groupBy`: `nodeId` or `type`
- `sort`: grouped sort key with optional direction, example: `tasksExecuted:desc`
- `limit`: max number of grouped rows returned
- `includeRaw`: `true` to include filtered `rawEvents` in response

## Response Shape

Top-level fields:

- `projectId`
- `executionId`
- `eventCount`
- `telemetryEventCount`
- `orchestrationTypes`
- `filters`
- `counters`
- `latestBudget` (if available)
- `grouped` (if `groupBy` is provided)
- `rawEventCount`, `rawEvents` (if `includeRaw=true`)
- `aggregatedAt`

## Examples

Filter by time window:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?from=2026-03-07T00:00:00Z&to=2026-03-07T01:00:00Z"
```

Group by node:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?groupBy=nodeId"
```

Group by type, sorted and limited:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?groupBy=type&sort=tasksExecuted:desc&limit=5"
```

Include raw events for debugging:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/telemetry?includeRaw=true"
```
