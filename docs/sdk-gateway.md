---
layout: default
title: Gollek SDK Gateway & SPI
parent: Documentation
nav_order: 12
---

# Gollek SDK Gateway & SPI

Wayang AI's core inference engine relies on the **Gollek SDK**, a unified facade and SPI (Service Provider Interface) that connects Wayang to virtually any generative AI or embedded execution model. 

---

## 🔌 The `gollek-sdk` SPI Architecture

Wayang decoupled from hardcoded dependency modules entirely, instead wiring its engine up only to `tech.kayys.gollek:gollek-sdk`. 

The SDK acts as an ecosystem bridge, enabling:
- **Dynamic Provider Discovery**: Local runtime JVMs discover supported models via ServiceLoaders (e.g., picking up `OpenAIProvider`, `AnthropicProvider`, `OllamaProvider`).
- **Unified DTOs**: Consistent data transfer patterns (`InferenceRequest`, `Message`, `ToolCall`) regardless of the underlying LLM protocol quirks.
- **MCP Server Discovery**: Connects the inference engine with embedded or remote Model Context Protocol (MCP) servers seamlessly.

### Example: Gollek SDK Provider Registration via CDI
Wayang's internal `GollekSdkProducer` handles SDK instantiation efficiently at boot through standard Quarkus configurations:

```java
@Produces
@ApplicationScoped
public GollekSdk produceGollekSdk() {
    return GollekSdk.builder()
            // Customizes configuration hooks...
            .build();
}
```

---

## 🚀 Streaming & Chunk Delegation

One of the largest benefits of moving inference generation through `gollek-sdk` is high-performance streaming. Through the SDK's `inferStream` method, Wayang's `SkillBasedAgentExecutor` handles generative streams natively.

Rather than waiting for the entire loop to finish sequentially, Wayang's agent API can surface `StreamChunk` emissions up to the end-users instantly, creating responsive front-end experiences out-of-the-box.

---

## 🧩 Model Context Protocol (MCP)

`gollek-sdk` natively bridges to standard Model Context Protocol servers. This means an agent can discover system-level tools, read local file systems, connect to remote GitHub actions, or search Slack.

Wayang connects through `McpRegistryManager` during inference setup, enriching the prompt injection loop seamlessly!
