---
name: our_rulego_developer
description: "Expert RuleGo developer guide. Use when: architecting RuleGo projects, writing Rule Chain DSL (JSON), configuring Endpoints (HTTP/MQTT/Cron), implementing StreamSQL, developing Go extensions (Components/UDF/AOP), or integrating RuleGo-Server. Focuses on Server-First architecture, standard naming conventions, and highly reusable, parameterized component design."
---

# RuleGo 专家技能指南 (Expert Developer)

阿沃，欢迎使用 RuleGo 开发专家技能。本技能致力于帮助您构建高性能、高可维护性的规则编排系统。

## 🚨 核心定位：Server-First 架构

**本技能严格构建于 `rulego/examples/server` 开发模式之上。** 

### 开发铁律：
1. **优先使用 DSL**：能用内置组件编排实现的逻辑，绝不写代码。
2. **逻辑解耦**：组件应保持通用，业务参数（URL, 阈值）一律通过 `configuration` 或 `${global.xxx}` 变量传入。
3. **安全第一**：严禁在 DSL 中硬编码密码，统一归口 `config.conf` 的 `global` 节。

---

## 🔍 参考资料库 (必备手册)

阿沃，开发前请务必通读以下文档，避免重复造轮子：

### 核心文档
- **📚 [组件参数金典 (Master Catalog)](references/component-catalog.md)**: 已有组件的全量 JSON 个参数模板。
- **⏱️ [Wait 同步/异步深度解析 (Wait Mechanism)](references/wait-mechanism.md)**: 核心 `wait` 参数对性能与数据流的底层影响。
- **🔗 [子链调用深度闭坑指南 (Sub-Chains)](references/sub-chains.md)**: `flow` 与 `chain` 节点的正确用法及递归死循环预防。
- **🧪 [变量与 JS 编程标准 (JS & Variables)](references/variables-and-expressions.md)**: 插值语法 `${}` 与 JS 代码中变量访问及返回格式的强制标准。
- **🚨 [开发避坑与高频陷阱 (Pitfalls)](references/pitfalls.md)**: 无限递归、响应假死、脚本错误等实战踩坑总结。

### 扩展开发
- **🛠️ [自定义组件开发 (Custom Nodes)](references/custom-components.md)**: 完整 Go 接口实现模版。
- **⚡️ [自定义函数开发 (UDF)](references/udf-development.md)**: 更加轻量级的 Go 逻辑扩展与调用方法。
- **🔪 [AOP 拦截器指南](references/aop.md)**: 在生命周期中注入 GO 逻辑。

### 部署与运维
- **🏗️ [RuleGo-Server 开发模式](references/server-development.md)**: 包含 **CGO 编译规范** 与配置文件详解。
- **🔌 [Endpoint 集成指南](references/endpoint.md)**: 配置 HTTP/MQTT/Cron 入口及“内联闭环”红线。
- **🔌 [平台 API 与 MCP 集成 (Integration)](references/platform-integration.md)**: SSE 数据流与 AI 工具化标准。

---

## 📦 版本控制规范
阿沃，当你完成工作并确认无误后，请使用以下命令同步：
1. `git add -A`
2. `git commit -m "中文备注描述改动"`
3. **根据指示完成 Push 操作**。

阿沃，遵循这套标准，你就是 RuleGo 领域最专业的开发者！
