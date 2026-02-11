# RuleGo 规则链 JSON Schema 详解

规则链定义是一个 JSON 对象，包含 `ruleChain` 元数据和 `metadata`（节点及连接）。

## 1. ruleChain 对象

| 字段 | 类型 | 描述 |
| :--- | :--- | :--- |
| **id** | string | 规则链租户范围内唯一的 ID。 |
| **name** | string | 规则链名称。必须遵循 **“中文 + 英文”** 格式。 |
| **root** | boolean | 是否为根规则链。 |
| **debugMode** | boolean | 是否开启调试模式，开启后会记录每个节点的执行日志。 |
| **configuration** | object | 规则链级别的配置（Key-Value）。 |

## 2. metadata 对象

### nodes (节点列表)
节点是规则链中的基本处理单元。

```json
{
  "id": "node_unique_id",
  "type": "组件类型 ComponentType",
  "name": "节点名称 NodeName",
  "debugMode": false,
  "configuration": {
    "key": "value"
  }
}
```

- **id**: 规则链内唯一的节点 ID。
- **type**: 组件类型。
- **name**: 节点名称。
- **configuration**: 组件特有的配置参数。

### connections (连接列表)
定义节点之间的流转逻辑。

```json
{
  "fromId": "node_a",
  "toId": "node_b",
  "type": "RelationType"
}
```

- **type**: 关系类型。常见的有：
    - `Success`: 节点执行成功后流向。
    - `Failure`: 节点执行失败后流向。
    - `True`: 过滤器节点返回 true 时流向。
    - `False`: 过滤器节点返回 false 时流向。
    - `SomeType`: 路由节点自定义的类型。

## 示例：一个简单的温控规则链

```json
{
  "ruleChain": {
    "id": "temp_monitor",
    "name": "温度监控 TemperatureMonitor",
    "root": true
  },
  "metadata": {
    "nodes": [
      {
        "id": "s1",
        "type": "jsFilter",
        "name": "高热过虑 HighTemperatureFilter",
        "configuration": { "jsScript": "return msg.temperature > 50;" }
      },
      {
        "id": "s2",
        "type": "log",
        "name": "记录日志 RecordingLogs",
        "configuration": { "jsScript": "return '警告：温度过高：' + msg.temperature;" }
      }
    ],
    "connections": [
      { "fromId": "s1", "toId": "s2", "type": "True" }
    ]
  }
}
```
