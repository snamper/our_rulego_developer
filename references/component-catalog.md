---

## 0. 规则节点 (RuleNode) 通用定义
每个在 `metadata.nodes` 数组中的节点都遵循以下结构：

```json
{
  "id": "node_unique_id",
  "type": "组件类型码",
  "name": "中文名称 English_Name", 
  "debugMode": false,
  "configuration": {
    "参数1": "值",
    "参数2": "值"
  }
}
```
- **debugMode**: 设为 `true` 时，该节点的输入输出将记录到日志/数据库（Server 模式下在可视化界面可见）。

---

## 1. 基础消息路由与控制 (Basic Flow)

### **jsFilter** (脚本过滤)
- **type**: `jsFilter`
- **功能**: 根据 JS 返回值（true/false）决定后续路径。
- **configuration**:
    - `jsScript`: (string) **必填**。逻辑代码。
- **案例**: `return msg.temperature > 50;`

### **jsSwitch** (多路开关)
- **type**: `jsSwitch`
- **功能**: 返回一个或多个状态字符串，路由到带有对应标签的有向边。
- **configuration**:
    - `jsScript`: (string) 需返回字符串数组，如 `return ["Success", "Alarm"];`。

### **exprFilter** (表达式过滤 - 高频)
- **type**: `exprFilter`
- **功能**: 使用高性能表达式（非 JS）进行条件判断。支持 `metadata`, `msg`, `config` 变量。
- **configuration**:
    - `expr`: (string) **必填**。如 `metadata.getRedis == true && msg.val > 10`。
- **表达式语法**:
    - **变量**: `msg.field`, `metadata.field`, `config.field`。
    - **操作符**: `+`, `-`, `*`, `/`, `%`, `==`, `!=`, `>`, `<`, `>=`, `<=`, `&&`, `||`, `!`, `in` (包含)。
    - **函数**: `len(array/string)`, `int(value)`, `float(value)`, `string(value)`, `has(msg.field)` (检查字段是否存在)。

### **exprTransform** (表达式转换)
- **type**: `exprTransform`
- **功能**: 使用表达式进行字段映射和计算。
- **configuration**:
    - `mapping`: (object) **必填**。Key 是目标字段名，Value 是表达式字符串。
- **案例**:
    ```json
    "mapping": {
      "total": "msg.price * msg.count",
      "offset": "int(metadata._loopIndex) * 10",
      "deviceName": "metadata.name",
      "status": "msg.value > 100 ? 'high' : 'low'"
    }
    ```

### **fork** (并行分流)
- **type**: `fork`
- **功能**: 将消息**同时复制**发送到所有下游节点进行并行处理。

### **join** (并行合并)
- **type**: `join`
- **功能**: 等待所有并行分支（由 fork 产生）完成后，将结果合并。
- **合并机制**: `join` 节点会收集回所有并行分支的输出消息，将其作为数组合并。

---

## 2. 循环与集合处理 (Iteration)

### **for** (确定次数循环)
- **type**: `for`
- **configuration**:
    - `range`: (int/string) 循环范围。可以是整数，或数组字段（如 `"msg.items"`）。
    - `do`: (string) **必填**。循环体起始节点 ID。

### **while** (条件循环)
- **type**: `while`
- **configuration**:
    - `jsScript`: (string) 返回 `true` 继续，`false` 退出。
    - `do`: (string) 起始节点 ID。

### **functions** (自定义函数调用)
- **type**: `functions`
- **功能**: 执行在 Go 代码中注册的特定 UDF 函数。
- **全量 JSON 示例**:
    ```json
    {
      "type": "functions",
      "configuration": {
        "functionName": "my_custom_handler",
        "params": ["${msg.id}", "${metadata.type}"]
      }
    }
    ```
- **配置参数**:
    - `functionName`: (string) **必填**。已注册的 Go 函数名。
    - `params`: (array) 传递给函数的动态参数列表。

---

## 3. 工具与实用组件 (Utility)

### **metadataTransform** (元数据映射)
- **type**: `metadataTransform`
- **configuration**:
    - `mapping`: (object) 如 `{"topic": "msg.deviceType"}`。

### **msgTypeFilter** (类型过滤)
- **type**: `msgTypeFilter`
- **全量 JSON 示例**:
    ```json
    {
      "type": "msgTypeFilter",
      "configuration": {
        "messageTypes": ["TELEMETRY_MSG", "ALARM_EVENT"]
      }
    }
    ```

### **fieldFilter** (字段过滤)
- **type**: `fieldFilter`
- **全量 JSON 示例**:
    ```json
    {
      "type": "fieldFilter",
      "configuration": {
        "checkAllExist": true,
        "names": ["msg.temperature", "metadata.deviceId"]
      }
    }
    ```

### **restApiCall** (外部 API 调用 - 实战 45次)
- **type**: `restApiCall`
- **全量 JSON 示例**:
    ```json
    {
      "type": "restApiCall",
      "configuration": {
        "restEndpointUrlPattern": "http://api.example.com/v1/push",
        "requestMethod": "POST",
        "headers": {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${global.token}"
        },
        "body": "${msg.data}",
        "readTimeoutMs": 5000,
        "maxRetries": 3
      }
    }
    ```
- **关键参数**: `restEndpointUrlPattern` 支持变量拼接。

### **dbClient** (数据库操作 - 实战 41次)
- **type**: `dbClient`
- **全量 JSON 示例**:
    ```json
    {
      "type": "dbClient",
      "configuration": {
        "driverName": "mysql",
        "dsn": "${global.mysql_dsn}",
        "sql": "INSERT INTO telemetry (device_id, value) VALUES (?, ?)",
        "params": ["${metadata.deviceId}", "${msg.temperature}"],
        "opType": "EXEC"
      }
    }
    ```

### **ai/llm** (大模型调用 - 实战 10次)
- **type**: `ai/llm`
- **全量 JSON 示例**:
    ```json
    {
      "type": "ai/llm",
      "configuration": {
        "url": "https://api.openai.com/v1",
        "model": "gpt-4o",
        "messages": [
          { "role": "system", "content": "你是个翻译助手" },
          { "role": "user", "content": "${msg.text}" }
        ],
        "params": {
          "temperature": 0.7,
          "maxTokens": 1024
        }
      }
    }
    ```

### **ci/gitClone** (Git 克隆 - 实战 6次)
- **type**: `ci/gitClone`
- **全量 JSON 示例**:
    ```json
    {
      "type": "ci/gitClone",
      "configuration": {
        "repository": "http://github.com/example/repo.git",
        "directory": "./workspace/repo",
        "authType": "token",
        "authPassword": "${global.git_token}"
      }
    }
    ```

---

## 4. 工业协议与流计算 (Extend)

- **x/opcuaRead**: `{ "server": "opc.tcp://...", "nodes": ["ns=2;s=Temp"] }`
- **x/streamAggregator**: `{ "sql": "SELECT avg(temp) FROM s WINDOW TUMBLING(SIZE 1m)" }`
- **x/otel**: `{ "server": "localhost:4318", "metrics": [...] }`

---

## 💡 使用准则
1. **JSON 配置用 `${}`，JS 脚本直接用变量名。**
2. **数据类型敏感**：`int` 不要加引号。
3. **变量优先级**: 节点配置 > Metadata > Global。
