# RuleGo-Server 模式开发指南

阿沃，本指南专门针对基于 `rulego/examples/server` 项目的开发工作流。请务必遵循“不破坏原始结构”的原则。

## 1. 项目结构与约束
`examples/server` 是一个完整的规则引擎服务，通过命令行启动。

- **禁止修改**：请勿直接修改 `cmd/server/server.go`、`internal/service` 等核心逻辑。
- **允许操作**：
    - **增加 DSL**：在 `./data/workflows/admin/rule/` 目录下添加 `.json` 规则链文件。
    - **开发组件**：在项目目录下新建包（如 `custom_nodes`），并在 `cmd/server/server.go` 同级的扩展文件中引入。
    - **使用内置插件**：通过 `go build -tags with_extend .` 编译包含 Kafka、Redis 等扩展组件的版本。

## 2. DSL (规则链) 开发流程
1. **定位目录**：默认情况下，规则链存放于 `./data/workflows/{username}/rule/`。对于开发调试，通常使用 `admin` 用户。
2. **编写/导出**：推荐使用可视化编辑器导出 JSON，或手动按标准结构编写。
3. **文件名与 ID**：文件名（不含扩展名）即为规则链 ID。
4. **热更新**：
   - 启动 server 后，修改文件通常需要重启或通过 API 触发 Reload。
   - `server` 启动参数示例：`go run ./cmd/server/ -c ./config.conf`

## 3. 自定义组件开发规范
为了保持组件解耦并能通过参数灵活配置，请遵循以下模式：

### 目录建议
在 `examples/server` 根目录下创建 `extensions` 目录存放您的自定义组件。

### 开发模版 (解耦风格)
```go
package extensions

import (
    "github.com/rulego/rulego/api/types"
    "github.com/rulego/rulego/utils/maps"
)

// MyServiceNode 通过参数控制逻辑，不包含硬编码业务
type MyServiceNode struct {
    Config MyNodeConfig
}

type MyNodeConfig struct {
    Endpoint string `json:"endpoint"` // 参数化：接口地址
    Method   string `json:"method"`   // 参数化：请求方式
    Timeout  int    `json:"timeout"`  // 参数化：超时时间
}

func (n *MyServiceNode) Type() string { return "myServiceNode" }
func (n *MyServiceNode) New() types.Node { return &MyServiceNode{} }

func (n *MyServiceNode) Init(config types.Config, configuration types.Configuration) error {
    // 将 JSON 配置映射到结构体，实现参数化
    return maps.Map2Struct(configuration, &n.Config)
}

func (n *MyServiceNode) OnMsg(ctx types.RuleContext, msg types.RuleMsg) {
    // 使用 n.Config 中的参数执行逻辑
    // ...
    ctx.TellSuccess(msg)
}
```

### 自动注册
在组件文件中使用 `init()` 函数，或在服务器启动入口处统一匿名引入。
由于不能修改 server 结构，建议在 `cmd/server/` 下新建一个 `with_custom.go` 并标记 build tag。

## 4. 调试与验证
- **查看日志**：开启 `config.conf` 中的 `debug = true`，日志会打印每个节点的输入输出。
- **API 测试**：通过 `POST /api/v1/msg/{chainId}` 直接向指定规则链发送测试消息。
