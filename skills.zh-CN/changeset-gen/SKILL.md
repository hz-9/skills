---
name: changeset-gen
description: 基于暂存变更分析受影响的包，自动生成 pnpm changeset 版本变更文件。当用户在 nx + pnpm changeset monorepo 中需要为已完成变更生成版本变更文件时使用。
---

# changeset-gen

基于暂存变更分析受影响的包，自动生成 pnpm changeset 版本变更文件。不涉及分支创建、代码提交或推送流程，专注单一职责。

## Overview

本技能是一个纯工具技能，专注于 changeset 文件生成。接收用户指定的版本变更类型和变更摘要，为每个受影响的包生成独立的 changeset 文件。

仅适用于 pnpm changeset 的 monorepo 仓库（支持 nx 生态）。

## Definitions

- <a id="changeset-文件"></a>**changeset 文件**：位于 `.changeset/` 目录下的 Markdown 文件，描述包变更类型和内容，用于 changeset 发布流程自动计算版本号和生成 changelog
- <a id="受影响的包"></a>**受影响的包**：根据 `pnpm-workspace.yaml` 中定义的包目录（如 `packages/*/`、`apps/*/` 等），本次变更涉及到的包

## Prerequisites

- Git 仓库
- 存在暂存变更（`git diff --staged --name-only` 有输出）
- 项目启用了 pnpm changeset（存在 `.changeset/` 目录和 `@changesets/cli`）
- 存在 `pnpm-workspace.yaml` 文件（用于确定包目录结构）

## Workflow

0. **前置检查** — 确保后续任务的先决条件已达成；
  0.1 判断是否在 Git 仓库中：
    - 是 -> 下一步；
    - 否 -> 报告"当前不在 Git 仓库中"，终止流程；
  0.2 判断 Git 版本是否 >= 2.0：
    - 是 -> 下一步；
    - 否 -> 提示升级 Git，终止流程；
  0.3 检测工作区是否存在未暂存或未跟踪的变更（通过 `git status --porcelain` 判断）：
    - 是（存在未暂存/未跟踪变更） -> 执行 `git add .`：
      - 成功 -> 进入步骤 0.4；
      - 失败 -> 报告错误详情，提示用户手动处理后重试，终止流程；
    - 否（工作区干净） -> 进入步骤 0.4；
  0.4 判断 Git 暂存区是否存在内容：
    - 是 -> 下一步；
    - 否 -> 告知用户无变更可分析，终止流程；
  0.5 验证是否启用 pnpm changeset（`.changeset/` 目录和 `@changesets/cli`）：
    - 全部满足 -> 下一步；
    - 任意不满足 -> 报告未满足的条件，终止流程或提示用户处理；
  0.6 验证 `pnpm-workspace.yaml` 存在且包含 `packages` 配置：
    - 是 -> 下一步；
    - 否 -> 报告"缺少 pnpm-workspace.yaml 或 packages 配置"，终止流程；

1. **生成方案建议** — 分析暂存变更，为后续步骤生成两类方案；
  1.1 分析受影响的包
    - 执行 `git diff --staged --name-only` 获取变更文件列表；
    - 读取 `pnpm-workspace.yaml` 中的 `packages` 配置，确定包搜索目录列表（默认 `packages/*/`）；
    - 从变更文件路径中识别包目录，读取每个包 `package.json` 中的 `name` 字段，汇总受影响包列表；
    - 若某包 `package.json` 不存在或缺少 `name` 字段：跳过该包并提示用户；
    - 若未找到任何受影响包：
      - 提示用户当前变更不涉及包目录下的文件，无需生成 changeset，进入步骤 5（成果输出）；
  1.2 生成整体方案
    - 基于所有受影响包的变更内容综合判断，生成 1～3 个整体方案，每个方案包含统一的版本变更级别和变更摘要，适用于所有包；
    - 每个方案包含：
      - 方案编号与标题（如"方案 1：推荐 — 多模块功能更新"）
      - 版本变更级别组合（如 @scope/auth: minor, @scope/core: patch）
      - 建议的变更摘要（如"feat(auth): 添加用户认证模块 & fix(core): 调整配置项"）
      - AI 选择理由
  1.3 生成独立方案
    - 通过 `git diff --staged -- packages/<name>/` 查看每个包的详细变更内容；
    - 基于变更内容分析，为每个包独立生成 1～3 个建议方案，每个方案包含：
      - 方案编号与标题（如"方案 1：推荐 — 新增用户认证模块"）
      - 版本变更级别（major / minor / patch）
      - 建议的变更摘要（如"feat(auth): 添加用户认证模块"）
      - AI 选择理由（如"包含多个新功能导出，建议 minor 升级"）

