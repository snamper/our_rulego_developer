# RuleGo Endpoint 动态配置指南 (JSON DSL)

阿沃，RuleGo 支持完全通过 JSON DSL 来定义和启动 Endpoint（接入点），无需修改代码即可扩展服务能力。

## 1. Endpoint DSL 核心结构

一个完整的 Endpoint DSL 包含基本元数据、配置参数以及路由器列表。

```json
{
  "id": "数据接入网关 DataInputGateway",
  "type": "http",
  "configuration": {
    "server": ":9090",
    "allowCors": true
  },
  "routers": [
    {
      "id": "数据接收路由 DataReceiverRouter",
      "from": {
        "path": "/api/v1/collect",
        "configuration": {}
      },
      "to": {
        "path": "chain:主消息链 MainMessageChain",
        "wait": true 
      }
    }
  ]
}
```

## 2. 常用 Endpoint 类型配置参数

### **HTTP (rest)**
- **type**: `http`
- **configuration**:
    - `server`: (string) 监听地址，如 `:9090`。
    - `allowCors`: (bool) 是否允许跨域。

### **WebSocket (websocket)**
- **type**: `websocket`
- **configuration**:
    - `server`: (string) 监听地址。

### **MQTT (mqtt)**
- **type**: `mqtt`
- **configuration**:
    - `server`: (string) Broker 地址，如 `127.0.0.1:1883`。
    - `username/password`: (string) 认证信息。
- **Router From**: 代表订阅的主题（Topic）。

### **定时任务 (schedule)**
- **type**: `schedule`
- **configuration**: 无特定 server 地址。
- **Router From**: 代表 Cron 表达式，如 `*/5 * * * * *` (每 5 秒触发一次)。

## 3. 核心准则：利用已有模块

阿沃在开发时，请务必先核对 [组件参数金典 (component-catalog.md)](component-catalog.md)， RuleGo 已经内置了绝大多数常用的网络、协议和过滤模块：

1.  **能通过 DSL 配置的绝不改代码**：
    *   外部请求路由 -> 使用 **Endpoint DSL**。
    *   消息过滤/路由/简单的转换 -> 使用内置组件（`jsFilter`, `jsSwitch`, `templateTransform`）。
    *   API 调用、DB 操作、MQTT 推送 -> 使用内置 Action 组件。
2.  **只在以下情况开发新模块**：
    *   需要对接特殊的硬件协议且没有通用驱动。
    *   需要执行极高性能要求的复杂算法。
    *   需要集成公司内部私有的 SDK。

## 4. 命名一致性
在 Endpoint DSL 中，`id` 和路由的描述也请严格遵循 **“中文 + 英文”** 命名规范，方便后期维护。
