# RuleGo-Server 模式开发指南

阿沃，本指南专门针对基于 `rulego/examples/server` 项目的开发工作流。请务必遵循“不破坏原始结构”的原则。

---

## 1. 项目结构与约束
`examples/server` 是一个完整的规则引擎服务，通过命令行启动。

- **禁止修改核心逻辑**：请勿直接修改 `cmd/server/server.go`、`internal/service` 等核心逻辑。
- **扩展方式**：
    - **逻辑扩展 (DSL)**：在 `./data/workflows/admin/rule/` 目录下添加 `.json` 规则链文件。
    - **代码扩展 (GO)**：在 `extensions` 目录下新建包，并在 `cmd/server/server.go` 同级新建文件引入。

---

## 2. 项目编译规范 (生产环境必读)

阿沃，核心组件及扩展包对编译环境有严格要求。**禁止直接使用普通的 `go build`**，否则会导致执行时找不到组件。

### 🚨 强制要求
1. **开启 CGO**: `CGO_ENABLED=1`。部分硬件驱动、三方加密库及 SQLite 插件强依赖 CGO。
2. **全量 Tags**: 必须包含全量扩展标签，否则许多 `metadata.nodes` 中的组件将无法解析。

### 标准生产编译命令
```bash
CGO_ENABLED=1 go build \
  -tags "with_extend,with_fasthttp,with_ai,with_ci,with_iot,with_etl" \
  -o rulego-server \
  ./cmd/server/main.go
```

---

## 3. 核心配置详解 (config.conf)

### 3.1 全局变量 (Global Profile)
语法：`${global.xxx}`
- **用途**: 存储 SQL DSN、API Keys、公共 URL 等。
- **铁律**: 严禁在 DSL 中硬编码密码或敏感 IP。

### 3.2 自定义函数 (UDF)
- **注册**: `config.RegisterUdf("name", func)`。
- **详解**: 见 [⚡️ 自定义函数开发 (UDF)](udf-development.md)。

---

## 4. 调试与验证
- **查看日志**：开启 `config.conf` 中的 `debug = true`，日志会打印每个节点的输入输出。
- **热更新重载**：修改 DSL 后，调用 `config.ReloadSelf()` 或重启 Server 进程。
