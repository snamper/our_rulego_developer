# RuleGo Endpoint 配置指南 (DSL)

阿沃，Endpoint 是数据进入规则引擎的**守门人**。它负责监听网络端口、订阅消息队列或执行定时任务，并将这些外部请求解构为规则引擎可处理的 `RuleMsg`。

---

## 1. Endpoint DSL 核心结构

每个 Endpoint 本身也是一个 DSL 定义，通常包含多个路由（Routers）。

```json
{
  "id": "ep_01",
  "type": "endpoint/http",
  "name": "核心 API 网关",
  "configuration": {
    "address": ":9090"
  },
  "routers": [
    {
      "from": "/api/v1/telemetry",
      "to": {
        "path": "chain:main_logic",
        "wait": true
      },
      "processers": [
        "responseToBody"
      ]
    }
  ]
}
```

- **id**: 全局唯一标识。
- **type**: Endpoint 类型（如 `endpoint/http`, `endpoint/mqtt`, `endpoint/schedule`）。
- **configuration**: 本实例的特定配置（如监听地址、连接参数）。
- **routers**: 路由规则数组，定义了“从哪来 (`from`)”和“去哪儿 (`to`)”。

---

## 2. 核心 Endpoint 类型详解

### 🌐 3.1 HTTP 服务 (endpoint/http)
最常用的入口，支持 RESTful API。
- **Configuration**:
    - `address`: (string) 监听地址，如 `:9090`。
- **Router From**: URL 路径（支持带有通配符）。
- **常用 Processers**:
    - `responseToBody`: 将规则链最后的结果直接作为 HTTP Body 返回给客户端。

### ⏰ 3.2 定时任务 (endpoint/schedule)
无需外部触发，根据 Cron 表达式自动运行。
- **Router From**: 标准 Cron 表达式，如 `*/5 * * * * *` (每 5 秒)。
- **注意**: 建议 `wait` 设为 `false` 以免阻塞调度器。

### 📨 3.3 消息队列 (MQTT / Kafka)
订阅外部 Topic 并触发业务。
- **endpoint/mqtt**:
    - `server`: `tcp://localhost:1883`
    - `topic`: `device/+/data`
- **endpoint/kafka**:
    - `brokers`: `["localhost:9092"]`
    - `topics`: `["iot_topic"]`

---

## 3. 关键参数辨析：`wait` 与 `responseToBody`

阿沃，这是新手最容易踩坑的地方：

1.  **wait (Boolean)**:
    - `true`: Endpoint 会同步等待规则链执行完才返回结果。**适合查询类 API**。
    - `false`: 触发规则链后立即返回成功标志，不等待结果。**适合数据采集流**。
    - 更多细节请参考：[⏱️ Wait 同步/异步机制详解](wait-mechanism.md)。

2.  **responseToBody (Processer)**:
    - 仅在 `wait: true` 时有效。它会提取 `msg.Data` 并作为响应内容。

---

## 4. 🚫 架构红线：严禁“内联闭环”模式

阿沃，在生产环境中，**严禁** 在规则链内部通过一个“内联 Endpoint”（即自己定义的 HTTP 接口）构成调用闭环。

### **为什么严禁内联闭环？**
1.  **响应状态丢失**: `responseToBody` 严重依赖 `OnEnd` 回调。在同步等待模式下，引擎逻辑执行完的“释放”与 `OnEnd` 回调是两个独立的事件。对于内联闭环，底层的响应数据**无法正确冒泡同步**，导致调用方拿不到数据。
2.  **死循环风险**: 极易引发递归死调用，导致协程池满负荷直至 OOM 或死锁。

### **✅ 正确做法**
- **一律采用外部主网关路由**。
- 规则链之间的交互应使用 `flow` (子链) 节点或消息队列实现逻辑解耦。

---

## 5. 核心准则：利用已有模块

阿沃在开发时，请务必先核对 [组件库目录](component-catalog.md)， RuleGo 已经内置了绝大多数常用的组件。
