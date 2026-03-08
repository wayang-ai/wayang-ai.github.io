---
layout: default
title: Schema Catalog
---

# Schema Catalog and WayangSpec

Schema catalog endpoint:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/v1/schema/catalog"
```

Get a specific schema:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/v1/schema/catalog/{schemaId}"
```

## Key Semantics

- `wayang-spec` is the single source of truth for full workflow/spec payload structure.
- `workflow-spec` is supported as an alias to `wayang-spec` for compatibility.
- `workflow` is a simpler legacy node/connection schema and is not equivalent to `wayang-spec`.

## Built-In Schema Coverage

Catalog includes built-in schemas from core and executors, including:

- agent (`agent-config`, `agent-orchestrator`, `agent-planner`, `agent-coder`, `agent-evaluator`, `agent-basic`, `agent-analytic`)
- RAG (`rag-executor` and related response/retrieval/generation schemas)
- memory (`memory-*`)
- EIP (`eip-*`, `dead-letter-channel`)
- HITL (`hitl-human-task`)
- tool (`tool-http`, `tool-sandbox`, `tool-mcp`, `tool-utcp`, `tool-rest`)
- vector + embedding + web search (`vector-*`, `embedding-generate`, `web_search`)

## Project Execution Payload

Dedicated endpoint contract and sharing examples are also documented in [Projects API](./projects-api).

Project execution accepts `spec`, `wayangSpec`, or `workflowSpec` keys:

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/executions" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: community" \
  -d '{
    "name": "demo-execution",
    "spec": { "workflow": { "name": "Demo" } }
  }'
```

Dry-run validation (no workflow run is started):

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/executions" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: community" \
  -d '{
    "name": "demo-dry-run",
    "dryRun": true,
    "spec": { "workflow": { "name": "Demo" } }
  }'
```

Supported flags: `dryRun` or `validateOnly` (either enables validation-only mode).

### Sub-Workflow / Custom Agent Node

Saved projects can now be embedded as sub-workflows using node types:

- `sub-workflow`
- `custom-agent-node` (alias)

Execution behavior:

- Parent graph expands sub-workflow nodes before runtime execution.
- Parent-to-child and child-to-parent edges are rewired automatically.
- Parent effectively waits for child completion because child graph is inlined synchronously.
- Default depth guard is `2` (configurable per request with `maxSubWorkflowDepth`, clamped `1..5`).
- Cycle detection rejects recursive project references.

Node configuration example:

```json
{
  "type": "sub-workflow",
  "configuration": {
    "projectId": "b8ef8f37-7d9a-41a5-92a9-bf5cd95ef89c",
    "projectVersion": "v2",
    "inputs": {
      "ticketId": "INC-123",
      "priority": 5
    },
    "outputBindings": {
      "summary": "context.child.summary"
    },
    "wayangSpec": {
      "specVersion": "1.0.0",
      "workflow": {
        "nodes": [],
        "connections": []
      }
    },
    "maxDepth": 2
  }
}
```

Execution request example:

```json
{
  "name": "parent-with-children",
  "maxSubWorkflowDepth": 2,
  "spec": {
    "specVersion": "1.0.0",
    "workflow": {
      "nodes": [],
      "connections": []
    }
  }
}
```

### Designer Contract: Custom Agent Node

For `wayang-ui` custom reusable agent/sub-workflow node, use:

- `type`: `custom-agent-node` (or `sub-workflow`)
- `metadata.id`: stable node id
- `configuration.projectId`: referenced saved project id
- optional `configuration.wayangSpec`: inline sub-workflow payload override
- optional `maxSubWorkflowDepth` in execution request

Preferred frontend behavior:

