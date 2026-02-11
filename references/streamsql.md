# StreamSQL 开发指南

StreamSQL 允许您使用 SQL 语法处理实时数据流。它是处理时间窗口、聚合和过滤的利器。

## 1. 核心概念

StreamSQL 并非查询数据库，而是查询**流经规则链的消息**。

- **输入流**: 规则链中的消息流。
- **输出**: 处理后的结果，流入下一个节点。

## 2. 语法参考

```sql
SELECT 
    avg(temperature) as avg_temp, 
    device_id 
FROM msg 
WHERE temperature > 20 
GROUP BY device_id, TUMBLINGWINDOW(ss, 10)
```

- **SELECT**: 选择字段，支持 `${metadata.key}`。
- **FROM**: 固定为 `msg`（消息体）或 `metadata`。
- **WHERE**: 过滤条件。
- **GROUP BY**: 分组键。
- **WINDOW**: 窗口函数（核心）。

## 3. 窗口函数

1.  **Tumbling Window (滚动窗口)**:
    - 不重叠，每隔 N 秒结算一次。
    - `TUMBLINGWINDOW(ss, 10)`: 每 10 秒输出一次聚合结果。

2.  **Hopping Window (滑动窗口)**:
    - 可以重叠。
    - `HOPPINGWINDOW(ss, 10, 5)`: 窗口大小 10 秒，每 5 秒滑动一次。

3.  **Sliding Window**:
    - 基于事件触发。

## 4. 在 RuleGo 中使用

使用 `dbClient` 节点，但配置特殊类型：

```json
{
  "id": "stream_agg",
  "type": "dbClient",
  "configuration": {
    "driverName": "stream-sql",
    "sql": "SELECT avg(val) FROM msg GROUP BY TUMBLINGWINDOW(ss, 5)"
  }
}
```

注意：需要引入 `rulego-components/stats` 包。
