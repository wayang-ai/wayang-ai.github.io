---
layout: default
title: Wayang Kulit Release Notes
---

# Wayang Kulit Release Notes

## 2026-03-07

### Execution and Runtime

- Added execute submit correlation via `X-Request-Id`.
- Added idempotent execution submit via `Idempotency-Key`.
- Added execute endpoint fallback from:
  - `POST /api/v1/projects/{projectId}/executions`
  - to `POST /api/v1/projects/{projectId}/execute-spec` when needed.
- Added retry execution action from execution details dialog.
- Added optional auto dry-run gate before execution.

### Lifecycle Concurrency

- Added optimistic concurrency support for stop/resume/delete lifecycle actions:
  - `If-Match` header
  - `expectedVersion` body field (stop/resume when parseable).
- Added clearer `409` version conflict messaging in UI.

### Observability and Polling

- Added conditional execution status polling with `ETag` / `If-None-Match`.
- Added conditional timeline events polling with `ETag` / `If-None-Match`.
- Added `304 Not Modified` handling to reduce polling payload churn.
- Added events response compatibility for both:
  - list payload: `[...]`
  - object payload: `{ "events": [...] }`.

### Failure Debugging UX

- Added latest failed node detection from timeline events.
- Added pinned failed node highlight on canvas.
- Added app bar quick actions:
  - focus pinned failed node
  - clear pinned failed node.
- Added one-time-per-execution auto-open failure details behavior.

### Shortcuts and Settings

- Added shortcuts:
  - `F` to focus pinned failed node
  - `Shift+F` to clear pinned failed node.
- Added keyboard shortcuts help entry in Settings.
- Added toggles:
  - auto dry run before execute
  - auto focus failed node
  - auto-open failure details.

### Docs

- Added dedicated user guide:
  - [Wayang Kulit User Guide](./designer-user-guide)

