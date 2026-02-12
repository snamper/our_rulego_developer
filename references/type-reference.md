# RuleGo Type 类型规范索引 (Type Reference)

阿沃，RuleGo 在 DSL 中使用短字符串（类型码）来标识组件。拼写错误会导致 `component not found` 引擎加载失败。

---

## 1. 核心路由组件 (Core Flow)

| 类型码 (Type) | 对应功能 | 备注 |
| :--- | :--- | :--- |
| `jsFilter` | JS 脚本过滤 | 返回 true/false |
| `jsSwitch` | JS 脚本分发 | 返回数组 `["Success"]` |
| `jsTransform` | JS 脚本转换 | 转换 msg/metadata |
| `exprFilter` | 表达式过滤 | 高性能非 JS |
| `exprTransform` | 表达式转换 | 字段映射计算 |
| `chain` | 嵌套子规则链 | 基础调用 |
| `flow` | 高级流转/子链 | 支持变量路由 `${}` |
| `functions` | 自定义函数调用 | 调用 Go UDF |
| `fork` | 并行分流 | 消息复制 |
| `join` | 并行合并 | 结果等待 |

---

## 2. 外部集成组件 (Integration)

| 类型码 (Type) | 对应功能 | 常用场景 |
| :--- | :--- | :--- |
| `restApiCall` | HTTP REST 调用 | 对外通知、调第三方 API |
| `dbClient` | 数据库操作 | MySQL/Postgres/Oracle |
| `mqttClient` | MQTT 客户端 | 发送物模型指令 |
| `kafkaClient` | Kafka 消息投递 | 数据入大模型、入仓 |
| `redisClient` | Redis 读写 | 高频缓存、计数器 |
| `ai/llm` | 大模型交互 | 意图识别、智能分类 |
| `ci/gitClone` | Git 持久化 | 部署、代码同步 |

---

## 3. 入口 Endpoint 类型 (Endpoint Type)

| 类型码 (Type) | 对应协议 | 监听方式 |
| :--- | :--- | :--- |
| `endpoint/http` | RESTful API | 端口监听 (Address) |
| `endpoint/mqtt` | MQTT Broker | Topic 订阅 |
| `endpoint/schedule` | Cron Job | 时间计划 (Cron) |
| `endpoint/tcp` | TCP 服务 | 原始字节流 |
| `endpoint/udp` | UDP 服务 | 数据报文 |

---

## 4. 关系标签标准 (Relation Types)

| 标签 (Relation) | 触发条件 |
| :--- | :--- |
| `Success` | 节点处理逻辑正常完成 |
| `Failure` | 节点抛出 Error 或执行 Panic |
| `True` | 过滤/条件判断为真 |
| `False` | 过滤/条件判断为假 |
| `Other` | 某些分支切换的默认兜底 |

---

阿沃，写 DSL 前请对照此表。**拼写必须完全一致**，例如 `restApiCall` 的大小写非常敏感！
