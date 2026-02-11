# RuleGo 自定义组件开发指南

如果您内置组件无法满足业务需求，您可以轻松扩展自定义组件。

## 1. 实现接口
您的组件必须实现 `github.com/rulego/rulego/api/types` 包中的 `Node` 接口。

```go
type Node interface {
    // Type 组件类型，必须唯一
    Type() string
    // New 实例工厂函数
    New() Node
    // Init 初始化组件配置
    Init(config Config, configuration Configuration) error
    // OnMsg 处理消息，核心业务逻辑在此实现
    OnMsg(ctx RuleContext, msg RuleMsg)
    // Destroy 销毁组件
    Destroy()
}
```

## 2. 示例代码：一个简单的单位转换组件

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