- frontend should send reference-only node payload (`configuration.projectId`)
- frontend should not copy/embed full child workflow payload into parent payload by default
- runtime loads child payload from saved project metadata when execution request arrives
- inline `configuration.wayangSpec` is supported as an override/fallback, but not required for normal UI flow
- for parameterized callable children, frontend should populate `configuration.inputs` (or `parameters` / `inputBindings`)
- frontend may pin `configuration.projectVersion` for deterministic child contract execution
- frontend may map child outputs with `configuration.outputBindings` based on declared callable output schema
- UI should use `GET /api/v1/projects/shareable?mode=callable` and display `callable.inputs` + `callable.output` for mapping

### Share / Consent Metadata (Standalone + Enterprise-Compatible)

Store access policy in project metadata:

```json
{
  "metadata": {
    "access": {
      "ownerTenantId": "tenant-a",
      "ownerUserId": "alice",
      "visibility": "private",
      "sharedWithUsers": ["bob"],
      "sharedWithTenants": ["tenant-b"],
      "requireConsent": false,
      "consentGrants": [
        {
          "tenantId": "tenant-b",
          "userId": "bob",
          "permission": "execute_subworkflow"
        }
      ]
    }
  }
}
```

Resolver rules:

- owner always allowed
- `visibility=private`: owner/share only (standalone fallback allows same-tenant when user identity is absent)
- `visibility=tenant`: same tenant or explicit share
- `visibility=explicit`: explicit share only (plus owner)
- `visibility=public`: open reference
- if `requireConsent=true`, non-owner access also needs matching `consentGrants.permission=execute_subworkflow`

#### End-to-End Sharing Examples

1. Owner creates child project (`tenant-a` / `alice`) as private:

```bash
curl -X POST "http://localhost:31713/api/v1/projects" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-a" \
  -H "X-User-Id: alice" \
  -d '{
    "name": "shared-child-project",
    "metadata": {
      "createdBy": "alice",
      "access": {
        "ownerTenantId": "tenant-a",
        "ownerUserId": "alice",
        "visibility": "private",
        "requireConsent": false
      }
    },
    "spec": {
      "specVersion": "1.0.0",
      "workflow": { "nodes": [], "connections": [] }
    }
  }'
```

2. Owner updates sharing for cross-tenant execution (`tenant-b` / `bob`):

```bash
curl -X PUT "http://localhost:31713/api/v1/projects/{childProjectId}" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-a" \
  -H "X-User-Id: alice" \
  -d '{
    "metadata": {
      "access": {
        "ownerTenantId": "tenant-a",
        "ownerUserId": "alice",
        "visibility": "explicit",
        "sharedWithTenants": ["tenant-b"],
        "sharedWithUsers": ["bob"],
        "requireConsent": false
      }
    }
  }'
```

3. Parent execution by requester (`tenant-b` / `bob`) referencing child by `projectId`:

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{parentProjectId}/executions" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-b" \
  -H "X-User-Id: bob" \
  -d '{
    "name": "parent-uses-shared-child",
    "spec": {
      "specVersion": "1.0.0",
      "workflow": {
        "nodes": [
          {
            "metadata": { "id": "child-node-1" },
            "type": "custom-agent-node",
            "configuration": {
              "projectId": "{childProjectId}"
            }
          }
        ],
        "connections": []
      }
    }
  }'
