---
layout: default
title: Trigger Integrations
---

# Trigger Integrations

Server-side trigger execution maps schema parameters into runtime output and integration behavior for:

- `start`
- `trigger-manual`
- `trigger-schedule`
- `trigger-email`
- `trigger-telegram`
- `trigger-websocket`
- `trigger-webhook`
- `trigger-event`
- `trigger-kafka`
- `trigger-file`

Each trigger node returns `triggerIntegration` in execution output.

Example:

```json
{
  "triggerType": "trigger-email",
  "triggeredAt": "2026-03-06T09:00:00Z",
  "triggerIntegration": {
    "integrationMode": "simulated",
    "liveRequested": false,
    "liveEnabled": false,
    "status": "simulated",
    "from": "ops@example.com",
    "subjectContains": "approval"
  }
}
```

## Live vs Simulated Mode

Live integration and probe behavior are configurable:

```properties
wayang.trigger.integration.live.enabled=false
wayang.trigger.integration.live.probe.enabled=false
wayang.trigger.integration.live.email.enabled=false
wayang.trigger.integration.live.telegram.enabled=false
wayang.trigger.integration.live.kafka.enabled=false
wayang.trigger.integration.live.file.enabled=true
```

When live mode is disabled or unavailable, runtime falls back to `simulated` mode.

## Validation and Coverage

Automated tests cover:

- all supported trigger types
- schema parameter mapping into `triggerIntegration`
- live/simulated fallback behavior
- probe and error-path handling
