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
3.  **返回结果**: 最后一个节点应该是 `jsTransform` 或其他能修改 `msg` 的节点。RuleGo 会将最终的 `msg.data` 作为 Tool Result 返回给 AI。

## 5. 连接 AI

使用 MCP 客户端（如 Claude Desktop）配置 endpoint:

```json
{
  "mcpServers": {
    "rulego": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "rulego/server", "run-mcp"]
    }
  }
}
```
*(注：Server 模式下通常通过 SSE 连接，详情参考 Server 文档)*
