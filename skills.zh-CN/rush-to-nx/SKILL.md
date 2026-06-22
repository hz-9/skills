---
name: rush-to-nx
description: 将 Rush.js monorepo 迁移到 Nx + pnpm workspace + Changesets。当用户需要将 Rush.js 项目迁移到 Nx 生态时使用。如需从零创建 Nx monorepo（非迁移），请手动参考详细步骤。
disable-model-invocation: true
---

# [Rush.js](#rushjs) -> [Nx](#nx) + [Changesets](#changesets) 迁移

## Overview

自动化 [Rush.js](#rushjs) monorepo 到 [Nx](#nx) + pnpm workspace + [Changesets](#changesets) 的完整迁移流程：分析现有结构 -> 初始化 [Nx](#nx) 配置 -> 复制源码重组目录 -> 创建 project.json -> 迁移 Git hooks -> 更新 CI/CD -> 验证。适用于包数量不多（<20）、团队希望脱离 [Rush.js](#rushjs) 生态转向标准 pnpm+[Nx](#nx) 工具链的场景。

## Definitions

- <a id="rushjs"></a>**Rush.js**：微软出品的 monorepo 管理工具，使用 `rush.json` 定义项目结构，内置 pnpm 和版本发布策略。
- <a id="nx"></a>**Nx**：通用 monorepo 构建系统，提供任务编排、缓存、依赖图分析能力。
- <a id="changesets"></a>**Changesets**：语义化版本管理工具，通过 changeset 文件记录变更意图，执行时自动 bump 版本、生成 changelog、发布到 npm。

## Prerequisites

- 本地存在 [Rush.js](#rushjs) monorepo 仓库（含 `rush.json`）。
- Node.js >= 18.15.0（<19）或 >=20.9.0（<21），pnpm >= 8.15.9。
- 目标目录有写入权限，Git 已安装配置。
- 如需从零创建 [Nx](#nx) + [Changesets](#changesets) 项目（非迁移），请先阅读详细步骤后手动调整。

## Workflow

0. **前置检查** — 确保迁移条件已满足；
  - 判断 `rush.json` 是否存在：
    - 是 -> 下一步；
    - 否 -> 报告“未找到 rush.json，非 [Rush.js](#rushjs) 项目”，终止流程；
  - 判断 Node.js 版本是否满足 >=18.15.0（<19）或 >=20.9.0（<21）：
    - 是 -> 下一步；
    - 否 -> 提示更新 Node.js 至支持的版本（>=18.15.0 <19 或 >=20.9.0 <21），终止流程；
  - 判断 pnpm 版本是否 >= 8.15.9：
    - 是 -> 下一步；
    - 否 -> 提示更新 pnpm，终止流程；
  - 判断 Git 是否已安装配置：
    - 是 -> 下一步；
    - 否 -> 提示安装/配置 Git，终止流程；
  - 判断 `pnpm-workspace.yaml` 或 `nx.json` 是否已存在：
    - 是 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
      - 检测到已有 Nx workspace 配置，继续覆盖 -> 继续执行，执行后进入下一步；
      - 终止 -> 终止流程；
    - 否 -> 下一步；
  - 判断目标目录是否有写入权限：
    - 是 -> 下一步；
    - 否 -> 报告无权限，终止流程；

1. **分析** — 读取 `rush.json`，梳理项目结构；
  - 统计项目数量、`workspace:*` 依赖关系、自定义 [Rush.js](#rushjs) 命令；
  - 判断项目数量是否为 0：
    - 是 -> 报告“`rush.json` 中未找到任何项目，无法迁移”，终止流程；
    - 否 -> 下一步；
  - 判断包数量是否 >= 20：
    - 是 -> 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
      - 已知风险，继续 -> 继续执行，执行后进入下一步；
      - 不继续 -> 终止流程；
    - 否 -> 下一步；
  - 通过 AskUserQuestion 提供选项，阻塞等待用户选择：
    - [动态选项，由 AI 根据 [分析结果] 生成] -> 确认方案，执行后进入下一步；

2. **初始化** — 创建临时目录，在新仓库中创建 [Nx](#nx) workspace 基础配置，详见 [迁移步骤](references/migration-steps.md#第-2-步初始化-nx-workspace)；

3. **复制源码** — rsync 排除 [Rush.js](#rushjs) 缓存，重组目录，详见 [迁移步骤](references/migration-steps.md#第-3-步复制源码包)；

4. **创建 project.json** — 每个包创建 [Nx](#nx) project.json，详见 [迁移步骤](references/migration-steps.md#第-4-步为每个包创建-project.json)；

5. **迁移 Git hooks** — 创建 Husky 配置，详见 [迁移步骤](references/migration-steps.md#第-5-步迁移-git-hooks)；

6. **更新配置** — 更新 `.gitignore`、`.prettierrc.js` 等，详见 [迁移步骤](references/migration-steps.md#第-6-步更新配置文件)；

7. **更新 CI/CD** — 迁移 CI/CD 配置，详见 [迁移步骤](references/migration-steps.md#第-7-步更新-cicd)；

8. **验证** — 执行构建验证，详见 [迁移步骤](references/migration-steps.md#第-8-步安装依赖并验证)；
  - 判断构建是否通过：
    - 是 -> 下一步；
    - 否 -> 记录失败次数，判断是否已达最大重试次数（3 次）：
      - 是 -> 终止流程，报告无法修复的构建错误；
      - 否 -> 报告错误原因，返回具体步骤（步骤 2~7 中对应环节）修复，修复完成后返回当前步骤重新验证；

9. **复核检查** — 对照 [Review List](#review-list)，确认迁移结果；
  - 判断 Review List 是否有内容：
    - 否 -> 直接进入下一步（成果输出）；
    - 是 -> 下一步；
  - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
    - 基于“复核检查示例”来显示输出内容；
  - 有任一检查失败，判断是否已达最大重试次数（3 次）：
    - 是 -> 终止流程，报告失败项；
    - 否 -> 返回具体步骤（步骤 2~7 中对应环节）修复，修复完成后返回当前步骤重新检查；
  - 全部通过 -> 下一步；

10. **成果输出** — 输出迁移总结，告知完成；
  - 输出结构化摘要（包数量、新建文件、验证结果等）；
  - 告知迁移完成；

## Rules

- **操作规范**
  - 所有配置文件创建和修改操作，先向用户展示方案，确认后再执行；
  - 保留用户原有的非 [Rush.js](#rushjs) 配置文件（`.markdownlint.json`、`.nvmrc`、`.editorconfig` 等），不得删除；
  - 每个涉及文件移动的操作，同步更新相关路径引用；
- **安全规范**
  - 迁移前先在临时目录中构建新仓库结构，验证通过后再应用到目标目录；
- **交互规范**
  - 所有涉及用户抉择的交互环节，**必须**使用 `AskUserQuestion` 工具，禁止以纯文本追问代替；将问题与选项结构化传入 AskUserQuestion，每次调用不超过 4 个问题；
- **自洽性规范**
  - [Review List](#review-list) 检查项必须覆盖 Rules 中所有约束性规则，确保 Rules 与 [Review List](#review-list) 一一对应；

## Examples

### 对话交互示例

**示例：AI 引导用户完成 Rush.js -> Nx 迁移**

```markdown
用户 > 帮我把我这个 Rush.js 项目迁移到 Nx

AI > 触发 rush-to-nx 迁移技能。

首先分析现有结构...
rush.json 中共 3 个项目：
- eslint-config/eslint-config-airbnb
- eslint-config/eslint-config-airbnb-ts
- prettier-config/prettier-config

依赖关系：
- eslint-config-airbnb-ts -> eslint-config-airbnb (workspace:*)
- 无自定义 Rush 命令

建议目录结构：
- packages/eslint-config-airbnb
- packages/eslint-config-airbnb-ts
- packages/prettier-config

[AskUserQuestion]
问题：是否按以上方案继续迁移？
选项：["已知风险，继续", "终止"]

用户 > 已知风险，继续

AI > 开始创建 Nx workspace 基础配置...
已创建 pnpm-workspace.yaml、nx.json、.changeset/config.json、package.json、.npmrc

现在复制源码到新仓库...
已复制所有包到 packages/，已清理 Rush 运行时文件

为每个包创建 project.json...
eslint-config-airbnb: library, lint+build targets ✓
eslint-config-airbnb-ts: library, implicitDependencies=[eslint-config-airbnb] ✓
prettier-config: library, lint target ✓

迁移 Git hooks...
.husky/commit-msg ✓, .husky/pre-commit ✓, commitlint.config.js ✓
```

### 复核检查示例

```markdown
AI > 进入复核检查，对照 Review List 逐项确认：

**迁移完整性检查**
  - 🟩 所有包已重组为 packages/ 结构
  - 🟩 pnpm-workspace.yaml、nx.json 等已创建
  - 🟩 每个包有 project.json

**配置一致性检查**
  - 🟩 Rush 配置文件已移除
  - 🟩 Git hooks 已激活

（AI 运行时将逐项输出全部检查项结果）

**！！！以下检查项未通过！！！**

**最终验证检查**
  - 🟥 pnpm install && pnpm nx run-many --target=build --all 未通过 — 构建错误

终止流程，建议修复后重新执行。
```

### 成果输出示例

```markdown
| 维度 | 说明 |
|------|------|
| [Rush.js](#rushjs) 残留 | 已全部移除 |
| Git hooks | 已激活 |
| CI/CD | 已迁移到 pnpm/action-setup |
| 验证结果 | pnpm install ✓, build ✓ |
```

### 执行成功示例

```markdown
| 维度 | 说明 |
|------|------|
| 项目数量 | 3 个（2 eslint-config + 1 prettier-config） |
| 内部依赖 | 1 个（workspace:* 依赖，[Changesets](#changesets) 发布时自动解析为实际版本） |
| 新建文件 | 5 个（pnpm-workspace.yaml, nx.json, .changeset/config.json, package.json, .npmrc） |
| 包配置 | 3 个 project.json |
| Git hooks | commit-msg + pre-commit |
| CI/CD | 已从 actions-rush 迁移到 pnpm/action-setup |
| 验证结果 | pnpm install ✓, build ✓ |
```

## Review List

完成迁移后，验证以下内容：

- **迁移完整性检查**
    - [ ] 所有包已从 [Rush.js](#rushjs) 结构重组为 `packages/` 平铺结构
    - [ ] `pnpm-workspace.yaml`、`nx.json`、`.changeset/config.json` 已创建
    - [ ] 每个包有 `project.json`，内部依赖已声明 `implicitDependencies`
    - [ ] [Rush.js](#rushjs) 配置文件与运行时产物（`rush.json`、`common/`、`.rush/`、`*.lint.log`）已移除
- **配置一致性检查**
    - [ ] Git hooks（`.husky/commit-msg`、`.husky/pre-commit`）已激活
    - [ ] CI/CD 配置已从 `actions-rush` 更新为 `pnpm/action-setup`
    - [ ] 非 [Rush.js](#rushjs) 的现有配置文件已保留（`.markdownlint.json`、`.nvmrc`、`.editorconfig` 等）
- **最终验证检查**
    - [ ] `pnpm install && pnpm nx run-many --target=build --all` 通过
- **安全性检查**
    - [ ] 迁移前已在临时目录中构建新仓库结构，验证通过后再应用到目标目录
    - [ ] 所有文件移动操作的相关路径引用已同步更新
    - [ ] 所有涉及用户抉择的交互环节已使用 AskUserQuestion 工具而非纯文本追问
    - [ ] 所有配置文件的创建和修改操作已在执行前向用户展示方案并获得确认
- **自洽性检查**
    - [ ] Review List 检查项已覆盖 Rules 中所有约束性规则（操作规范、安全规范、交互规范、自洽性规范），未遗漏

## References

- [快速开始](references/quick-start.md) — 一键命令概览
- [迁移步骤](references/migration-steps.md) — 从分析到验证的 8 步详细指令
- [关键决策点与配置清单](references/configuration.md) — 目录结构、发布流程、版本策略、完成后检查清单
- [常见问题](references/faq.md) — [Nx](#nx) 命令找不到、Husky 不执行、[Changesets](#changesets) hash 前缀
- [迁移示例](EXAMPLES.md) — 从空目录开始的完整迁移实操
- [发布脚本](scripts/release.sh) — 自动 bump、commit、tag、publish 的 shell 脚本
