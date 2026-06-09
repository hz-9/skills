---
name: triage
description: 通过由 triage 角色驱动的状态机来处理 issues。当用户想要创建 issue、分类 issues、审查传入的 bug 或功能请求、为 AFK agent 准备 issues，或管理工作流程时使用。
---

# 分类

通过一个由 triage 角色组成的小型状态机来推动项目 issue 跟踪器上的 issues。

在 triage 期间发布到 issue 跟踪器的每条评论或 issue **必须**以以下免责声明开头：

```
> *此内容由 AI 在 triage 期间生成。*
```

## 参考文档

- [AGENT-BRIEF.md](AGENT-BRIEF.md) — 如何编写持久的 agent brief
- [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md) — `.out-of-scope/` 知识库如何工作

## 角色

两个**分类**角色：

- `bug` — 某些东西出错了
- `enhancement` — 新功能或改进

五个**状态**角色：

- `needs-triage` — 维护者需要评估
- `needs-info` — 等待报告者提供更多信息
- `ready-for-agent` — 完全明确，准备好供 AFK agent 处理
- `ready-for-human` — 需要人类实现
- `wontfix` — 不会处理

每个经过 triage 的 issue 应恰好携带一个分类角色和一个状态角色。如果状态角色冲突，标记出来并在做任何其他事情之前询问维护者。

这些是规范的角色名称——issue 跟踪器中实际使用的标签字符串可能不同。映射应该已经提供给你了——如果没有，运行 `/setup-matt-pocock-skills`。

状态转换：一个未标记的 issue 通常先进入 `needs-triage`；然后移动到 `needs-info`、`ready-for-agent`、`ready-for-human` 或 `wontfix`。一旦报告者回复，`needs-info` 返回到 `needs-triage`。维护者可以随时覆盖——标记看起来不寻常的转换并在继续之前询问。

## 调用

维护者调用 `/triage` 并用自然语言描述他们想要什么。解释请求并采取行动。示例：

- "显示任何需要我关注的内容"
- "我们看看 #42"
- "将 #42 移到 ready-for-agent"
- "哪些已经准备好给 agents 处理了？"

## 显示需要关注的内容

查询 issue 跟踪器并展示三个分类，最早的优先：

1. **未标记**——从未被 triage。
2. **`needs-triage`**——正在评估中。
3. **自上次 triage 记录以来报告者有活动的 `needs-info`**——需要重新评估。

显示每类的数量和每个 issue 的一行摘要。让维护者选择。

## 处理特定 issue

1. **收集上下文。** 阅读完整的 issue（正文、评论、标签、报告者、日期）。解析任何先前的 triage 记录，以免重复询问已解决的问题。使用项目的领域术语表浏览代码库，并尊重相关区域的 ADR。阅读 `.out-of-scope/*.md`，找出任何先前拒绝过的与此 issue 相似的记录。

2. **推荐。** 告诉维护者你的分类和状态建议及理由，以及与该 issue 相关的简要代码库摘要。等待指示。

3. **复现（仅限 bug）。** 在任何拷问之前，尝试复现：阅读报告者的步骤，跟踪相关代码，运行测试或命令。报告发生了什么——成功复现并附上代码路径、复现失败、或细节不足（强烈的 `needs-info` 信号）。确认的复现能产生更强的 agent brief。

4. **拷问（如果需要）。** 如果 issue 需要充实完善，运行 `/grill-with-docs` 会话。

5. **应用结果：**
   - `ready-for-agent` — 发布 agent brief 评论（[AGENT-BRIEF.md](AGENT-BRIEF.md)）。
   - `ready-for-human` — 结构与 agent brief 相同，但说明为什么不能委托（需要判断的决策、外部访问权限、设计决策、手动测试）。
   - `needs-info` — 发布 triage 记录（模板见下方）。
   - `wontfix`（bug） — 礼貌解释，然后关闭。
   - `wontfix`（enhancement） — 写入 `.out-of-scope/`，在评论中链接到它，然后关闭（[OUT-OF-SCOPE.md](OUT-OF-SCOPE.md)）。
   - `needs-triage` — 应用角色。如果有部分进展，可选添加评论。

## 快速状态覆盖

如果维护者说"将 #42 移到 ready-for-agent"，相信他们并直接应用角色。确认你要做的事情（角色变更、评论、关闭），然后执行。跳过拷问。如果要在没有拷问会话的情况下移至 `ready-for-agent`，询问他们是否想要编写 agent brief。

## Needs-info 模板

```markdown
## Triage 记录

**我们已经确定的：**

- 要点 1
- 要点 2

**我们仍然需要你（@报告者）提供的信息：**

- 问题 1
- 问题 2
```

在"已经确定的"下捕获在拷问期间解决的所有内容，这样工作成果不会丢失。问题必须具体且可操作，而不是"请提供更多信息"。

## 恢复之前的会话

如果 issue 上存在先前的 triage 记录，阅读它们，检查报告者是否已回答了任何未解决的问题，并在继续之前呈现更新后的情况。不要重复询问已解决的问题。
