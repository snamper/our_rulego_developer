# RuleGo 组件库金典 (JSON 配置与现有模块)

阿沃，本指南详细列出了 RuleGo 及其官方扩展库中所有可用组件的 JSON 配置参数，旨在防止传错 key 或放错位置。

---

## 1. 基础消息路由与控制 (Common/Flow)

### **chain** (嵌套子链)
- **type**: `chain`
- **功能**: 调用另一个规则链。
- **configuration**:
    - `ruleChainId`: (string) **必填**。子规则链 ID。

### **jsSwitch** (多路开关/路由)
- **type**: `jsSwitch`
- **功能**: 使用 JS 返回一个或多个 Relation 字符串。
- **configuration**:
    - `jsScript`: (string) **必填**。代码需返回字符串数组。`return ['Success', 'Log'];`

### **while/for/iterator** (循环控制)
- **type**: `while`, `for`, `iterator`
- **功能**: 实现逻辑循环。
- **configuration**:
    - `count`: (int/string) 循环次数 (仅 for)。
    - `jsScript`: (string) 判断条件 (仅 while)。
    - `field`: (string) 迭代对象字段名 (仅 iterator)。

---

## 2. 消息过滤 (Filter)

### **jsFilter** (脚本过滤)
- **type**: `jsFilter`
- **configuration**:
    - `jsScript`: (string) **必填**。返回 `true`/`false`。

### **msgTypeFilter** (类型过滤)
- **type**: `msgTypeFilter`
- **configuration**:
    - `messageTypes`: (string array) 如 `["TELEMETRY_MSG"]`。

### **fieldFilter** (字段过滤)
- **type**: `fieldFilter`
- **configuration**:
    - `checkAllExist`: (bool) 是否要求所有字段都存在。
    - `names`: (string array) 检查的字段列表。

---

## 3. 消息转换 (Transform)

### **jsTransform** (脚本转换 - 极其热门)
- **type**: `jsTransform`
- **功能**: 使用 JavaScript 修改消息内容、元数据或消息类型。
- **configuration**:
    - `jsScript`: (string) **必填**。代码需返回包含 `msg`, `metadata`, `msgType` 的对象。
    - *实战示例*：`return {'msg':msg, 'metadata':metadata, 'msgType':msgType};`

### **functions** (业务函数调用)
- **type**: `functions`
- **功能**: 调用在 Go 代码中预注册的业务函数。
- **configuration**:
    - `functionName`: (string) **必填**。Go 中注册的函数名。

### **exprFilter / exprTransform** (表达式过滤/转换)
- **type**: `exprFilter`, `exprTransform`
- **功能**: 使用轻量级表达式（比 JS 更快）进行处理。
- **configuration**:
    - `expr`: (string) **必填**。表达式，如 `msg.temperature > 50`。

### **fork & join** (并发执行)
- **type**: `fork`, `join`
- **功能**: 并发触发多个分支，并在 Join 点汇合。
- **configuration**:
    - `join`: 设置汇合策略。

---

## 3.5 高级流控 (Advanced Flow)

### **delay** (延迟队列)
- **type**: `delay`
- **功能**: 暂存消息，延迟一定时间后发送。
- **configuration**:
    - `periodInSeconds`: (int) 延迟秒数。
    - `maxPendingMsgs`: (int) 队列最大积压数。超过走 Failure。

### **groupFilter** (组合过滤)
- **type**: `groupFilter`
- **功能**: 复用已有的过滤器节点，进行 AND/OR 组合。
- **configuration**:
    - `nodeIds`: (string) 要复用的 Filter 节点 ID 列表，逗号分隔，如 `"node_a,node_b"`。
    - `allMatches`: (bool) `true`=AND (全满足), `false`=OR (任一满足)。

### **groupAction** (组合动作)
- **type**: `groupAction`
- **功能**: 并行执行一组动作节点，等待全部完成后继续。
- **configuration**:
    - `nodeIds`: (string) 逗号分隔的节点 ID。

### **switch** (条件分支 - 高频 93次)
- **type**: `switch`
- **功能**: 基于**表达式**的多路分支（比 `jsSwitch` 轻量，不需要 JS 引擎）。
- **configuration**:
    - `cases`: (array) 条件数组，每项包含 `case` (表达式) 和 `then` (Relation 名称)。
- **示例**:
    ```json
    {
      "cases": [
        {"case": "msg.temperature>=20 && msg.temperature<=50", "then": "Case1"},
        {"case": "msg.temperature>50", "then": "Case2"}
      ]
    }
    ```

