---
layout: default
title: HITL Flow
---

# HITL Execution Flow

`hitl-human-task` provides a manual checkpoint in workflow execution.

## Runtime Lifecycle

1. Workflow executes until a HITL node.
2. Execution transitions to waiting/paused.
3. Client submits human decision/data using resume endpoint.
4. Execution continues from checkpoint.

Resume request:

```bash
curl -X POST "http://localhost:31713/api/v1/projects/{projectId}/executions/{executionId}/resume" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "humanTaskId": "task_123",
    "data": {
      "approved": true,
      "comment": "continue execution"
    }
  }'
```

## Designer Support

In Wayang Designer, you can insert a checkpoint with:

- right-click a node
- choose `Insert HITL Checkpoint`

This inserts a `hitl-human-task` node and rewires outgoing edges through the checkpoint.

## Execution Events and Persistence

Execution metadata:

```bash
~/.wayang/logs/server/cloud-project-executions.json
```

Execution event timeline:

```bash
~/.wayang/logs/server/cloud-project-execution-events.json
```

## Test Coverage

Coverage includes:

- project execution lifecycle behavior used by HITL pause/resume
- integration tests for execution API flow around waiting/resume semantics
