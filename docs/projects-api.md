---
layout: default
title: Projects API
---

# Projects API

Base path:

- `/api/v1/projects`

Implementation modules:

- Core API resources and supports live in `wayang/core/wayang-api`.
- Standalone runtime (`wayang/runtime/wayang-runtime-standalone`) depends on `wayang-api` and provides runtime wiring/configuration.

Identity headers used by standalone runtime:

- `X-Tenant-Id` (defaults to `community` when omitted)
- `X-User-Id` (recommended for access/consent evaluation)

## Core Endpoints

- `GET /api/v1/projects`
- `GET /api/v1/projects/shareable?mode=callable`
- `POST /api/v1/projects`
- `GET /api/v1/projects/{projectId}`
- `GET /api/v1/projects/{projectId}/callable-contract`
- `POST /api/v1/projects/{projectId}/validate-callable`
- `POST /api/v1/projects/{projectId}/preview-output-bindings`
- `PUT /api/v1/projects/{projectId}`
- `DELETE /api/v1/projects/{projectId}`

Execution endpoints:

- `POST /api/v1/projects/{projectId}/executions`
- `POST /api/v1/projects/{projectId}/execute-spec` (alias)
- `GET /api/v1/projects/{projectId}/executions`
- `GET /api/v1/projects/{projectId}/executions/{executionId}`
- `GET /api/v1/projects/{projectId}/executions/{executionId}/events`
- `GET /api/v1/projects/{projectId}/executions/{executionId}/telemetry`
- `GET /api/v1/projects/{projectId}/executions/{executionId}/lineage`
- `POST /api/v1/projects/{projectId}/executions/{executionId}/stop`
- `POST /api/v1/projects/{projectId}/executions/{executionId}/resume`
- `DELETE /api/v1/projects/{projectId}/executions/{executionId}`

Debugger endpoints (standalone):

- `GET /api/v1/debug/projects/{projectId}/executions/{executionId}/events`
- `GET /api/v1/debug/projects/{projectId}/executions/{executionId}/telemetry`
- `GET /api/v1/debug/projects/{projectId}/executions/{executionId}/lineage`
- `GET /api/v1/debug/projects/{projectId}/executions/{executionId}/snapshot`

## Create Project

```bash
curl -X POST "http://localhost:31713/api/v1/projects" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-a" \
  -H "X-User-Id: alice" \
  -d '{
    "name": "parent-project",
    "metadata": { "createdBy": "alice" },
    "spec": {
      "specVersion": "1.0.0",
      "workflow": { "nodes": [], "connections": [] }
    }
  }'
```

## Execute Project Spec

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/executions" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-a" \
  -H "X-User-Id: alice" \
  -H "Idempotency-Key: req-001" \
  -d '{
    "name": "run-1",
    "dryRun": false,
    "parentExecutionId": "parent-exec-001",
    "parentProjectId": "parent-project-001",
    "parentNodeId": "custom-agent-node-1",
    "relationType": "subworkflow",
    "correlationId": "corr-123",
    "maxSubWorkflowDepth": 2,
    "spec": {
      "specVersion": "1.0.0",
      "workflow": { "nodes": [], "connections": [] }
    }
  }'
```

Notes:

- `dryRun: true` (or `validateOnly: true`) validates only and does not run workflow.
- request accepts `spec`, `wayangSpec`, or `workflowSpec`.
- optional execution-correlation fields:
  - `parentExecutionId`
  - `parentProjectId`
  - `parentNodeId`
  - `relationType` (for example: `subworkflow`)
  - `correlationId`
- if provided, runtime stores `executionContext` and exposes it in:
  - `POST /executions` accepted response
  - `GET /executions/{executionId}` status response
  - `GET /executions/{executionId}/events` metadata
  - `GET /executions/{executionId}/telemetry`

## Sub-Workflow Reference (Custom Agent Node)

```json
{
  "metadata": { "id": "custom-reusable-1" },
  "type": "custom-agent-node",
  "configuration": {
    "projectId": "{childProjectId}"
  }
}
```

Runtime resolves `projectId` at execution time (reference-only contract).

Shareable picker endpoint (for custom agent selection in UI):

```bash
curl -H "accept: application/json" \
  -H "X-Tenant-Id: tenant-b" \
  -H "X-User-Id: bob" \
  "http://localhost:31713/api/v1/projects/shareable?mode=callable"
```

Response includes callable contract metadata for UI mapping:

- `callable.mode`: `callable` or `autonomous`
- `callable.entrypoint.type`: `manual` | `parameterized` | `empty` | `trigger`
- `callable.version`: child contract version/snapshot marker
- `callable.inputs.required[]` / `callable.inputs.optional[]`
- `callable.output` (if declared)

When execution or dry-run expands sub-workflow nodes, response includes:

- `subWorkflowResolution.childReferences`
- `subWorkflowResolution.childrenResolved`
- `subWorkflowResolution.trace[]` with:
  - `childId`, `projectId`, `depth`
  - `parentNodeId`, `parentProjectId`
  - `callableMode`, `entrypointType`, `version`
  - `bindingSummary`:
    - `inputKeys`, `inputCount`
    - `outputBindingSources`, `outputBindingTargets`, `outputBindingCount`

Lineage-focused endpoint for UI:

```bash
curl -H "accept: application/json" \
  "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/lineage?view=compact&nodeId=custom-agent-1&sort=depth:desc&limit=20&offset=0&fields=childId,parentNodeId,depth&include=executionContext,status"
