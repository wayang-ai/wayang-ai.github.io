---
layout: default
title: Wayang Kulit User Guide
---

# Wayang Kulit User Guide

This guide covers daily usage of the Wayang Kulit desktop app, including local/cloud project handling, workflow execution, failure debugging, and logs.

---

## What’s New in Designer

Recent desktop improvements:

- persistent sign-in/session behavior
- execute flow with request correlation and idempotent submit
- execute fallback alias support (`/execute-spec`)
- retry execution from details dialog
- automatic startup failure handling with optional auto-open details
- pinned failed node with canvas highlight and quick focus/clear
- keyboard shortcuts for failed node focus (`F`) and clear (`Shift+F`)
- conditional status/events polling with ETag (`304 Not Modified`)
- enhanced logs viewer with selectable/copyable content

See full changelog:

- [Wayang Kulit Release Notes](./designer-release-notes)

---

## 1. Start and Create/Open a Project

When the app launches, Quick Start can show:

- **Start Blank**
- **Open Local File** (`.wayang` / `.json`)
- **Pick Template**

You can toggle this in **Settings** with **Show Quick Start on Launch**.

---

## 2. Save and Open Projects

Use the **Storage** menu in the top bar:

- **Save Local**: save current project to file (`.wayang` recommended)
- **Open Local**: load project from local file
- **Save**: save to current cloud project on local control server
- **Save As**: create/select another cloud project and save there
- **Open Cloud**: pick a project from server list

If cloud API is unavailable, Designer keeps local fallback cache for demo/standalone flow.

---

## 3. Execute Workflow

Use **Runtime -> Execute Workflow**.

Execution flow:

1. Ensure cloud project is active (Designer prompts to save first if needed).
2. Provide execution name, description, and optional JSON `inputs`.
3. Designer submits current route as `spec` (`WayangSpec`) to:
   - `POST /api/v1/projects/{projectId}/executions`
   - fallback alias: `POST /api/v1/projects/{projectId}/execute-spec`

Designer sends:

- `X-Request-Id` for request correlation
- `Idempotency-Key` for safe retries/dedup
- `idempotencyReplayWindowSeconds` in payload

If enabled in **Settings**, **Auto Dry Run Before Execute** shows a validation/spec preview before submit.

---

## 4. Monitor Executions

From **Runtime -> Execution History**:

- refresh status
- stop/resume execution
- delete execution record
- open details

Execution lifecycle actions support optimistic concurrency where version token is available:

- `If-Match` header
- `expectedVersion` body field (for stop/resume)

`409` version conflict means refresh and retry.

---

## 5. Execution Details and Timeline

Execution details dialog includes:

- live status polling
- timeline event filter/search
- jump-to-node from event
- export timeline JSON/CSV
- copy visible timeline JSON
- retry execution

Polling uses conditional fetch when server provides ETag:

- status endpoint: `If-None-Match` + `304 Not Modified`
- events endpoint: `If-None-Match` + `304 Not Modified`

Events payload shapes supported by Designer:

- direct list: `[...]`
- wrapped object: `{ "events": [...] }`

---

## 6. Failure Debugging (Pinned Failed Node)

When timeline contains a failing event with `nodeId`, Designer pins that node as latest failed node.

Features:

- auto-focus failed node (configurable in Settings)
- app bar chip: **Failed: ...** to focus quickly
- clear pinned failed node from app bar or details dialog
- node is highlighted on canvas until cleared

Shortcuts:

- `F`: focus pinned failed node
- `Shift+F`: clear pinned failed node

---

## 7. Logs

Open **View Logs** from top bar.

Designer logs:

```bash
~/.wayang/logs/designer/
```

Server logs:

```bash
~/.wayang/logs/server/
```

Viewer supports:

- log source switch (designer/server)
- file list and content view
- raw text and JSON-friendly viewing
- copy text/content
- selectable text

---

## 8. Recommended Settings

For standalone desktop usage:

- enable **Auto Dry Run Before Execute**
- enable **Auto Focus Failed Node**
- enable **Auto-open Failure Details**
- enable **Auto Reveal Exported Files** (optional)

---

## 9. Upgrade Checklist

Use this checklist after updating Designer:

1. Open **Settings** and verify:
   - **Auto Dry Run Before Execute**
   - **Auto Focus Failed Node**
   - **Auto-open Failure Details**
2. Run one test execution and confirm:
   - execution starts from **Runtime -> Execute Workflow**
   - request/submit feedback appears in snackbar/logs
3. Open **Execution History** and validate lifecycle actions:
   - stop/resume/delete work as expected
   - if `409` appears, refresh and retry (version conflict handling)
4. Open execution details and check:
   - timeline polling updates
   - jump-to-node works from events
   - retry execution works
5. Trigger a controlled failure and verify:
   - failed node is pinned/highlighted
   - app bar **Failed: ...** focus/clear works
   - shortcuts `F` and `Shift+F` work
6. Validate storage paths and logs:
   - Designer logs at `~/.wayang/logs/designer/`
   - Server logs at `~/.wayang/logs/server/`
7. If using local control API, verify execution endpoint compatibility:
   - `/api/v1/projects/{projectId}/executions`
   - fallback `/api/v1/projects/{projectId}/execute-spec`
