# RuleGo Go API 参考指南

本文档涵盖了在 Go 语言中操作规则引擎实例、消息对象以及注册自定义组件的核心 API。

## 1. 规则引擎生命周期

### 创建引擎
```go
import "github.com/rulego/rulego"

// 使用指定 ID 和配置初始化
engine, err := rulego.New("chain_id", []byte(jsonConfig))
```

### 获取现有引擎
```go
engine, ok := rulego.Get("chain_id")
```

### 更新引擎 (热更新)
```go
// 重新加载规则链配置
err := engine.ReloadSelf([]byte(newJsonConfig))

// 重新加载特定的子节点配置
err := engine.ReloadChild("node_id", []byte(newNodeConfig))
```

### 销毁引擎
```go
rulego.Del("chain_id")
```

## 2. 消息处理 (RuleMsg)

消息是 RuleGo 处理的核心，由 `types.RuleMsg` 定义。

### 创建新消息
```go
import "github.com/rulego/rulego/api/types"

metadata := types.NewMetadata()
metadata.PutValue("topic", "device/telemetry")

msg := types.NewMsg(
    0,                      // 消息 ID
    "TELEMETRY_MSG",        // 消息类型
    types.JSON,             // 数据格式 (JSON | BINARY | PROTOBUF)
    metadata,               // 元数据
    "{\"temp\": 25}"        // 数据负载
)
```

### 异步处理与回调 (Advanced Options)
使用 `RuleContextOption` 获得更精细的执行控制：

```go
engine.OnMsg(msg, 
    // 1. 单个节点结束回调（每次分叉都会触发）
    types.WithOnEnd(func(ctx types.RuleContext, msg types.RuleMsg, err error, relationType string) {
        log.Printf("Node end: %s, Relation: %s", msg.Id, relationType)
    }),
    // 2. 整条规则链执行完毕回调（只触发一次）
    types.WithOnAllNodeCompleted(func() {
        log.Println("Rule chain execution finished completely.")
    }),
    // 3. 获取规则链快照（包含所有节点日志）- 调试神器
    types.WithOnRuleChainCompleted(func(ctx types.RuleContext, snapshot types.RuleChainRunSnapshot) {
        log.Printf("Chain trace: %+v", snapshot.Logs)
    }),
    // 4. 指定开始节点（跳过 Root）
    types.WithStartNode("node_specific_id"),
)
```

### 调试模式回调
如果规则链或节点开启了 `debugMode: true`，会触发 `config.OnDebug`（全局）和 `WithOnNodeDebug`（单次）：

```go
types.WithOnNodeDebug(func(chainId, flowType, nodeId string, msg RuleMsg, relationType string, err error) {
    // flowType: IN (进入节点) | OUT (离开节点)
    fmt.Printf("[%s] Node %s %s: %s\n", chainId, nodeId, flowType, msg.Data)
})
```

## 3. 编排上下文 (RuleContext)

在节点内部可以通过 `RuleContext` 操作消息流向：
- `ctx.TellSuccess(msg)`: 告知引擎节点处理成功，流向 `Success` 关系。
- `ctx.TellNext(msg, types.Success)`: 等同于上面。
- `ctx.TellFailure(msg, err)`: 告知节点处理失败，流向 `Failure` 关系。
- `ctx.TellNext(msg, "MyCustomRelation")`: 将消息流向自定义关系。

## 4. 自定义组件注册

```go
// 实现 types.Node 接口
type MyNode struct {}

func (n *MyNode) Type() string { return "myCustomNode" }
func (n *MyNode) New() types.Node { return &MyNode{} }
func (n *MyNode) Init(config types.Config, configuration types.Configuration) error { ... }
func (n *MyNode) OnMsg(ctx types.RuleContext, msg types.RuleMsg) { ... }
func (n *MyNode) Destroy() { ... }

// 注册到全局单例
rulego.Registry.Register(&MyNode{})
```

注册后，您就可以在规则链 JSON 中使用 `"type": "myCustomNode"` 了。