```

Response includes:

- `view`: `full` | `compact`
- `nodeId`: filter applied to `trace[]` using `parentNodeId` or `childId`
- `sort`: e.g. `depth:desc`, `childId:asc`, `parentNodeId:asc`
- `limit`, `offset`
- `fields`: accepted trace projection keys after allowlist filtering
- `ignoredFields`: requested projection keys that are not supported and were ignored
- `include`: accepted top-level sections after allowlist filtering
- `ignoredIncludes`: requested top-level sections that are not supported and were ignored
- `traceCount`
- `totalTraceCount` (before filter)
- `filteredTraceCount` (after filter, before pagination)
- `trace[]` (lineage + binding summary)
- `subWorkflowResolution` (included by default in `view=full`)
- `executionContext` (included by default in both `full` and `compact`)
- `status`, `updatedAt` (included by default in `view=full`)

Accepted `fields` and `include` values are returned in server-defined canonical order, not request order.

Supported `fields` keys for `trace[]` projection:

- `projectId`
- `childProjectId`
- `childId`
- `parentNodeId`
- `parentProjectId`
- `depth`
- `invokeMode`
- `waitForCompletion`
- `bindingSummary`

Supported `include` keys for top-level lineage projection:

- `executionContext`
- `subWorkflowResolution`
- `status`
- `updatedAt`

Direct contract endpoint:

```bash
curl -H "accept: application/json" \
  -H "X-Tenant-Id: tenant-b" \
  -H "X-User-Id: bob" \
  "http://localhost:31713/api/v1/projects/{projectId}/callable-contract"
```

Contract validation endpoint (preflight for node configuration):

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/validate-callable" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-b" \
  -H "X-User-Id: bob" \
  -d '{
    "nodeId": "custom-agent-1",
    "configuration": {
      "projectId": "{projectId}",
      "projectVersion": "v2",
      "inputs": {
        "ticketId": "INC-123"
      },
      "outputBindings": {
        "summary": "context.child.summary"
      }
    }
  }'
```

Output mapping preview endpoint:

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/preview-output-bindings" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-b" \
  -H "X-User-Id: bob" \
  -d '{
    "configuration": {
      "projectId": "{projectId}",
      "outputBindings": {
        "summary": "context.child.summary"
      }
    }
  }'
```

Response highlights:

- `valid`: whether all source output fields exist in child callable output contract
- `validSources`: available source fields (`*` wildcard included)
- `invalidSources`: unknown/mismatched fields
- `bindings`: normalized valid bindings

## Cross-Tenant Share + Consent Flow

1. Owner creates child project as private.
2. Owner updates child metadata access policy to share with target tenant/user.
3. Requester executes parent project that references child by `projectId`.

### Access Metadata Example

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

Resolver rules:

- owner always allowed
- `visibility`: `private | tenant | explicit | public`
- if `requireConsent=true`, non-owner requires matching `consentGrants.permission=execute_subworkflow`

If access fails, execution submission is rejected during sub-workflow expansion.

## Callable Contract Rules for Sub-Workflow Execution

When parent workflow references child `projectId`:

- child must resolve to `callable.mode = callable`
- callable entrypoint must be one of:
  - `manual`
  - `parameterized`
  - `empty`
- autonomous/trigger-start children are rejected as sub-workflow references

For `entrypoint.type = parameterized`:

- parent node must provide required inputs via one of:
  - `configuration.inputs`
  - `configuration.parameters`
  - `configuration.inputBindings`
- required input names are validated against contract
- primitive type compatibility is validated (`string`, `number`, `integer`, `boolean`, `array`, `object`)
- if parent pins `projectVersion`, runtime validates child callable version before execution
- `outputBindings` keys must match declared child `callable.output.properties` (or `*`)

## Structured Execution Error (Invalid Workflow Definition)

When runtime detects workflow-definition invalidity in execution phase, API returns:

- HTTP `400`
- `errorCode = EXECUTION_WORKFLOW_INVALID`
- `details.phase = workflow-definition-validation`

This makes invalid-graph failures distinguishable from generic internal errors.

Example node:

```json
{
  "metadata": { "id": "child-1" },
  "type": "custom-agent-node",
  "configuration": {
    "projectId": "child-project-id",
    "inputs": {
      "ticketId": "INC-123",
      "priority": 5
    }
  }
}
```

## Permission Matrix

`allow` below means requester can reference child `projectId` during parent execution.

| Requester | private | tenant | explicit | public |
| --- | --- | --- | --- | --- |
| Owner (`ownerTenantId` + `ownerUserId`) | allow | allow | allow | allow |
| Same tenant, different user | deny (unless explicitly shared; standalone may allow if no user context) | allow | deny unless shared | allow |
| Different tenant, shared tenant | deny | allow if tenant shared | allow if tenant shared | allow |
| Different tenant, shared user | deny | allow if user shared | allow if user shared | allow |
| Unshared external requester | deny | deny | deny | allow |

Consent overlay (`requireConsent=true`):

- owner stays allowed
- non-owner rows above require matching `consentGrants` entry with:
  - `tenantId` + `userId` matching requester
  - `permission = execute_subworkflow`
- without matching grant: deny

## Related Docs

- [Schema Catalog and WayangSpec](./schema-catalog)
- [Execution Telemetry API](./telemetry-api)
- [Debugger API](./debugger-api)
- [Standalone Troubleshooting](./standalone-troubleshooting)
