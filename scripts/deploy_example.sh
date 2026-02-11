#!/bin/bash

# RuleGo Server 部署辅助脚本
# 默认基于 rulego/examples/server

SERVER_DIR="参考目录/rulego/examples/server"
WORKFLOW_DIR="${SERVER_DIR}/data/workflows/admin/rules"

echo "🚀 开始部署 RuleGo 规则链..."

# 检查 server 目录
if [ ! -d "$SERVER_DIR" ]; then
    echo "❌ 错误: 未找到 Server 目录: $SERVER_DIR"
    exit 1
fi

# 确保目标 DSL 目录存在
mkdir -p "$WORKFLOW_DIR"

# 复制示例文件到 Server 的 DSL 目录
# 假设我们想运行 optimized_workflow_retry_rest.json
cp skills/rulego_skill/examples/optimized_workflow_retry_rest.json "$WORKFLOW_DIR/workflow_retry_rest.json"

echo "✅ 规则链已部署到: $WORKFLOW_DIR/workflow_retry_rest.json"
echo ""
echo "🔧 现在您可以进入 $SERVER_DIR 运行 Server:"
echo "   cd $SERVER_DIR && go run cmd/server/main.go"
echo ""
echo "📡 测试触发命令:"
echo "   curl -X POST -H 'Content-Type: application/json' -d '{\"workflowId\": \"wf_12345\"}' http://127.0.0.1:9090/api/v1/rules/workflow_retry_rest/execute/msg"
