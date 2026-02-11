# RuleGo 开发准则与规范库

阿沃，在使用和扩展 RuleGo 时，请务必遵循以下核心准则和开发规范，以确保系统的高性能与可维护性。

## 1. 核心准则 (The RuleGo Way)

- **配置驱编排 (Configuration over Coding)**: 绝不将业务逻辑硬编码在节点代码中。所有判断依据、访问路径、SQL 逻辑必须通过 DSL 中的 `configuration` 传入。
- **消息驱动 (Event Driven)**: 节点间仅通过 `RuleMsg` 通讯。不要尝试通过全局变量在节点间传递临时状态。
- **无状态设计 (Stateless Nodes)**: 除非组件本身是“外部客户端”（如 DB 连接池），否则节点本身应保持无状态，以支持并发安全。

## 2. 开发新模块的要求与建议

如果您发现内置组件无法满足需求，可以开发新组件，但必须满足以下条件：

### A. 命名与映射 (Naming Conventions)
- **核心命名规范**：为了提高可读性和国际化参考，所有的**链名称 (name)**、**节点名称 (name)** 以及 **组件类型 (Type)** 必须统一使用 **“中文 + 英文”** 的方式命名。
    - *格式示例*：`用户校验 UserValidation` 或 `数据转换 DataTransform`。
- **组件 Type**: 必须全局唯一，推荐使用 `中文名称-EnglishName` (如 `自定义验证-CustomValidator`) 或驼峰 `中文EnglishName`。
- **Config 映射**: 必须定义一个对应的 `Config` 结构体，并使用 `maps.Map2Struct` 进行初始化。

### B. 解耦要求
- **严禁包含特定业务 ID**: 节点不应知道 "User123"，它只应知道 "userId"（通过变量获取）。
- **统一异常处理**: 始终使用 `ctx.TellFailure(msg, err)` 告知引擎故障，不要在节点内自行打印 `Panic`。

### C. 风格一致性
- **超时处理**: 凡涉及网络/磁盘 IO，必须提供 `timeoutMs` 或类似可配置参数。
- **变量替换支持**: 使用 `el.NewTemplate()` 手动支持配置项中的 `${...}` 语法。

### D. 高级模式 (Shared & Pool)
- **SharedNode (节点共享)**: 对于 MQTT Client 或 Database Client，如果多个节点使用相同的配置，应使用 `SharedNode` 机制避免重复连接。
    - *原则*: 不要在 `OnMsg` 里创建客户端；在 `Init` 里创建，或使用 `Resource` 注册表。
- **Node Pool (资源隔离)**: 根据业务 IO 特性，将节点分类放入不同的协程池。
    - *配置*: 在 `rulego.yml` 或 `config.conf` 中为特定 Type 的组件指定 `pool_name`。

## 3. 开发注意事项 (踩坑指南)

- **并发竞争**: RuleGo 是并发运行规则链的。避免在节点 struct 中定义普通变量来累加值。
- **资源泄露**: 实现了 `Destroy()` 方法。如果您的组件持有文件句柄、网络连接，必须在销毁时关闭。
- **内存安全**: 处理海量数据时，避免一次性在元数据中放入巨大 JSON 对象。
- **不要修改 Server 结构**: 
  - 核心逻辑在 `rulego/examples/server`。
  - 只能在 `./extensions/` 添加代码。
  - 只能在 `./data/workflows/` 添加 DSL。

## 4. 如何更好地使用 RuleGo

1.  **善用全局变量**: 在 `config.conf` 的 `[global]` 中配置 DSN、API Keys，在规则链中通过 `${global.xxx}` 引用。
2.  **模块化规则链**: 开发复杂的业务流程时，将其拆分为多个子规则链，使用 `chain` 节点进行嵌套调用。
3.  **开启调试模式**: 开发阶段在节点 JSON 中将 `debugMode` 设为 `true`，通过 Server 的日志观察每一个步骤的 Payload 变化。
4.  **接口先行**: 所有的自定义逻辑，优先考虑是否可以封装成一个通用的 REST 服务，然后使用 `restApiCall` 调用，而不是为了一个小功能去写 Go 组件。

---

> **警告**：重复开发已有的模块是浪费资源的，如果您不确定，请先查阅 [组件库金典](component-catalog.md)。
