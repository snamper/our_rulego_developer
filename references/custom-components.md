# RuleGo 自定义组件开发指南

如果您内置组件无法满足业务需求，您可以轻松扩展自定义组件。

## 1. 组件核心接口 (Core Interface)

您的组件必须实现 `github.com/rulego/rulego/api/types` 包中的 `Node` 接口。

```go
type Node interface {
    // New 实例工厂：每条规则链的每个节点都会创建一个新实例，数据隔离
    New() Node
    
    // Type 组件类型：唯一标识，建议使用 `project/component` 格式防止冲突
    Type() string
    
    // Init 初始化：解析配置，仅在规则链初始化或更新时调用一次
    Init(ruleConfig Config, configuration Configuration) error
    
    // OnMsg 处理消息：核心逻辑，控制消息流向
    OnMsg(ctx RuleContext, msg RuleMsg)
    
    // Destroy 销毁：释放资源，如关闭连接池
    Destroy()
}
```

### 1.1 生命周期 (Lifecycle)
1.  **New()**: 引擎加载时调用，创建节点实例副本。
2.  **Init()**: 节点初始化时调用。**这是解析配置的最佳时机**。`configuration` 参数包含了 JSON DSL 里的 `configuration` 字段映射。
3.  **OnMsg()**: 消息到达时调用。**高并发热点**，请避免在此做重初始化操作。
4.  **Destroy()**: 规则链销毁或重载时调用。

## 2. RuleContext：编排与控制 (Orchestration)

`OnMsg` 方法中的 `ctx` 是操作的关键，它提供了强大的流控能力：

### 2.1 消息流转
*   `TellSuccess(msg)`: 通知引擎处理成功，消息流向 `Success` 有向边。
*   `TellFailure(msg, err)`: 通知处理失败，消息流向 `Failure` 有向边。
*   `TellNext(msg, relationTypes...)`: 自定义流向，例如 `TellNext(msg, "True")`。
*   `TellFlow(ctx, chainId, msg, ...)`: **触发子规则链**。
*   `TellNode(ctx, nodeId, msg, ...)`: 跳转到指定节点（高级用法，如跳转回前面的节点实现循环）。

### 2.2 上下文共享 & 缓存
*   `SetContext(c)` / `GetContext()`: 在同一次执行链路的**不同组件实例间**共享 Golang Context。
*   `ChainCache()`: 获取**当前规则链级**缓存。适合存取该链的中间状态。
*   `GlobalCache()`: 获取**全局级**缓存。适合跨链共享数据。

### 2.3 异步编排
*   `SubmitTack(task func())`: 提交异步任务，不阻塞当前协程。

## 3. 示例代码：一个简单的单位转换组件

```go
package mynodes

import (
	"github.com/rulego/rulego/api/types"
	"github.com/rulego/rulego/utils/maps"
)

// MyTransformNode 定义组件
type MyTransformNode struct {
	Config types.Configuration
}

func (n *MyTransformNode) Type() string {
	return "我的转换组件-MyTransform"
}

func (n *MyTransformNode) New() types.Node {
	return &MyTransformNode{}
}

func (n *MyTransformNode) Init(config types.Config, configuration types.Configuration) error {
	n.Config = configuration
	return nil
}

func (n *MyTransformNode) OnMsg(ctx types.RuleContext, msg types.RuleMsg) {
	// 简单的逻辑：将消息中的 val 乘以配置中的倍数
	var data map[string]interface{}
	// 解析数据并转换...
    
	// 告知引擎处理成功，发送到下一节点
	ctx.TellSuccess(msg)
}

func (n *MyTransformNode) Destroy() {}
```

## 3. 注册组件
在使用之前，需要手动注册到 RuleGo 注册表：

```go
import "github.com/rulego/rulego"

func init() {
    rulego.Registry.Register(&mynodes.MyTransformNode{})
}
```

## 4. 在 JSON 中使用
```json
{
  "id": "node_custom",
  "type": "myTransform",
  "configuration": {
    "factor": 10
  }
}
```
