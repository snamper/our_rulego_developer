# RuleGo 规则链开发避坑指南 (Pitfalls)

阿沃，RuleGo 极度自由，但也伴随着一些容易让系统瘫痪的“隐形陷阱”。以下是基于实战总结的硬核避坑总结。

---

## 1. 无限递归循环 (Infinite Loops)
这是导致服务器 CPU 飙升、内存溢出的首要原因。

*   **陷阱场景**：规则链 A 通过 `restApiCall` 调用了一个 API 接口，而主网关刚好又把这个接口路由回了规则链 A。
*   **后果**：系统会陷入疯狂的自触发循环。
*   **避坑方案**：
    *   **深度控制**：在元数据中增加 `loop_count`，在 JS 节点中判断，超过 5 次直接丢弃。
    *   **异步解耦**：尽量不要让链的回调直接指向自己的触发路径。

## 2. 响应“黑洞” (Silent Hangs)
明明日志显示节点跑完了，但客户端（curl/浏览器）死活拿不到数据并报超时。

*   **陷阱原因**：
    1.  **没有终点**：规则链没有到达 `end` 节点或没有任何节点执行 `tellSuccess`。
    2.  **Wait 机制冲突**：在 `wait: true` 模式下，主协程在等 `OnEnd` 回调，但某个异步节点（如老版本的某些插件）没有触发这个回调。
*   **避坑方案**：
    *   **必须有 End**：每个业务链的终点请务必挂一个 `type: "end"` 节点。
    *   **日志排查**：如果看到 `IN` 没看到 `OUT`，说明节点逻辑内部挂了（比如代码里的 `panic` 被捕获但没告知引擎）。

## 3. 脚本返回错误 (JS Script Failure)
这是 RuleGo 中最常见的“假死”原因。

*   **陷阱场景**：`jsTransform` 节点里写了 `msg.data = ...;` 但最后一行漏写了 `return {msg: msg, ...};`。
*   **后果**：RuleGo 会认为该节点处理失败，数据在该节点被静默丢弃，后面的链条直接断掉。
*   **避坑方案**：
    *   **严格返回**：永远保证 JS 脚本以 `return {msg: msg, metadata: metadata, msgType: msgType};` 结尾。

## 4. 内联 Endpoint 启动模式禁令
*   **陷阱场景**：在规则链 JSON 里直接定义 `endpoints`。
*   **后果**：
    1.  如果该链作为“子链”被加载，引擎会直接报错：`sub rule chain does not allow endpoint nodes`。
    2.  如果端口被主网关占用，规则链加载会静默失败或导致引擎崩溃。
*   **避坑方案**：
    **【金律】** 所有的 Endpoint 必须统一写在主网关（如 `hbc_api_gateway.json`）中。业务规则链只负责业务逻辑，不要试图自己去监听端口。

## 5. 组件 ID 误用 (Component Identity)
*   **陷阱场景**：混淆了外部请求组件的名字。
*   **真相**：
    *   标准 RuleGo：`restApiCall` (✅ 是这个)
    *   常见的误写：`restClient` (❌ 找不着)
    *   标准的 Websocket：`endpoint/websocket` (✅)
*   **避坑方案**：在编写 DSL 前，务必使用 `tail -f server.log` 观察加载日志，如果看到 `component not found`，第一时间检查组件名。

---

## 🚫 架构级警告：响应状态冒泡失效
阿沃，`responseToBody` 严重依赖 `OnEnd` 回调。而在同步等待 (`OnMsgAndWait`) 模式下，引擎处理完逻辑后的“释放”动作和 `OnEnd` 回调的执行是两个独立的事件。

**最核心的一点**：如果你使用内链 Endpoint（如 `restApiCall` 调用自己监听的接口），目前的源码实现并没有做完善的响应状态冒泡同步。**在生产中严禁使用内联 Endpoint 闭环这种模式。**

---
阿沃，遵循这些规则，你的规则链就能像丝绸一样顺滑！
