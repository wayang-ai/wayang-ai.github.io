---
layout: default
title: Documentation
---

# Documentation

Get started with Wayang AI and learn how to build powerful AI agent workflows.

---

## Quick Start Guide

### 1. Installation

Install the Wayang AI CLI tool:

```bash
npm install -g @wayang-ai/cli
```

Or use npx for one-off commands:

```bash
npx @wayang-ai/cli
```

### 2. Create Your First Project

```bash
# Create a new project
wayang create my-first-workflow

# Navigate to the project
cd my-first-workflow
```

### 3. Configure Your API Keys

Set up your AI provider credentials:

```bash
# For OpenAI
wayang config set OPENAI_API_KEY your-api-key

# For Anthropic
wayang config set ANTHROPIC_API_KEY your-api-key
```

### 4. Create a Simple Workflow

Create a file named `workflow.yaml`:

```yaml
name: Hello World
description: A simple greeting workflow

agents:
  - id: greeter
    type: llm
    model: openai/gpt-4
    prompt: "Greet the user and ask how you can help them today."

execution:
  start: greeter
```

### 5. Run Your Workflow

```bash
# Development mode with hot reload
wayang dev

# Or run once
wayang run workflow.yaml
```

---

## Core Concepts

### Agents

Agents are the building blocks of Wayang AI workflows. Each agent has a specific role and capabilities.

```yaml
agents:
  - id: researcher
    type: llm
    model: openai/gpt-4
    prompt: "Research the topic and provide a summary."
    tools:
      - web_search
      - file_read
```

### Workflows

Workflows define how agents collaborate to achieve a goal.

```yaml
workflow:
  name: Research Assistant
  agents:
    - researcher
    - writer
    - reviewer
  
  flow:
    - researcher -> writer
    - writer -> reviewer
    - reviewer -> (end)
```

### Tools

Tools extend agent capabilities with external integrations.

```yaml
tools:
  - name: web_search
    type: builtin
    provider: google
  
  - name: database
    type: custom
    connection: postgres://localhost/mydb
```

---

## CLI Reference

| Command | Description |
|---------|-------------|
| `wayang create <name>` | Create a new project |
| `wayang dev` | Start development server |
| `wayang run <workflow>` | Execute a workflow |
| `wayang deploy` | Deploy to production |
| `wayang logs` | View execution logs |
| `wayang config` | Manage configuration |
| `wayang agents` | List available agents |
| `wayang --help` | Show help information |

---

## Configuration Reference

### Environment Variables

```bash
# Required
WAYANG_API_KEY=your-wayang-api-key

# AI Providers
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_API_KEY=...

# Optional
WAYANG_LOG_LEVEL=debug
WAYANG_PORT=3000
WAYANG_ENV=development
```

### Project Configuration (wayang.config.js)

```javascript
module.exports = {
  name: 'my-workflow',
  version: '1.0.0',
  
  agents: {
    default: {
      model: 'openai/gpt-4',
      temperature: 0.7,
    },
  },
  
  execution: {
    timeout: 30000,
    retries: 3,
  },
  
  integrations: {
    slack: {
      webhook: process.env.SLACK_WEBHOOK,
    },
  },
};
```

---

## Advanced Topics

### Multi-Agent Collaboration

Design workflows where multiple agents work together:

```yaml
workflow:
  name: Content Pipeline
  
  agents:
    - id: researcher
      prompt: "Research the topic thoroughly."
    
    - id: writer
      prompt: "Write an engaging article based on research."
    
    - id: editor
      prompt: "Review and improve the content."
  
  flow:
    - researcher
    - writer (depends_on: researcher)
    - editor (depends_on: writer)
    - end (depends_on: editor)
```

### Custom Agents

Create specialized agents for your use case:

```javascript
// agents/customer-support.js
module.exports = {
  name: 'customer-support',
  
  async execute(context) {
    const { message, history } = context;
    
    // Analyze sentiment
    const sentiment = await this.analyzeSentiment(message);
    
    // Route based on urgency
    if (sentiment.urgency > 0.8) {
      return { escalate: true, reason: 'High urgency detected' };
    }
    
    // Generate response
    const response = await this.generateResponse(message, history);
    
    return { response, sentiment };
  },
};
```

### Error Handling

Implement robust error handling in your workflows:

```yaml
workflow:
  name: Resilient Workflow
  
  agents:
    - id: main
      on_error:
        retry: 3
        fallback: backup_agent
  
  execution:
    timeout: 60000
    on_timeout:
      notify: slack
      action: escalate
```

---

## API Reference

### REST API

```bash
# Start a workflow execution
curl -X POST https://api.wayang.ai/v1/executions \
  -H "Authorization: Bearer $WAYANG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"workflow": "my-workflow", "input": {"key": "value"}}'

# Get execution status
curl https://api.wayang.ai/v1/executions/{execution_id} \
  -H "Authorization: Bearer $WAYANG_API_KEY"
```

### SDK Usage

```typescript
import { WayangClient } from '@wayang-ai/sdk';

const client = new WayangClient(process.env.WAYANG_API_KEY);

// Execute a workflow
const execution = await client.execute('my-workflow', {
  input: { topic: 'AI Agents' },
});

// Wait for completion
const result = await execution.waitForCompletion();
console.log(result.output);
```

---

## Troubleshooting

### Common Issues

**Agent not responding**
- Check API key configuration
- Verify model availability
- Review rate limits

**Workflow fails to start**
- Validate YAML syntax
- Check agent definitions
- Ensure all dependencies are installed

**Slow execution**
- Enable parallel processing
- Optimize agent prompts
- Consider caching responses

---

## Need Help?

- 📚 [Full Documentation](https://docs.wayang.ai)
- 💬 [Community Discord](https://discord.gg/wayang-ai)
- 🐛 [Report an Issue](https://github.com/wayang-ai/wayang-platform/issues)
- 📝 [Examples Repository](https://github.com/wayang-ai/examples)

---

[Back to Home](/) &nbsp; [View Features](/features/)
