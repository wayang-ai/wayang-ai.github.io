---
layout: default
title: Wayang AI - AI Agent Workflow Platform
---

<section class="hero">
  <p class="eyebrow">Agentic Workflow Platform</p>
  <h1>Design, execute, and scale multi-agent workflows with Wayang.</h1>
  <p class="lead">Wayang combines a visual workflow designer, multi-agent orchestration, and a hardened runtime so teams can ship AI automation faster without sacrificing control.</p>
  <div class="hero-actions">
    <a class="btn btn-primary" href="/docs/">Get Started</a>
    <a class="btn btn-ghost" href="/features/">Features</a>
    <a class="btn btn-ghost" href="/docs/wayang-assistant">Wayang Assistant</a>
    <a class="btn btn-ghost" href="https://github.com/wayang-ai/wayang-platform">GitHub</a>
  </div>
  <div class="hero-stats">
    <span>Visual Designer</span>
    <span>Orchestrator Loops</span>
    <span>Production Runtime</span>
  </div>
</section>

<section class="quick-grid">
  <a class="quick-card" href="/docs/">
    <h3>Start a Project</h3>
    <p>Bootstrap a workflow and learn the WayangSpec + WorkflowSpec layout.</p>
  </a>
  <a class="quick-card" href="/features/">
    <h3>Explore Features</h3>
    <p>See orchestration, RAG, triggers, guardrails, and HITL coverage.</p>
  </a>
  <a class="quick-card" href="/docs/wayang-assistant">
    <h3>Ask Wayang Assistant</h3>
    <p>Generate projects, ask questions, and troubleshoot errors fast.</p>
  </a>
</section>

<section class="subtle-panel">
  <strong>Latest update:</strong> Wayang Assistant is live with project generation and troubleshooting endpoints.
  <a href="/docs/wayang-assistant">Learn more</a>
</section>

<section class="terminal-demo">
  <h2>Try the CLI Experience</h2>
  <p>Spin up a dev runtime and iterate on workflows quickly.</p>
  <div id="terminal" class="terminal-box" role="img" aria-label="Typing demo showing wayang dev command">
    <span class="prompt">$</span>
    <span
      id="typing-effect"
      data-command="wayang dev"
      data-result="Starting Wayang runtime...&#10;✓ Runtime ready on http://localhost:31713&#10;Designer connected"
    >wayang dev</span>
  </div>
</section>

<section class="subtle-panel hero-compact">
  <strong>Light mode QA:</strong> check hero text, quick cards, tables, and code blocks for contrast and readability.
</section>

---

## Why Wayang AI?

Wayang AI empowers developers and teams to create sophisticated AI-driven automation systems without the complexity. Our platform combines the power of large language models with intuitive workflow orchestration.

### Visual Workflow Designer

Drag-and-drop interface for designing complex agent workflows. No coding required for basic setups, full extensibility for advanced users.

### Multi-Agent Collaboration

Design systems where multiple specialized agents work together, share context, and achieve complex goals through coordinated execution.

### Real-Time Execution Engine

High-performance runtime with support for parallel execution, error handling, and seamless integration with external APIs and services.

### Wayang Assistant

An internal assistant that helps users build Wayang projects, answer questions about the platform, and troubleshoot errors. See the [Wayang Assistant docs](/docs/wayang-assistant).

### Native Vector Memory

Built-in high-performance FAISS vector search engine powered by JDK 25 Foreign Function Memory (FFM). Provides zero-dependency semantic memory for RAG and autonomous agents out of the box with no external databases required.

### Extensible Architecture

Build custom agents, tools, and connectors. Our plugin system makes it easy to extend functionality and integrate with your existing stack.

---

## Quick Start

Get up and running in minutes:

```bash
# Install Wayang AI
npm install -g @wayang-ai/cli

# Create a new project
wayang create my-agent-flow

# Start the development server
wayang dev
```

---

## Use Cases

| Domain | Application |
|--------|-------------|
| Customer Support | Automated ticket routing, intelligent responses, escalation handling |
| Data Processing | ETL pipelines, data validation, transformation workflows |
| Research | Literature review, data extraction, summarization pipelines |
| DevOps | Incident response, monitoring alerts, automated remediation |
| Content Creation | Multi-stage content generation, review workflows, localization |

---

## Community & Support

- [Documentation](/docs/) - Comprehensive guides and API references
- [Discussions](https://github.com/wayang-ai/wayang-platform/discussions) - Ask questions and share ideas
- [Issues](https://github.com/wayang-ai/wayang-platform/issues) - Report bugs and request features

---

## Ready to Build?

Join teams building the future of AI automation.

[Get Started Now](/docs/) &nbsp; [Star on GitHub](https://github.com/wayang-ai/wayang-platform)

---

Wayang AI is open source and available under the [Apache 2.0 License](https://github.com/wayang-ai/wayang-platform/blob/main/LICENSE).
