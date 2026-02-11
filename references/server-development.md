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


## 4. Server 核心配置详解 (config.conf)

RuleGo Server 的强大在于其高度可配置性。以下是几个至关重要的配置项，直接影响您的开发模式：

### 4.1 全局变量 (Global Properties)

在 `[global]` 节定义的变量，可以在 **任何规则链** 的 **任何节点配置** 中通过 `${global.xxx}` 引用。

```toml
[global]
  # 数据库连接串，DSL 中使用 ${global.sql_dsn} 引用
  sql_dsn = "root:123456@tcp(127.0.0.1:3306)/test"
  # API 密钥，DSL 中使用 ${global.api_key} 引用
  api_key = "sk-xxxxxxxx"
```

> **最佳实践**: 永远不要在 JSON DSL 中硬编码密码或 IP。始终使用 `global` 变量。

### 4.2 自定义函数 (UDF)

您可以将 Go 函数注册为 UDF，然后在 DSL 的 `jsTransform` 或 `functions` 节点中直接调用。

1.  **注册 (Go Code)**:
    ```go
    // 在 server 初始化时注册
    config.RegisterUdf("my_hash", func(str string) string {
        return utils.Hash(str)
    })
    ```
2.  **调用 (DSL)**:
    *   **JS**: `var hash = global.my_hash(msg.data);`
    *   **Lua**: `local hash = global.my_hash(msg.data)`

### 4.3 协程池隔离 (Node Pool)

对于 `dbClient` 或 `restApiCall` 等慢速 I/O 节点，建议配置独立的协程池，避免阻塞核心规则处理线程。

```toml
# node_pool_file = "./node_pool.json"
```
在 `node_pool.json` 中定义哪些节点类型运行在独立的 Pool 中。

### 4.4 调试回调 (OnDebug)

开启 `debugMode: true` 的节点会触发全局 `OnDebug` 回调。Server 默认会打印详细的输入/输出日志，这是排查问题的利器。

## 5. 调试与验证
- **查看日志**：开启 `config.conf` 中的 `debug = true`，日志会打印每个节点的输入输出。
- **API 测试**：通过 `POST /api/v1/msg/{chainId}` 直接向指定规则链发送测试消息。
