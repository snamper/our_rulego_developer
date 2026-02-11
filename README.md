# RuleGo Expert Developer Skill (our_rulego_developer)

**RuleGo 规则引擎专家**。本技能用于处理 [RuleGo](https://rulego.cc/) 规则链开发、组件编排、自定义组件实现以及 Endpoint 集成。

> 🧠 **Core Intelligence**: 集成了基于 **505 条真实线上规则链** 的深度分析成果，提供经过实战验证的最佳配置模版。

## ✨ 核心能力

- **🏗️ 规则链编排**: 提供符合[中英双语命名规范](references/development-standards.md)的 DSL 生成。
- **🔌 Endpoint集成**: 零代码配置 HTTP, MQTT, WebSocket, Cron 接入点。
- **🛠️ 组件开发**: 提供标准化的、解耦的 Go 自定义组件模版。
- **📚 参数金典**: 防止配置错误的[组件参数详解](references/component-catalog.md)。
- **🤖 AI Tool化**: 支持将规则链一键转化为 MCP (Model Context Protocol) 工具。

## 📦 安装 (Installation)

### 作为 Claude/Cursor 技能安装

将本仓库链接到您的 AI 助手技能目录：

```bash
# MacOS / Linux
ln -s "$(pwd)" ~/.gemini/antigravity/skills/our_rulego_developer
```

### 依赖环境

推荐使用 `rulego/examples/server` 作为运行环境：

```bash
git clone https://github.com/rulego/rulego.git
cd rulego/examples/server
go build -o rulego-server cmd/server/main.go
```

## 🚀 使用指南 (Usage)

直接在对话中呼唤 **"阿沃"** 或使用以下指令：

| 场景 | Prompt 示例 |
| :--- | :--- |
| **查参数** | "阿沃，帮我查一下 `restApiCall` 的完整 JSON 配置参数。" |
| **写 DSL** | "阿沃，我要做一个温度报警规则链：`temp > 50` 时发 HTTP 请求。" |
| **写代码** | "阿沃，给我一个自定义组件的 Go 模版，用于计算 MD5。" |
| **部署** | "阿沃，部署这个规则链到 Server。" |

## 📂 文档索引 (Documentation)

详细的技术文档均位于 `references/` 目录：

- **基础**: [组件参数金典](references/component-catalog.md) | [DSL Schema](references/rule-chain-schema.md)
- **接入**: [Endpoint 配置指南](references/endpoint.md)
- **进阶**: [StreamSQL 流计算](references/streamsql.md) | [AOP 切面编程](references/aop.md) | [MCP 集成](references/mcp-server.md)
- **规范**: [开发准则](references/development-standards.md) | [Server 开发模式](references/server-development.md)

## ⚖️ 开发准则 (Standards)

1.  **Server-First**: 保持 Server 源码结构不变，仅通过 `extensions` 扩展。
2.  **配置驱动**: 业务逻辑参数化，禁止硬编码。
3.  **命名规范**: 严格遵循 `中文名称 EnglishName` 格式。

---
*Created for efficient RuleGo development.*
