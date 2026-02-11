# RuleGo AOP 开发指南

AOP (Aspect Oriented Programming) 不需要在规则链 DSL 中配置，而是通过 Go 代码注入到规则引起中。

## 1. 核心概念

AOP 允许您在规则链执行的不同生命周期插入自定义逻辑，例如：
*   链/节点初始化前/后
*   消息到达节点前/后
*   重载、销毁时

## 2. 常用切入点 Pointcut

| 接口方法 | 触发时机 | 典型用途 |
| :--- | :--- | :--- |
| `OnChainBeforeInit` | 规则链初始化前 | 修改 DSL 配置 |
| `OnNodeBeforeInit` | 节点初始化前 | 全局注入配置 |
| `OnCreated` | 初始化完成 | 资源准备 |
| `OnReload` | 规则链更新 | 缓存刷新 |
| `OnDestroy` | 销毁时 | 资源释放 |
| `OnBefore` | 消息处理前 | 权限校验、Tracing |
| `OnAfter` | 消息处理后 | 耗时统计、日志记录 |

## 3. 实现示例

```go
type MyAspect struct {
}

// Order 执行顺序，越小越先执行
func (aspect *MyAspect) Order() int {
    return 0
}

// New 创建实例
func (aspect *MyAspect) New() types.Aspect {
    return &MyAspect{}
}

// OnBefore 节点处理前拦截
func (aspect *MyAspect) OnBefore(ctx types.RuleContext, msg types.RuleMsg, relationType string) types.RuleMsg {
    // 示例：增加一个 TraceID
    msg.Metadata.PutValue("traceId", utils.NewUUID())
    return msg
}

// 注册切面
func init() {
    rulego.Registry.Register(&MyAspect{})
}
```

## 4. 应用场景
1.  **链路追踪**: 在 `OnBefore` 注入 SpanID。
2.  **性能监控**: `OnBefore` 记录开始时间，`OnAfter` 计算耗时并上报 Prometheus。
3.  **动态配置**: 在 `OnNodeBeforeInit` 中根据环境变量修改节点配置。
