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


## 5. 缓存操作 (Cache)

### **cache/get, cache/set, cache/delete**
- **type**: `cache/get`, `cache/set`, `cache/delete`
- **功能**: 对 RuleGo 内置缓存进行增删改查。
- **configuration**:
    - `key`: (string) 缓存 Key。支持变量替换。
    - `ttl`: (string) 过期时间 (仅 set)，如 "10m"。
    - `scope`: (string) `chain` (链级) 或 `global` (全局)。

---

## 6. 官方扩展模块 (rulego-components)

这些模块已在 `rulego-components` 中提供，启动时需带 `-tags with_extend`：

- **Kafka**: `kafkaProducer`, `kafkaConsumer`
- **Redis**: `redisClient`, `redisPublisher`
- **MongoDB**: `mongodbClient`
- **Prometheus**: `prometheus`
- **Lua**: `luaFilter`, `luaTransform`

---

## 💡 使用准则：防止“配置地雷”
1.  **区分 `msg` 和 `metadata`**：在 JSON 字符串配置中，`${msg.xxx}` 取 Payload（数据包内容），`${metadata.xxx}` 取元数据。
2.  **数据类型敏感**：`int` 类型在 JSON 中不要加引号。例如 `readTimeoutMs: 5000` 是对的，`"5000"` 可能会引发解析错误。
3.  **变量优先级**：
    1. 局部节点配置。
    2. 消息元数据 (Metadata)。
    3. 全局配置 (`config.conf` 中的 `[global]` 节)。
