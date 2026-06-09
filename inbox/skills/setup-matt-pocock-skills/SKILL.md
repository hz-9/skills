---
name: setup-matt-pocock-skills
description: 在 AGENTS.md/CLAUDE.md 中设置 `## Agent skills` 块和 `docs/agents/`，使工程类 skills 知道该仓库的 issue 跟踪器（GitHub 或本地 markdown）、triage 标签词汇表和领域文档布局。在首次使用 `to-issues`、`to-prd`、`triage`、`diagnose`、`tdd`、`improve-codebase-architecture` 或 `zoom-out` 之前运行——或者当这些 skills 似乎缺少关于 issue 跟踪器、triage 标签或领域文档的上下文时运行。
disable-model-invocation: true
---

# 设置 Matt Pocock 的 Skills

搭建工程类 skills 所依赖的每个仓库的配置：

- **Issue 跟踪器**——issues 存放的位置（默认是 GitHub；本地 markdown 也已开箱支持）
- **Triage 标签**——五个规范 triage 角色所使用的字符串
- **领域文档**——`CONTEXT.md` 和 ADR 存放的位置，以及读取它们的消费规则

这是一个由提示驱动的 skill，而不是确定性的脚本。探索，展示你找到的内容，与用户确认，然后写入。

## 流程

### 1. 探索

查看当前仓库以了解其初始状态。读取已有的内容；不要做假设：

- `git remote -v` 和 `.git/config`——这是一个 GitHub 仓库吗？是哪个？
- 仓库根目录下的 `AGENTS.md` 和 `CLAUDE.md`——它们存在吗？其中是否已有 `## Agent skills` 部分？
- 仓库根目录下的 `CONTEXT.md` 和 `CONTEXT-MAP.md`
- `docs/adr/` 和任何 `src/*/docs/adr/` 目录
- `docs/agents/`——该 skill 之前的输出是否已存在？
- `.scratch/`——表明本地 markdown issue 跟踪器约定已在使用中

### 2. 展示发现并提问

总结现存的内容和缺失的内容。然后**一次一个**地引导用户完成三个决策——展示一个部分，获取用户的回答，然后进入下一个。不要一次性全部抛出。

假设用户不知道这些术语的含义。每个部分以一个简短的解释开头（它是什么，为什么这些 skills 需要它，如果选择不同会有什么变化）。然后展示选项和默认值。

**部分 A — Issue 跟踪器。**

> 解释："Issue 跟踪器"是该仓库中 issues 的存放位置。像 `to-issues`、`triage`、`to-prd` 和 `qa` 这样的 skills 会读写它——它们需要知道是调用 `gh issue create`、在 `.scratch/` 下写入 markdown 文件，还是遵循你描述的其他工作流。选择你实际为该仓库管理工作的地方。

默认姿态：这些 skills 是为 GitHub 设计的。如果 `git remote` 指向 GitHub，建议使用 GitHub。如果 `git remote` 指向 GitLab（`gitlab.com` 或自托管主机），建议使用 GitLab。否则（或者如果用户有其他偏好），提供：

- **GitHub**——issues 存放在仓库的 GitHub Issues 中（使用 `gh` CLI）
- **GitLab**——issues 存放在仓库的 GitLab Issues 中（使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI）
- **本地 markdown**——issues 作为文件存放在该仓库的 `.scratch/<feature>/` 下（适合个人项目或没有远程仓库的仓库）
- **其他**（Jira、Linear 等）——让用户用一段话描述工作流；该 skill 将作为自由格式文本记录

**部分 B — Triage 标签词汇表。**

> 解释：当 `triage` skill 处理传入的 issue 时，它通过一个状态机来推动它——需要评估、等待报告者、准备好供 AFK agent 处理、准备好给人类处理、或不会修复。为此，它需要应用与你*实际配置的*字符串匹配的标签（或你在 issue 跟踪器中的等效物）。如果你的仓库已经使用了不同的标签名称（例如使用 `bug:triage` 而不是 `needs-triage`），在此处映射它们，以便该 skill 应用正确的名称而不是创建重复项。

五个规范角色：

- `needs-triage` — 维护者需要评估
- `needs-info` — 等待报告者
- `ready-for-agent` — 完全明确，AFK 就绪（agent 可以在没有人类上下文的情况下接手）
- `ready-for-human` — 需要人类实现
- `wontfix` — 不会处理

默认值：每个角色的字符串等于其名称。询问用户是否要覆盖任何角色。如果他们的 issue 跟踪器没有现有标签，默认值就可以了。

**部分 C — 领域文档。**

> 解释：某些 skills（`improve-codebase-architecture`、`diagnose`、`tdd`）会读取 `CONTEXT.md` 文件来学习项目的领域语言，以及 `docs/adr/` 来了解过去的架构决策。它们需要知道该仓库是有一个全局 context 还是多个（例如一个单仓，包含独立的前端/后端 contexts），以便在正确的位置查找。

确认布局：

- **单一 context**——仓库根目录下一个 `CONTEXT.md` + `docs/adr/`。大多数仓库都是这种。
- **多 context**——根目录下的 `CONTEXT-MAP.md` 指向每个 context 的 `CONTEXT.md` 文件（通常是单仓）。

### 3. 确认和编辑

向用户展示草稿：

- 要添加到正在编辑的 `CLAUDE.md` / `AGENTS.md` 中的 `## Agent skills` 块（选择规则见步骤 4）
- `docs/agents/issue-tracker.md`、`docs/agents/triage-labels.md`、`docs/agents/domain.md` 的内容

在写入之前让他们编辑。

### 4. 写入

**选择要编辑的文件：**

- 如果 `CLAUDE.md` 存在，编辑它。
- 否则如果 `AGENTS.md` 存在，编辑它。
- 如果两者都不存在，询问用户要创建哪个——不要替他们选择。

当 `CLAUDE.md` 已存在时，永远不要创建 `AGENTS.md`（反之亦然）——总是编辑已有的那个。

如果所选文件中已存在 `## Agent skills` 块，原地更新其内容，而不是附加重复内容。不要覆盖用户对周围部分的编辑。

该块：

```markdown
## Agent skills

### Issue 跟踪器

[issues 跟踪位置的一行摘要]。参见 `docs/agents/issue-tracker.md`。

### Triage 标签

[标签词汇表的一行摘要]。参见 `docs/agents/triage-labels.md`。

### 领域文档

[布局的一行摘要——"single-context" 或 "multi-context"]。参见 `docs/agents/domain.md`。
```

然后使用该 skill 文件夹中的种子模板作为起点写入三个文档文件：

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — 本地 markdown issue tracker
- [triage-labels.md](./triage-labels.md) — 标签映射
- [domain.md](./domain.md) — 领域文档消费规则 + 布局

对于"其他"issue 跟踪器，使用用户的描述从头编写 `docs/agents/issue-tracker.md`。

### 5. 完成

告诉用户设置已完成，以及哪些工程类 skills 现在将读取这些文件。提到他们之后可以直接编辑 `docs/agents/*.md`——仅当他们想要切换 issue 跟踪器或从头重新开始时才需要重新运行此 skill。