2. **用户确认方案** — 选择方案模式并逐包/整体确认；
  2.1 选择方案模式
    - 通过 AskUserQuestion 询问用户采用哪种方案模式：
      - 整体方案 -> 使用统一方案，进入子步骤 2.2；
      - 独立方案 -> 每包单独选择方案，进入子步骤 2.3；
  2.2 选择整体方案
    - 展示 Step 1 生成的 1～3 个整体方案；
    - 通过 AskUserQuestion 提供选项，让用户选择其中一个方案，选项包括：
      - [动态选项，由 AI 根据整体方案列表生成] -> 选用该方案，统一应用于所有包，进入下一步；
      - 自定义 -> 让用户自行输入，统一应用于所有包，进入下一步；
  2.3 选择独立方案
    - 按受影响包列表逐包询问，每包独立决策：
      - 展示该包 Step 1 中生成的 1～3 个独立方案；
      - 通过 AskUserQuestion 提供选项，让用户选择其中一个方案，选项包括：
        - [动态选项，由 AI 根据该包的方案列表生成] -> 选用该方案，记录版本变更类型和变更摘要，进入下一个包或下一步；
        - 自定义 -> 让用户自行输入版本变更类型和变更摘要，进入下一个包或下一步；
    - 所有包确认完毕后，进入下一步；

3. **生成 changeset 文件** — 为每个受影响包创建独立 changeset 文件；
  3.1 生成唯一文件名
    - 为每个受影响的包创建独立 `.changeset/<random-name>.md` 文件；
    - 文件名使用随机英文单词组合（如 `adjective-noun-noun`），确保唯一，避免手动命名冲突；
    - 若随机生成的名称与 `.changeset/` 目录中已有文件重名，重新生成直到不冲突；
  3.2 写入 changeset 内容

    ```markdown
    ---
    '@scope/package-name': minor
    ---

    feat: add xxx support for something
    ```

    - 变更摘要使用 Step 2 用户提供的内容；
  3.3 处理多包场景
    - 若多个包受影响，为每个包创建独立 changeset 文件；
  3.4 确认文件路径
    - 文件路径：`.changeset/<random-word-combination>.md`；

