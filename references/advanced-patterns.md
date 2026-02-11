# RuleGo 高级开发模式 (Advanced Patterns)

本指南汇集了 RuleGo 核心开发者使用的设计模式，用于解决动态配置、热更新及混合编程等复杂场景。

## 1. 逻辑注入模式 (Logic Injection)

**痛点**: 业务规则经常变化，但不想每次都修改 DSL JSON 文件并发布。
**解法**: 将易变的 JavaScript 逻辑放入全局配置（甚至数据库/配置中心），在 DSL 中通过占位符引用。

### 1.1 Config 配置
在 `config.conf` 或代码初始化时：

```toml
[global]
  # 定义一段公共的 JS 逻辑，甚至可以包含函数定义
  common_validation = """
    if (msg.temp < 0) return false;
    if (metadata.sensor_status != 'active') return false;
    return true;
  """
```

### 1.2 DSL 引用
在规则链中，不要写死代码，而是引用变量：

```json
{
  "type": "jsFilter",
  "name": "动态验证",
  "configuration": {
    "jsScript": "${global.common_validation}"
  }
}
```

**优势**: 修改配置中心的配置后，调用 `engine.ReloadSelf()` 即可生效，无需重新部署 DSL 文件。

---

## 2. 混合编程模式 (Hybrid Computing)

**痛点**: JS 处理复杂数学运算或 IO 慢，Go 代码灵活性差。
**解法**: **Go UDF (计算/IO)** + **JS DSL (编排/胶水)**。

### 2.1 Go 侧注册重型函数
```go
// 注册一个查询数据库并返回复杂结构体的函数
config.RegisterUdf("getUserProfile", func(userId string) map[string]interface{} {
    // 模拟 DB 查询，这里可以使用 Go 的高性能 ORM
    return users.Find(userId)
})

// 注册高性能算法库
config.RegisterUdf("calcHash", func(data string) string {
    h := sha256.New()
    h.Write([]byte(data))
    return hex.EncodeToString(h.Sum(nil))
})
```

### 2.2 DSL 侧轻量调用
```javascript
// jsTransform 节点
var uid = msg.userId;
// 1. 调用 Go 函数获取数据 (高性能 IO)
var profile = global.getUserProfile(uid);

// 2. 调用 Go 函数计算 (高性能 CPU)
var hash = global.calcHash(msg.payload);

// 3. JS 仅做字段组装 (灵活)
if (profile.vip) {
    msg.hash = hash;
    return {msg: msg, metadata: metadata, msgType: 'VIP_MSG'};
}
```

---

## 3. 局部热更新模式 (Partial Hot Reload)

**场景**: 生产环境中有一个庞大的规则链，只有其中一个“阈值判断”节点需要调整参数，不想重启这一整条链（可能会丢失中间状态）。

**核心 API**: `engine.ReloadChild(nodeId, newJson)`

```go
// 原始节点 ID 为 "node_check_01"
// 新的配置 JSON
newNodeJson := []byte(`{
  "id": "node_check_01",
  "type": "jsFilter",
  "name": "新阈值判断",
  "configuration": {
    "jsScript": "return msg.val > 90;" // 以前是 > 80
  }
}`)

// 原地热更，不影响链路上其他正在运行的消息
err := engine.ReloadChild("node_check_01", newNodeJson)
```

---

## 4. 动态子链路由 (Dynamic Chain Routing)

**场景**: 根据消息类型，动态分发到不同的子规则链处理，且规则链 ID 是动态的。

**组件**: `chain` 节点虽然通常配置固定的 `ruleChainId`，但你可以通过实现自定义路由或使用 `jsSwitch` 配合 `Route` 节点来实现。

**更优雅的方案 (Vars)**:
如果 RuleGo 版本支持（v0.22+），`chain` 节点的 `ruleChainId` 支持变量替换。

```json
{
  "type": "chain",
  "configuration": {
    "ruleChainId": "${metadata.target_chain_id}"
  }
}
```
这样，上游节点只需修改 metadata 中的 `target_chain_id`，即可将消息路由到任意规则链，实现完全动态的调度网关。