```

4. Consent-required variant (`requireConsent=true`) with grant:

```json
{
  "metadata": {
    "access": {
      "ownerTenantId": "tenant-a",
      "ownerUserId": "alice",
      "visibility": "explicit",
      "sharedWithUsers": ["bob"],
      "sharedWithTenants": ["tenant-b"],
      "requireConsent": true,
      "consentGrants": [
        {
          "tenantId": "tenant-b",
          "userId": "bob",
          "permission": "execute_subworkflow"
        }
      ]
    }
  }
}
```

If `requireConsent=true` and no matching grant exists, sub-workflow expansion is denied during execution submission.

Minimal node fragment:

```json
{
  "metadata": { "id": "custom-reusable-1" },
  "type": "custom-agent-node",
  "configuration": {
    "projectId": "fbb9d7b8-2f67-4ef0-a340-0b729fa5a357"
  }
}
```

Execution semantics:

- backend expands referenced child project workflow into parent graph
- parent inbound/outbound edges are bridged to child entry/exit nodes
- expansion is synchronous, so parent flow continues after child branch completion
- recursive references are rejected (`cycle detected`)

Execution responses include `subWorkflowResolution` when expansion is applied:

- `childReferences`
- `childrenResolved`
- `expandedNodeCount`
- `maxDepthApplied`

Execution submit idempotency:

- send `Idempotency-Key` (or `X-Idempotency-Key`) header to deduplicate retries
- alternatively include `idempotencyKey` in request body
- duplicate submit with same key returns existing execution payload (`idempotentReplay: true`)
- replay dedup also uses a TTL window field: `idempotencyReplayWindowSeconds`
- default replay TTL is runtime property `wayang.runtime.standalone.execution.idempotency.replay-window-seconds` (default `86400`)
- set replay window to `0` to disable replay dedup for that submit

Request correlation:

- send `X-Request-Id` header (or `requestId` in request body) to propagate a stable request correlation id
- API echoes it as `requestId` in execution response and stores it in execution event metadata
- runtime timeline events also include `metadata.telemetry` for node-completed outputs (for orchestrator: budget and execution counters)
  - `executorTelemetry.delegationAttempts`
  - `executorTelemetry.delegationRetries`
  - `executorTelemetry.delegationFailures`
  - `executorTelemetry.delegationTimeouts`
- aggregated runtime telemetry endpoint:
  - `GET /api/v1/projects/{projectId}/executions/{executionId}/telemetry`
  - optional filters: `from` (ISO instant), `to` (ISO instant), `nodeId`, `type`
  - optional grouping: `groupBy=nodeId` or `groupBy=type`
  - optional grouped result controls: `sort=<field>[:asc|desc]`, `limit=<n>`
  - optional debug payload: `includeRaw=true` to include filtered `rawEvents`
  - returns summed delegation counters and latest budget snapshot from execution timeline events
  - full endpoint reference and examples: [Execution Telemetry API](./telemetry-api)

## Agent Provider and Vault References

`agent-config` supports explicit local/cloud provider selection and secret references:

- `providerMode`: `auto` | `local` | `cloud`
- `localProvider` / `cloudProvider`
- `credentialRefs` (reference-only; no raw secret values)
- `vault` backend routing metadata
- agent typed execution fields:
  - basic (`agent-basic`): general agent config + provider/vault fields
  - coder (`agent-coder`): `instruction`, optional `taskType` (default: `GENERATE`)
  - analytic (`agent-analytic`): `question`, optional `taskType` (default: `DESCRIPTIVE`)
  - planner (`agent-planner`): `goal`, `objective`, `instruction`, `strategy`
  - evaluator (`agent-evaluator`): `candidateOutput`, `criteria` (with fallback from `output`/`result`/`content`)
  - orchestrator (`agent-orchestrator`): `objective` or (`agentTasks`, `orchestrationType`, `coordinationStrategy`)

During execution submission, standalone API also records a non-sensitive `agentConfigCoverage`
summary in execution metadata/events (counts of provider configs and credential references;
no secret values).
When `credentialRefs[].path` is relative, execution applies `extensions.vault.pathPrefix`
to build the effective secret path.
For agent executors, runtime also forwards resolved credentials to inference by
mapping `_resolvedCredentials` to Gollek `InferenceRequest.apiKey` using the
selected provider (`preferredProvider` or provider-mode derived provider).
Planner and evaluator executors prioritize typed schema fields above, then fallback
to generic context keys for backward compatibility.

## Agent Type Input Mapping

Recommended typed fields per agent type:

- `agent-basic`
  - execution: generic context payload for common tasks
  - provider selection: `providerMode`, `preferredProvider`, `localProvider`, `cloudProvider`
- `agent-coder`
  - execution: `instruction`
  - optional: `taskType` (`GENERATE`, `REVIEW`, `REFACTOR`, `DEBUG`, `TEST`, ...)
  - provider override: `preferredProvider`
- `agent-analytic`
  - execution: `question`
  - optional: `taskType` (`DESCRIPTIVE`, ...)
  - provider override: `preferredProvider`
- `agent-planner`
  - execution: `goal` (preferred), or `objective` / `instruction`
  - optional: `strategy`, `preferredProvider`
- `agent-evaluator`
  - execution: `candidateOutput` (preferred), fallback `output` / `result` / `content`
  - optional: `criteria`, `preferredProvider`
- `agent-orchestrator`
  - objective mode: `objective` (+ optional `taskType`, `preferredProvider`)
  - orchestration mode: `agentTasks` + optional `orchestrationType`, `coordinationStrategy`
  - loop budgets:
    - `maxIterations` (caps delegated task count)
    - `maxDelegations` (hard cap for delegated agent task count)
    - `maxLatencyMs` (overall orchestration timeout budget)
    - `maxAgentLatencyMs` (per-delegated-agent timeout budget)
    - `maxRetriesPerDelegation` (retry attempts for a failed delegated task)
  - `agentTasks[*].agentType` supports aliases:
    `planner-agent|agent-planner`, `coder-agent|agent-coder`,
    `analytics-agent|agent-analytic`, `evaluator-agent|agent-evaluator`,
    `common-agent|agent-basic`

### Planner / Evaluator Payload Shape

Planner-oriented fragment:

```json
{
  "type": "agent-planner",
  "configuration": {
    "goal": "Design release checklist",
    "strategy": "PLAN_AND_EXECUTE",
    "providerMode": "cloud",
    "cloudProvider": {
      "providerId": "tech.kayys/anthropic-provider",
      "model": "claude-3.5-sonnet"
    }
  }
}
```

Evaluator-oriented fragment:

```json
{
  "type": "agent-evaluator",
  "configuration": {
    "candidateOutput": "Implemented project execution API with tests",
    "criteria": "correctness, robustness, schema compliance",
    "providerMode": "cloud",
    "cloudProvider": {
      "providerId": "tech.kayys/anthropic-provider",
      "model": "claude-3.5-sonnet"
    }
  }
}
```

Example execution payload fragment:

```json
{
  "spec": {
    "workflow": {
      "nodes": [
        {
          "id": "agent-1",
          "type": "agent-basic",
          "configuration": {
            "providerMode": "cloud",
            "cloudProvider": {
              "providerId": "tech.kayys/gemini-provider",
              "model": "gemini-2.0-flash",
              "region": "us-central1"
            },
            "localProvider": {
              "providerId": "tech.kayys/ollama-provider",
              "model": "llama3.2"
            },
            "credentialRefs": [
              {
                "name": "gemini-api-key",
                "backend": "vault",
                "path": "wayang/providers/gemini",
                "key": "apiKey"
              }
            ],
            "vault": {
              "backend": "vault",
              "tenantId": "community",
              "pathPrefix": "wayang/providers"
            }
          }
        }
      ]
    }
  }
}
```

## Catalog Regression Coverage

Runtime includes `SchemaCatalogApiTest` to prevent regressions for:

- `agent-planner` and `agent-evaluator` schema IDs exposed in `/v1/schema/catalog`
- typed fields in schema payloads:
  - planner: `goal`, `strategy`
  - evaluator: `candidateOutput`, `criteria`
- `SchemaApiDynamicGenerationTest` also validates:
  - `agent-orchestrator` schema exposes `goal`, `strategy`, `maxIterations`, `maxDelegations`, `maxLatencyMs`, `maxAgentLatencyMs`, `maxRetriesPerDelegation`
  - `agent-analytic` schema exposes `goal`, `criteria`, `preferredProvider`
