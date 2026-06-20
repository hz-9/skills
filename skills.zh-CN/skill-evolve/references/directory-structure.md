# SKILL 目录结构 — 定义 SKILL 的标准目录结构和 references/ 文件规范

## Overview

定义 SKILL 的标准目录结构和 `references/` 文件的格式规范。当优化目标 SKILL 的目录结构或检查 references/ 文件格式时使用。

## 目录结构

```markdown
your-skill-name/
├── SKILL.md          # (必须) 核心执行说明书
├── scripts/          # (可选) 存放可执行的脚本
├── references/       # (可选) 存放详细的参考文档
├── assets/           # (可选) 存放模板、图片等静态资源
├── tests/            # (可选) 存放测试用例，是工程化的重要一环
└── schemas/          # (可选) 用于与其他Skill传递数据，实现串联
```

## References

### references/ 文件内容规范

`references/` 下的每个规范文件（workflow-standard.md、punctuation-convention.md、text-optimization.md 及其扩展）必须遵循以下结构：

- 以 `# [文件名] — 一句话职责描述` 开头
- 包含 `## Overview` 节，简要说明职责
- 包含一个或多个 `##` 主体内容节
- **必须**以 `## 验证清单` 结尾，清单中列出该文件覆盖的所有检查项
- `## 验证清单` 下可使用 `###` 子分组组织清单项（纯为可读性，不影响引用）

Workflow 步骤 3 中的"目录结构检查"会验证所有 references/ 文件是否符合此结构。

### 自身进化场景

当目标 SKILL 在技能原始仓库中为 `skill-evolve` 自身（`是否自身进化 = true`），且 template.md 存在时，template.md 也应被纳入检查范围：

- 若 template.md 与 SKILL.md 存在同字段/间引用，对 SKILL.md 的修改应验证 template.md 是否需同步更新
- 自身进化场景下，Workflow 步骤 0 的前置检查应额外验证 template.md 存在且结构可解析

## 验证清单

- [ ] 文件以 `# [文件名] — 描述` 格式开头
- [ ] 包含 `## Overview` 节
- [ ] 末尾有 `## 验证清单` 节
- [ ] 验证清单列出了该文件覆盖的所有检查项