4. **复核检查** — 对照 [Review List](#review-list)，确认执行结果；
  4.1 逐项检查 Review List
    - 依次判断 [Review List](#review-list) 中每个检查项，是否通过：
      - 是 -> 继续下一个检查项；
      - 否 -> 进入步骤 4.2；
  4.2 处理未通过项
    - 输出未通过项，询问用户：
      - 保留已生成文件并退出 -> 输出文件路径，终止流程；
      - 删除已生成文件并退出 -> 删除所有文件后终止流程；
      - 返回对应步骤修复 -> 删除已生成的 changeset 文件，通过 AskUserQuestion 询问用户希望返回哪个步骤：
        - 步骤 1（重新分析变更） -> 返回步骤 1；
        - 步骤 2（重新选择方案） -> 返回步骤 2；
        - 步骤 3（重新生成文件） -> 返回步骤 3；
  4.3 全部通过后，进入下一步（成果输出）；

5. **成果输出** — 输出执行摘要，告知完成；
  5.1 处理无受影响包场景
    - 若由"无受影响包"场景进入：输出"当前变更不涉及任何包目录下的文件，无需生成 changeset 文件"，直接告知完成；
  5.2 输出结构化摘要
    - 若正常进入：输出结构化摘要（包含生成的文件列表和路径）；
  5.3 提示暂存
    - 提示用户执行 `git add .changeset/` 将生成的 changeset 文件纳入暂存区，以便后续提交和发布流程使用；
  5.4 告知完成
    - 告知用户完成；

## Rules

- changeset 文件名必须随机唯一，避免手动命名冲突
- 生成文件名前检查 `.changeset/` 目录，确保不覆盖已有文件
- 每个受影响的包各生成一个独立 changeset 文件
- 所有涉及用户决策的交互点必须使用 AskUserQuestion 工具，禁止以纯文本追问形式咨询用户
- 若没有暂存变更，提醒用户先 `git add` 暂存变更
- 本技能仅在步骤 0.3 中按需自动暂存所有未暂存变更（`git add .`），不执行其他 `git commit`、`git push` 或任何分支操作
- 生成的文件仅限 `.changeset/` 目录内

## Examples

### 对话交互示例

**用户选择整体方案**

```markdown
用户> /changeset-gen

AI > 检测到暂存变更，分析受影响包...

     变更文件：
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts

     受影响包：@scope/auth, @scope/core

     ╔══ 整体方案建议 ══╗
     方案 1（推荐）：所有包统一 minor，摘要"feat: 多模块功能更新"
     方案 2：        @scope/auth minor + @scope/core patch
     方案 3：        所有包统一 patch，摘要"fix: 多模块修复"
     ╚══════════════════╝

     请选择方案模式：
     1. 整体方案 — 所有包使用同一方案
     2. 独立方案 — 每个包单独选择

用户> 选整体方案

AI > 展示整体方案选项：
     1（推荐）: 所有包统一 minor — feat: 多模块功能更新
     2:          @scope/auth minor + @scope/core patch
     3:          所有包统一 patch — fix: 多模块修复
     4:          自定义

用户> 方案 1

AI > 已生成 changeset 文件

     .changeset/curly-boxes-type.md → @scope/auth: minor
     .changeset/flat-tigers-run.md → @scope/core: minor
```

**用户选择独立方案**

```markdown
用户> /changeset-gen

AI > 检测到暂存变更，分析受影响包...

     变更文件：
       packages/auth/src/login.ts
       packages/auth/src/signup.ts
       packages/core/src/config.ts

     受影响包：@scope/auth, @scope/core

     ╔══ 整体方案建议 ══╗
     方案 1（推荐）：所有包统一 minor
     方案 2：        所有包统一 patch
     ╚══════════════════╝

     ── 逐包独立方案 ──
     @scope/auth:
       方案 1（推荐）：minor — feat(auth): 添加用户注册模块
       方案 2：        patch — fix(auth): 优化登录模块

     @scope/core:
       方案 1（推荐）：patch — fix(core): 调整配置项默认值
       方案 2：        minor — feat(core): 扩展配置接口

     请选择方案模式：
     1. 整体方案 — 所有包使用同一方案
     2. 独立方案 — 每个包单独选择

用户> 独立方案

AI > @scope/auth 请选择方案：
     1（推荐）：minor — feat(auth): 添加用户注册模块
     2：        patch — fix(auth): 优化登录模块

用户> 方案 1

AI > @scope/core 请选择方案：
     1（推荐）：patch — fix(core): 调整配置项默认值
     2：        minor — feat(core): 扩展配置接口

用户> 方案 1

AI > 已生成 changeset 文件

     .changeset/curly-boxes-type.md → @scope/auth: minor
     .changeset/flat-tigers-run.md → @scope/core: patch
```

### 复核检查示例

```markdown
AI > 进入复核检查，Review List 包含 7 个检查项，开始逐项验收：

**结果检查**
  - 🟩 changeset 文件为每个受影响包独立生成
  - 🟩 版本类型与用户选择一致
  - 🟩 变更摘要与用户输入一致
  - 🟩 changeset 文件名随机唯一
  - 🟩 changeset 文件格式正确（YAML frontmatter 合法，包名已正确引用）
  - 🟩 生成的文件仅限 `.changeset/` 目录内
  - 🟩 未修改任何暂存变更或执行 git 提交/推送操作

全部检查项通过，进入下一步。
```

### 成果输出示例

**changeset 生成完毕**

```markdown
| 项目           | 数量/路径                  |
| -------------- | -------------------------- |
| 受影响包       | 2 个                       |
| 生成 changeset | 2 个                       |
| 文件路径       | .changeset/                |

下一步：请执行 git add .changeset/ 将这些文件纳入暂存区。
```

## Review List

- **结果检查**
  - [ ] changeset 文件为每个受影响包独立生成
  - [ ] 版本类型与用户选择一致
  - [ ] 变更摘要与用户输入一致
  - [ ] changeset 文件名随机唯一，不与现有文件冲突
  - [ ] changeset 文件格式正确（YAML frontmatter 合法，包名已正确引用）
  - [ ] 生成的文件仅限 `.changeset/` 目录内
  - [ ] 未修改任何暂存变更或执行 git 提交/推送操作

## References

- [Changesets 文档](https://github.com/changesets/changesets)
- [pnpm changeset 工作流](https://pnpm.io/using-changesets)
