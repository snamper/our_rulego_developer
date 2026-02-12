# RuleGo 变量与表达式指南 (Variables & Expressions)

阿沃，RuleGo 提供了一套灵活的变量引用的机制，但在不同节点（JSON 字符串 vs JS 脚本）中，引用语法完全不同。

---

## 1. 核心变量作用域

| 作用域 | 语法 | 说明 |
| :--- | :--- | :--- |
| **消息体** | `msg.xxx` | 访问 Payload 中的字段。通常是 JSON 对象。 |
| **元数据** | `metadata.xxx` | 访问消息携带的元数据（如 `deviceId`, `topic`）。 |
| **规则变量** | `vars.xxx` | 链执行过程中的临时变量（可通过 `flow` 节点共享）。 |
| **全局配置** | `global.xxx` | 在 `config.conf` 或 Go 代码中定义的全局常量。 |
| **系统配置** | `config.xxx` | 引擎本身的配置项。 |

---

## 2. 两种引用模式 (必读)

### 2.1 模式一：JSON DSL 占位符 `${}`
**适用范围**: 节点的 `configuration` 字符串参数（如 SQL, URL, Topic）。

- **示例**: `"sql": "SELECT * FROM users WHERE id = ${msg.userId}"`
- **特点**: 在引擎执行该节点前，会自动将 `${}` 替换为对应的变量值。**仅支持字符串插值。**

### 2.2 模式二：JS / Expression 直接访问
**适用范围**: `jsFilter`, `jsSwitch`, `jsTransform`, `exprFilter`, `exprTransform` 等节点。

- **示例 (JS)**: `if (msg.temp > 50) return true;`
- **示例 (Expr)**: `msg.temp > 50 && metadata.area == 'A1'`
- **🛑 严禁**: **在 JS 代码块中使用 `${}`！** JS 环境会自动注入 `msg`, `metadata` 等全局对象，直接引用变量名即可。

---

## 3. RuleGo JS 编程标准 (强制)

阿沃，为了保证脚本能被正确解析且不造成内存泄漏，请严格遵守以下标准：

### 3.1 必须全量返回
对于转换类节点，必须返回包含完整上下文的对象。

- **✅ JS 转换标准**:
    ```javascript
    // 逻辑处理
    msg.newField = "value";
    metadata.timestamp = Date.now();
    // 必须返回这三个字段
    return {
      "msg": msg,
      "metadata": metadata,
      "msgType": msgType
    };
    ```

- **✅ JS 过滤标准**:
    ```javascript
    return msg.temperature > 50; // 必须返回 Boolean
    ```

- **✅ JS 分支 (Switch) 标准**:
    ```javascript
    return ["Success", "Log"]; // 必须返回字符串数组
    ```

### 3.2 变量操作准则
1.  **禁止 `${}`**: `var id = ${msg.id};` ❌ 是错误的。应写为 `var id = msg.id;` ✅。
2.  **JSON 处理**: 输入的 `msg` 通常已经是 JSON 对象。若需字符串化，使用 `JSON.stringify(msg)`。
3.  **只读全局量**: `global.xxx` 为只读，不可在 JS 中修改。

---

## 4. 特殊系统占位符

在子链或循环场景下，RuleGo 会注入特殊的元数据：
- `${metadata._loopIndex}`: 当前循环的索引。
- `${metadata._loopValue}`: 当前循环的元素值。

---

阿沃，记住：**JSON 配置用 `${}`，脚本内部直接写变量名。** 搞混了会导致脚本解析异常或变量未定义错误！
