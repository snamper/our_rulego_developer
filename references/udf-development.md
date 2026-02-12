# RuleGo 自定义函数 (UDF) 开发指南

阿沃，如果你觉得开发一个完整的 `Node` 接口太重，只需要执行一段简单的 Go 代码逻辑，那么 **UDF (User Defined Function)** 是最佳选择。

---

## 1. 什么是 UDF？

UDF 是注册到 RuleGo 引擎配置中的自定义 Go 函数。它们可以通过两种方式调用：
1.  **脚本调用**: 在 `jsFilter` 或 `jsTransform` 中通过 `global.函数名(...)` 调用。
2.  **节点调用**: 使用专门的 `functions` 节点触发。

---

## 2. 在哪里定义与注册？ (重要)

阿沃，这是最关键的地方：**UDF 必须在 Go 代码中完成定义和注册，无法在 JSON DSL 中直接编写 Go 逻辑。**

### 2.1 注册位置
- **标准 SDK 开发**: 在创建 `rulego.NewConfig()` 后，链启动前注册。
- **RuleGo-Server 模式**: 建议在 `cmd/server/` 目录下新建一个扩展文件（如 `with_udf.go`），在 `init()` 函数中注册。

### 2.2 注册示例 (Go Code)
```go
func init() {
    config.RegisterUdf("my_calc", func(a, b int) int {
        return a + b
    })
}
```

---

## 3. UDF 注册语法 (Go 侧)

你可以在初始化 RuleGo 引擎或 Server 时，将函数注册到 `types.Config` 中。

```go
config := rulego.NewConfig()

// 示例 1: 简单的字符串处理
config.RegisterUdf("my_upper", func(s string) string {
    return strings.ToUpper(s)
})

// 示例 2: 复杂的业务逻辑
config.RegisterUdf("check_permission", func(userId string, role string) bool {
    // 这里可以查库或调其他服务
    return userId == "admin" && role == "super"
})
```

---

## 4. 如何在 DSL 中引用？

注册成功后，你可以在 JSON DSL 的以下位置使用：

### 4.1 JS 脚本引用 (JS 增强插件风格)
语法：`global.函数名(参数...)`
> **注意**: 在 JS 代码（`jsFilter`, `jsTransform`）中调用 UDF **必须**带 `global.` 前缀！

```javascript
// 在 jsFilter 或 jsTransform 中
var userName = metadata.userName;

// 1. 调用注册的 Go 函数进行逻辑增强
var isSuper = global.check_permission(userName, "super");

if (isSuper) {
    // 2. 将 Go 侧处理的高性能数据写回消息
    msg.upperName = global.my_upper(userName);
}
return {msg: msg, metadata: metadata, msgType: msgType};
```

### 4.2 `functions` 节点引用 (逻辑编排风格)
如果你想在编排可视化流中清晰标记这一步骤，请使用专用节点。

- **type**: `functions`
- **特点**: 函数返回的 Map 会**自动合并**到 `msg.Data` 中。

```json
{
  "id": "node_enrich_data",
  "type": "functions",
  "name": "从外部DB获取详情 GetDetail",
  "configuration": {
    "functionName": "get_device_detail",
    "params": ["${metadata.deviceId}"]
  }
}
```

---

## 5. 🏗️ 实战案例：`type: "functions"` 深度应用

### 案例 A：高性能数据增强 (Redis/Cache 快捷查询)
如果不希望在 DSL 里写复杂的 Redis 节点组合，可以封装一个 UDF 直接查库并返回结构化数据。

**Go 侧注册**:
```go
config.RegisterUdf("get_device_detail", func(deviceId string) map[string]interface{} {
    return map[string]interface{}{
        "owner": "Alvin",
        "location": "Warehouse-01",
        "status": "online",
    }
})
```

**DSL 节点配置**:
```json
{
  "id": "node_enrich_data",
  "type": "functions",
  "configuration": {
    "functionName": "get_device_detail",
    "params": ["${metadata.deviceId}"]
  }
}
```

### 案例 B：复杂加密/签名校验
JS 引擎在处理 HMAC-SHA256 等复杂加密时性能极低且缺乏原生库支持。

**Go 侧注册**:
```go
config.RegisterUdf("verify_hmac", func(payload, sign, secret string) bool {
    // 使用 Go 标准库执行 CPU 密集型运算
    return cryptoUtils.Verify(payload, sign, secret)
})
```

**DSL 脚本调用**:
```javascript
// 在 jsFilter 节点中极简调用
return global.verify_hmac(msg.raw, metadata.sign, global.app_secret);
```

---

## 6. 🧪 UDF 开发避坑指南

### ❌ 坑 1: 类型不匹配
- **闭坑**: 在 Go 函数内部尽量使用通用类型，或在 JS 侧使用 `parseInt()` 等进行显式转换。

### ❌ 坑 2: 协程安全
- **闭坑**: **必须保证 UDF 是并发安全的**，尽量编写无状态函数。

---

阿沃，记住 **“计算归 Go，逻辑归 DSL”**。UDF 就像是给 RuleGo 脚本插上了 Go 的翅膀，这才是真正的开发精髓！
