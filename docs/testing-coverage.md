---
layout: default
title: Testing Coverage
---

# Runtime Testing Coverage

## Trigger and HITL Coverage

Automated coverage includes:

- `TriggerSourceExecutorTest`
  - validates all supported trigger types
  - validates schema parameter mapping in output (`triggerIntegration`)
  - validates live/simulated behavior and probe handling
- `BuiltinSchemaCatalogTriggerTest`
  - validates trigger schemas are present in catalog
  - validates required trigger parameter fields in schema definitions
- project execution integration tests
  - validates `POST /api/v1/projects/{projectId}/executions` end-to-end behavior with runtime spec payloads
  - validates dry-run path (`dryRun`/`validateOnly`) returns validation-only response and does not persist execution records
  - validates idempotent submit using `Idempotency-Key` replays existing execution and avoids duplicate runs
  - validates replay-window control (`idempotencyReplayWindowSeconds=0`) disables dedup replay and creates a new execution
  - validates request correlation (`X-Request-Id`) is echoed in execution response and present in timeline event metadata
  - validates stop reason taxonomy rejects unsupported reasons with `400 INVALID_STOP_REASON`
  - validates lifecycle transition conflicts return standardized error payload (`errorCode`, `details`)
  - validates optimistic concurrency via `If-Match` returns `409 EXECUTION_VERSION_CONFLICT` on stale version
  - validates retryable conflicts include `Retry-After` header and `retryAfterSeconds` payload
  - validates execution submit rate limiting emits `X-RateLimit-*` headers and returns `429 EXECUTION_RATE_LIMITED` when exceeded
  - validates execution status returns `ETag` and supports conditional polling with `If-None-Match` (`304` when unchanged)
  - validates strict lifecycle transitions reject invalid `stop`/`resume` calls with `409 Conflict`
  - validates execution lifecycle behavior used by HITL pause/resume flows
- `StandaloneExecutionTimelineServiceTest`
  - validates node-completed timeline events include `metadata.telemetry` extracted from executor output
  - validates orchestrator metrics (`orchestrationType`, `tasksExecuted`, `budget`, `executorTelemetry`) are persisted for observability
- `ProjectsResourceTelemetryTest`
  - validates `GET /api/v1/projects/{projectId}/executions/{executionId}/telemetry` aggregates timeline telemetry counters
  - validates latest budget snapshot and delegation counters are returned consistently
  - validates filtered windows, `groupBy=nodeId`, and `groupBy=type` with `sort`/`limit` rollups
  - validates `includeRaw=true` returns filtered raw event payload for debugging

## Agent Schema Coverage

Automated coverage includes:

- `SchemaCatalogApiTest`
  - validates `agent-planner` and `agent-evaluator` are exposed by `/v1/schema/catalog`
  - validates typed schema fields are present in catalog payloads:
    - planner: `goal`, `strategy`
    - evaluator: `candidateOutput`, `criteria`
- `SchemaApiDynamicGenerationTest`
  - validates dynamic catalog schema exposure for:
    - `agent-orchestrator` (`goal`, `strategy`, `maxIterations`, `maxDelegations`, `maxLatencyMs`, `maxAgentLatencyMs`, `maxRetriesPerDelegation`)
    - `agent-analytic` (`goal`, `criteria`, `preferredProvider`)

## Agent Executor Coverage

Automated unit coverage includes:

- `BasicAgentExecutorTest`
  - validates `agent-basic` matching and successful execution path
- `CoderAgentExecutorTest`
  - validates `agent-coder` typed execution (`instruction` / `taskType`) and output mapping
- `AnalyticAgentExecutorTest`
  - validates `agent-analytic` typed execution (`question` / `taskType`) and output mapping
- `PlannerAgentExecutorTest`
  - validates `agent-planner` typed execution and provider handling
- `EvaluatorAgentExecutorTest`
  - validates `agent-evaluator` typed/fallback inputs (`candidateOutput`, `criteria`)
- `OrchestratorAgentExecutorTest`
  - validates orchestration flows and agent delegation aliases
  - validates loop budget controls (`maxIterations`, `maxDelegations`, `maxLatencyMs`, `maxAgentLatencyMs`, `maxRetriesPerDelegation`, invalid budget input handling)

## MCP Coverage

See dedicated MCP test details in [MCP API Coverage](./mcp).
