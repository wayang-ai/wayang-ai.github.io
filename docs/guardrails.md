---
layout: default
title: Guardrails API & Execution
parent: Documentation
---

# Guardrails API & Execution

Wayang provides built-in mechanisms to govern and control Agent behaviors via **Guardrails**. The Guardrails ecosystem enforces rules continuously throughout the execution lifecycle of Wayang workflows and agents.

## Guardrails Management API

The Guardrails policy management is managed through a JSON REST API available in the `wayang-guardrails-core` component. This API lets you securely define what constraints exist on the execution of autonomous agents within the platform.

### Base Endpoint
`http://localhost:31713/api/v1/guardrails/policies`

### Supported Operations

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/guardrails/policies` | Retrieve all registered policies (tenant-isolated if `X-Tenant-Id` header provided) |
| `GET` | `/api/v1/guardrails/policies/{id}` | Retrieve a specific policy by its ID |
| `POST` | `/api/v1/guardrails/policies` | Create and store a new policy |
| `PUT` | `/api/v1/guardrails/policies/{id}` | Update an existing policy |
| `DELETE`| `/api/v1/guardrails/policies/{id}` | Delete a policy by its ID |

### Creating a Policy

You can register a new policy by hitting the `POST` endpoint with the following payload structure. A policy defines which detectors are active for specific check phases.

```bash
curl -X POST "http://localhost:31713/api/v1/guardrails/policies" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "policy-01",
    "name": "Strict Ethical Guidelines",
    "description": "Blocks any toxic or PII-violating attempts before and after agent execution.",
    "detectors": [
      {
        "id": "toxicity-detector",
        "configuration": { "threshold": 0.8 },
        "phases": ["PRE_EXECUTION", "POST_EXECUTION"]
      },
      {
        "id": "pii-detector",
        "phases": ["POST_EXECUTION"]
      }
    ],
    "action": "BLOCK"
  }'
```

---

## Agent Integration

Wayang's core agent executor is natively integrated with guardrails via the `GuardrailsService`. 

When a workflow runs an agent node (e.g., `AbstractAgentExecutor`), the execution flow strictly obeys these stages:

1. **`beforeExecute`**: Executes platform-level setup before running the task.
2. **`runGuardrailsPreCheck`** (Guardrails): Extracts context/prompt arguments passed to the agent and checks them against active policies using the registered Guardrails service. 
   - If the pre-check validation fails (e.g., toxicity detected in standard prompts), the pipeline short-circuits.
   - The user will receive a `VALIDATION_ERROR` or `RUNTIME_ERROR` depending on the failure, detailing what triggered the Guardrail block.
3. **`doExecute`**: Run the actual AI logic (Planner, Coder, Evaluator, etc).

### Guardrail Executor Nodes

Guardrails can also be embedded directly in your workflow as an independent node. Using `GuardrailNodeExecutor`, you can force content through validation mid-workflow without needing an agent execution. This enables validations outside the LLM contexts (e.g. validating scraped text, web payloads).
