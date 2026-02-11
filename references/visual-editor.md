# RuleGo 可视化编排指南

RuleGo 支持通过外部编辑器进行可视化规则链开发。

## 1. 官方推荐编辑器
- **RuleGo Editor**: [https://github.com/rulego/rulego-editor](https://github.com/rulego/rulego-editor)
- **在线尝试 (Demo)**: [https://rulego.cc/editor/](https://rulego.cc/editor/)

## 2. 编排工作流
1. 打开可视化编辑器。
2. 从左侧拖拽节点到画板。
3. 配置节点属性（ID, 类型, Configuration）。
4. 连接节点，并选择 Relation 类型（Success, True, False 等）。
5. 点击 **Export** 导出 JSON 文件。
6. 将 JSON 应用到您的项目中：
   ```go
   engine.ReloadSelf(exportedJsonBytes)
   ```

## 3. 注意事项
- 确保导出时选择的是 **RuleGo** 格式而非原本的 ThingsBoard 格式（虽然 RuleGo 兼容，但原生格式更简洁）。
- 编辑器中的节点 ID 必须唯一，连接关系必须符合有向。
- 调试模式 (Debug Mode) 可以在每个节点的配置中开启，方便在画板中观察消息流动（配合 RuleGo Server 使用）。
