---
trigger: glob
glob: "skills.zh-CN/skill-evolve/**"
---

### 编辑后自检提醒

编辑 `skills.zh-CN/skill-evolve/` 下的文件完成后，提醒用户：
- 本技能（skill-evolve）的文件已被修改，建议运行 skill-evolve 对其自身执行优化
- 特别检查：
  - 新增内容是否符合[内容边界标准](../skills.zh-CN/skill-evolve/references/content-boundary.md)的所有权表
  - 标点符号规范、引号风格是否被新内容违反
  - 引用执行规范是否被遵守（Workflow 中"逐项读取"指令、Rules 中行为约束）
  - SKILL.md 行数是否超过 450 行（距 500 上限不足 50 行预警）
---
trigger: glob
glob: "skills.zh-CN/skill-evolve/**"
---

### 编辑后自检提醒

编辑 `skills.zh-CN/skill-evolve/` 下的文件完成后，提醒用户：
- 本技能（skill-evolve）的文件已被修改
- 建议手动运行 skill-evolve 对其自身执行一遍优化流程，确保自指一致性
- 特别检查以下维度：
  - 标点符号规范（punctuation-convention.md 规则 1-6）是否被新内容违反
  - 格式规范（SKILL.md Rules 中的"格式规范"分组）是否得到遵守
  - 引号风格是否统一（使用弯引号 `""` 而非 `「」`）
  - 非分支节的行末标点是否使用句号而非分号
