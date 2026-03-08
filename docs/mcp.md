---
layout: default
title: MCP API Coverage
---

# MCP API Test Coverage

The MCP API has automated coverage at two levels in `wayang-tool-core`:

1. API/resource-level tests (direct resource invocation)
2. HTTP-level tests (`@QuarkusTest` + RestAssured)

## Covered Endpoints

MCP Tools (`/api/v1/mcp/tools`):

- `GET /formats`
- `POST /openapi`
- `GET /`
- `GET /{toolId}`
- `POST /{toolId}/execute`
- `PUT /{toolId}`
- `DELETE /{toolId}`

MCP Registry (`/api/v1/mcp/registry`):

- `POST /import`
- `GET /servers`
- `POST /servers/{name}`
- `DELETE /servers/{name}`

## Test Classes

API/resource-level:

- `tech.kayys.wayang.tool.api.ToolResourceTest`
- `tech.kayys.wayang.tool.api.McpRegistryResourceTest`

HTTP-level:

- `tech.kayys.wayang.tool.api.ToolResourceHttpTest`
- `tech.kayys.wayang.tool.api.McpRegistryResourceHttpTest`

## Run MCP Tests

Core API tests:

```bash
mvn -f wayang/executors/tool/wayang-tool-core/pom.xml \
  -Dtest=ToolResourceTest,McpRegistryResourceTest,ToolResourceHttpTest,McpRegistryResourceHttpTest \
  -nsu test
```

MCP module-specific tests:

```bash
mvn -f wayang/executors/tool/wayang-tool-mcp/pom.xml \
  -Dtest=MCPToolExecutorTest,McpResourceTest \
  -nsu test
```

Expected result:

- `wayang-tool-core`: 26 tests, 0 failures/errors
- `wayang-tool-mcp`: 8 tests, 0 failures/errors
