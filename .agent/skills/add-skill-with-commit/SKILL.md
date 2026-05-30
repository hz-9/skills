---
name: add-skill-with-commit
description: 向技能仓库添加新技能并自动提交变更。当用户完成新技能创建、需要将新技能纳入仓库管理并生成规范的 Git 提交时使用。
---

# Add Skill With Commit

将新技能纳入仓库管理并生成规范化 Git 提交的全流程自动化。

## 工作流程

```
Task Progress:
- [ ] Step 1: 确认新技能目录和 SKILL.md 已创建
- [ ] Step 2: 更新 README.md 技能列表
- [ ] Step 3: 更新 README.zh-CN.md 技能列表
- [ ] Step 4: 更新安装示例（如适用）
- [ ] Step 5: 创建分支并提交变更
```

### Step 1: 确认技能目录

确保新技能已创建在 `skills/<skill-name>/SKILL.md` 路径下：

```bash
ls skills/<skill-name>/SKILL.md
```

验证 SKILL.md 包含正确的 frontmatter：
- `name` — 匹配目录名（kebab-case）
- `description` — 描述技能功能和调用时机

### Step 2: 更新 README.md

在 `README.md` 的技能表格中按字母顺序添加新行：

```
| [<skill-name>](./skills/<skill-name>/SKILL.md) | <英文描述> |
```

### Step 3: 更新 README.zh-CN.md

在 `README.zh-CN.md` 的技能表格中按字母顺序添加新行：

```
| [<skill-name>](./skills/<skill-name>/SKILL.md) | <中文描述> |
```

### Step 4: 更新安装示例

在两个 README 的安装示例中，为新技能添加单独安装命令：

**npx skills 示例：**
```bash
npx skills add hz-9/skills --skill <skill-name>
```

**install.sh 示例：**
```bash
bash scripts/install.sh <skill-name>
```

### Step 5: 创建分支并提交

使用 `git-workflow-enhanced` 技能完成分支创建和提交：

1. **分析变更** — 检查当前所有变更
   ```bash
   git status
   git diff --staged
   git diff
   ```

2. **创建分支**
   - 类型: `feat/`（添加新技能属于新功能）
   - 格式: `feat/add-<skill-name>-skill`
   - 若同时添加多个技能: `feat/add-multiple-skills`

3. **提交变更**
   ```bash
   git add -A
   git commit -m "feat: add <skill-name> skill
   
   - add <skill-name> SKILL.md with full workflow documentation
   - update README.md and README.zh-CN.md skill list
   "
   ```

## 注意事项

- 始终先 `git status` 确认当前仓库状态
- 确保 `install.sh` 无需更新（它自动扫描 `skills/` 下所有目录）
- 分支名和 commit message 遵循 Conventional Commits 规范
- 提交前确认所有变更都已包含（SKILL.md + README 双语言 + 安装示例）