### **flow** (子链调用 - 推荐替代 chain)
- **type**: `flow`
- **功能**: 调用另一个规则链（比 `chain` 更灵活，支持 `extend` 参数）。
- **configuration**:
    - `targetId`: (string) **必填**。目标规则链 ID。
    - `extend`: (bool) 是否传递上下文扩展信息。

### **msgTypeSwitch** (消息类型分支)
- **type**: `msgTypeSwitch`
- **功能**: 根据 `msg.Type` 自动路由到不同的有向边。无需配置。

### **metadataTransform** (元数据映射 - 10次)
- **type**: `metadataTransform`
- **功能**: 将消息字段映射到元数据（比 `jsTransform` 轻量）。
- **configuration**:
    - `mapping`: (object) Key-Value 映射，如 `{"temperature": "msg.temperature"}`。

### **comment** (注释节点)
- **type**: `comment`
- **功能**: 纯注释用，不影响消息流。用于在可视化编辑器中标记说明。

### **end** (结束节点)
- **type**: `end`
- **功能**: 显式标记流程结束。通常作为分支的终点。

### **break** (中断节点)
- **type**: `break`
- **功能**: 从循环中跳出（配合 `for` / `while` 使用）。

### **ref** (引用节点)
- **type**: `ref`
- **功能**: 引用当前链中已存在的另一个节点，避免重复定义。

---

## 3.6 系统工具 (Utility)

### **exec** (执行系统命令 - 10次)
- **type**: `exec`
- **功能**: 在服务器上执行系统命令。
- **configuration**:
    - `cmd`: (string) **必填**。命令字符串，如 `"echo hello"`。
    - `args`: (array) 命令参数列表。
    - `log`: (bool) 是否记录执行日志。
    - `replaceData`: (bool) 是否用命令输出替换 `msg.Data`。
- **⚠️ 安全提醒**: 禁止将用户输入直接拼入 `cmd`！

### **sendEmail** (发送邮件 - 5次)
- **type**: `sendEmail`
- **功能**: 通过 SMTP 发送邮件。
- **configuration**:
    - `smtpHost`: (string) SMTP 服务器，如 `"smtp.gmail.com"`。
    - `smtpPort`: (int) 端口。
    - `username`: (string) 登录账号。支持 `${global.xxx}`。
    - `password`: (string) 登录密码。支持 `${global.xxx}`。
    - `connectTimeout`: (int) 连接超时秒数。
    - `email`: (object) 邮件内容：
        - `from`: (string) 发件人。
        - `to`: (string) 收件人。支持变量替换。
        - `subject`: (string) 主题。
        - `body`: (string) 正文。

### **text/template** (Go 模板渲染 - 7次)
- **type**: `text/template`
- **功能**: 使用 Go `text/template` 语法渲染模板。
- **configuration**:
    - `template`: (string) **必填**。Go 模板字符串，如 `"ID: {{ .id }}, Data: {{ .data | escape }}"`。

### **net** (TCP/UDP 网络客户端 - 7次)
- **type**: `net`
- **功能**: 向 TCP/UDP 服务器发送数据。
- **configuration**:
    - `protocol`: (string) `tcp` 或 `udp`。
    - `server`: (string) 目标地址，如 `"192.168.1.1:8080"`。
    - `connectTimeout`: (int) 连接超时秒数。
    - `heartbeatInterval`: (int) 心跳间隔秒数。

---

## 3.7 AI/LLM 组件 (AI)

### **ai/llm** (大模型调用 - 10次)
- **type**: `ai/llm`
- **功能**: 调用 OpenAI 兼容的 LLM 接口。
- **configuration**:
    - `url`: (string) API 地址，如 `"https://api.openai.com/v1"`。
    - `model`: (string) 模型名称，如 `"gpt-4o"`, `"o1-mini"`。
    - `messages`: (array) 消息列表，每项包含 `role` 和 `content`。
    - `images`: (array) 图片 URL 列表（多模态）。
    - `params`: (object) 推理参数：
        - `temperature`: (float) 温度。
        - `maxTokens`: (int) 最大输出 Token。
        - `topP`: (float) 核采样。
        - `responseFormat`: (string) 响应格式。
        - `jsonSchema`: (string) JSON Schema 约束。

### **ai/createImage** (AI 生成图片 - 5次)
- **type**: `ai/createImage`

### **ai/generate-text** / **ai/generate-image** (文本/图片生成)
- **type**: `ai/generate-text`, `ai/generate-image`

---

## 3.8 CI/CD 组件

### **ci/gitClone** (Git 克隆 - 6次)
- **type**: `ci/gitClone`

### **ci/gitLog** / **ci/gitCreateTag** / **ci/ps**
- **type**: `ci/gitLog`, `ci/gitCreateTag`, `ci/ps`

---

