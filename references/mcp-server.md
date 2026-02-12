# RuleGo-MCP-Server 集成说明

RuleGo 已经支持 **MCP (Model Context Protocol)**，这意味着所有的规则链都可以无缝转化为 AI Agent 的工具。

## 1. 什么是 RuleGo-MCP-Server？

RuleGo Server 内置了对 MCP 协议的支持。只要启动 Server，它就会根据配置文件将当前的规则链暴露为 MCP Tool，供 Claude、Cursor 等 AI 客户端直接调用。

## 2. 启用方法

在 `config.conf` 中配置（通常默认开启）：

```toml
[mcp]
  # 是否开启 mcp 功能
  enable = true
  # 暴露规则链为工具
  load_chains_as_tool = true
```

## 3. 规则链配置 (Input Schema)

AI 如何知道这个工具怎么用？通过规则链的 `additionalInfo` 字段定义：

```json
{
  "ruleChain": {
    "id": "weather_query",
    "name": "查询天气 QueryWeather",
    "additionalInfo": {
      "description": "根据城市名查询实时天气信息",
      "inputSchema": {
        "type": "object",
        "properties": {
          "city": {
            "type": "string",
            "description": "城市名称，如 Beijing"
          }
        },
        "required": ["city"]
      }
    }
  }
}
```

## 4. MCP 工具规则链设计准则

1.  **输入规范**: `${msg.city}` 对应 Schema 中的属性。
2.  **单一职责**: 仅仅做计算或查询，不要包含复杂的副作用（除非那就是工具的目的）。
## 1. MCP 集成模式 (Integration Modes)

RuleGo-Server 支持两种维度的 MCP 集成，满足不同的工具暴露需求。

### 1.1 租户级集成 (Tenant Level)
*   **接口**: `/api/v1/mcp/:apiKey/sse`
*   **功能**: 将指定租户下的**所有规则链**作为独立的 MCP 工具暴露给 AI。
*   **特性**: 粒度粗，适合需要 AI 调度全局任务的场景。

### 1.2 规则链级集成 (Chain Level)
*   **接口**: `/api/v1/rules/{chainId}/mcp/sse`
*   **功能**: 仅将**当前规则链中配置的工具节点**作为 MCP 工具暴露。
*   **注意**: 这种模式需要配置 MCP Server Endpoint，将规则链内部编排的组件转化为 AI 可调用的能力。

---

## 2. 客户端配置示例 (Client Configuration)

以下是将 RuleGo-Server 工具集成到 AI Agent（如 Claude Desktop）的配置 JSON：

```json
{
  "mcpServers": {
    "hbc_test": {
      "url": "http://127.0.0.1:9090/api/v1/rules/MZo3g9SGaJBW/mcp/sse"
    }
  }
}
```

---

## 3. 核心差异总结
| 集成维度 | 访问路径 | 暴露内容 |
| :--- | :--- | :--- |
| **租户级** | `/api/v1/mcp/:id/sse` | 所有规则链 |
| **规则链级** | `/api/v1/rules/:id/mcp/sse` | 该链内的组件工具 |

## 3. 调用方式选择
*   **Tool 调用**: 当通过 MCP 触发工具时，底层会自动映射到对应的节点执行。
*   **数据隔离**: 通过 apiKey 实现租户级别的数据与权限隔离。
