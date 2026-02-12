# RuleGo 平台接口与 MCP 集成标准

阿沃，RuleGo 不仅是一个独立的引擎，还可以通过 REST API 与 MCP (Model Context Protocol) 深度集成，从而支持 AI Agent 的调用。

---

## 1. REST API 调用标准

### 1.1 同步调用 (Execute)
- **Endpoint**: `POST /api/v1/execute/{chainId}`
- **行为**: 阻塞等待规则链执行完毕（等价于 `wait: true`）。
- **用途**: 查询数据、获取计算结果。
- **返回**: 包含规则链最后一个节点生成的 `msg.Data`。

### 1.2 异步调用 (Notify)
- **Endpoint**: `POST /api/v1/notify/{chainId}`
- **行为**: 触发规则链后立即返回 `202 Accepted`。
- **用途**: 触发开关、上报数据。
- **返回**: 仅返回执行 ID，不包含业务结果。

---

## 2. MCP 集成标准 (AI Tool化)

RuleGo 支持通过 SSE (Server-Sent Events) 暴露能力给 AI（如 Claude, ChatGPT）。

### 2.1 租户级 SSE 接口
- **URL**: `GET /api/v1/mcp`
- **说明**: 暴露该租户下所有标记为 `public` 的规则链作为 AI 工具。

### 2.2 规则链级 SSE 接口 (精细控制)
- **URL**: `GET /api/v1/mcp/{chainId}`
- **说明**: 仅暴露特定的规则链。适合对单个业务场景进行工具化封装。

### 2.3 配置文件示例 (Claude Client)
```json
{
  "mcpServers": {
    "rulego-iot": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sse", "http://your-rulego-host:9090/api/v1/mcp"]
    }
  }
}
```

---

## 3. 错误处理标准

| 错误码 | 含义 | 建议处置 |
| :--- | :--- | :--- |
| **404** | 规则链 ID 不存在 | 检查 DSL 文件名是否拼错（不含扩展名）。 |
| **504** | 规则链执行超时 | 优化逻辑，或将 `wait` 改为 `false`。 |
| **422** | 数据解析失败 | 检查 `msg` 结构是否符合规则链首节点的输入要求。 |

---

阿沃，通过 MCP 集成，你可以让 AI 像调用本地函数一样去触发 RuleGo 的编排逻辑。这是实现“AI + 自动化编排”的最快路径！