## 4. 外部系统联动 (External) - ⚠️ 最易放错位置

### **restApiCall** (HTTP 调用)
- **type**: `restApiCall`
- **configuration**:
    - `restEndpointUrlPattern`: (string) **必填**。URL 地址。支持变量 `${msg.url}`。
    - `requestMethod`: (string) `GET`, `POST`, `PUT`, `DELETE`。
    - `headers`: (map[string]string) 请求头。
    - `body`: (string) 发送内容。
    - `readTimeoutMs`: (int) 超时毫秒。

### **dbClient** (数据库操作)
- **type**: `dbClient`
- **configuration**:
    - `driverName`: (string) `mysql`, `postgres`...
    - `dsn`: (string) 连接串。示例：`root:root@tcp(127.0.0.1:3306)/test`
    - `sql`: (string) **必填**。SQL 语句模板。
    - `params`: (array) 占位符具体值。
    - `opType`: (string) `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `EXEC`, `AUTO`。

### **x/mongodbClient** / **x/redisClient** (扩展示例)
- **type**: `x/mongodbClient`, `x/redisClient`
- **注意**: 官方扩展库组件通常带有 `x/` 或特定命名前缀。

### **mqttClient** (MQTT 发布)
- **type**: `mqttClient`
- **configuration**:
    - `server`: (string) `tcp://127.0.0.1:1883`。
    - `topic`: (string) 主题。
    - `qos`: (int) `0`, `1`, `2`。
    - `cleanSession`: (bool)。

### **ssh** (远程命令)
- **type**: `ssh`
- **configuration**:
    - `host`: (string) 主机名。
    - `port`: (int) 端口。
    - `cmd`: (string) 执行的命令。

---


## 5. 缓存操作 (Cache - 实战 12次)

### **cacheGet / cacheSet / cacheDelete**
- **type**: `cacheGet`, `cacheSet`, `cacheDelete`
- **功能**: 对 RuleGo 内置缓存进行增删改查。支持链级 (chain) 和全局 (global) 两种作用域。
- **configuration**:
    - `key`: (string) 缓存 Key。支持 `${msg.xxx}` 变量替换。
    - `value`: (string) 缓存值 (仅 cacheSet)。
    - `ttl`: (string) 过期时间 (仅 cacheSet)，如 `"10m"`, `"1h"`。空 = 永不过期。
    - `scope`: (string) `chain` (当前规则链级) 或 `global` (全局跨链共享)。
- **JS 脚本中直接操作** (无需组件):
    ```javascript
    // 在 jsTransform / jsFilter 中
    let cache = $ctx.ChainCache();  // 或 $ctx.GlobalCache()
    cache.Set("key", "value", "10m");
    let val = cache.Get("key");
    ```

---

## 6. 官方扩展模块 (rulego-components)

这些模块已在 `rulego-components` 中提供，启动时需带 `-tags with_extend`：

### 消息队列
- **Kafka**: `x/kafkaProducer` (5次)
- **NATS**: `x/natsClient` (5次), `endpoint/nats`
- **NSQ**: `x/nsqClient` (3次)
- **RabbitMQ**: `x/rabbitmqClient` (1次)
- **Redis Pub/Sub**: `x/redisPub` (3次)

### 数据库 & 存储
- **Redis**: `x/redisClient` (11次)
- **MongoDB**: `x/mongodbClient` (14次)
- **TDengine**: `taosClient` (2次) - 时序数据库

### IoT 协议
- **OPC-UA**: `x/opcuaRead` (4次), `x/opcuaWrite` (5次) - 工业控制协议
- **Modbus**: `x/modbus` (1次) - 工业总线

### 网络通信
- **gRPC**: `x/grpcClient` (7次)
- **WuKongIM**: `x/wukongimSender` (1次)

### 流处理
- **Stream**: `x/streamAggregator` (4次), `x/streamTransform` (1次)
- **Lua**: `x/luaFilter` (6次), `x/luaTransform` (5次)

### 可观测性
- **OpenTelemetry**: `x/otel` (2次)
- **Prometheus**: `prometheus`

---

## 💡 使用准则：防止“配置地雷”
1.  **区分 `msg` 和 `metadata`**：在 JSON 字符串配置中，`${msg.xxx}` 取 Payload（数据包内容），`${metadata.xxx}` 取元数据。
2.  **数据类型敏感**：`int` 类型在 JSON 中不要加引号。例如 `readTimeoutMs: 5000` 是对的，`"5000"` 可能会引发解析错误。
3.  **变量优先级**：
    1. 局部节点配置。
    2. 消息元数据 (Metadata)。
    3. 全局配置 (`config.conf` 中的 `[global]` 节)。
