该仓库是一个 AI Agent 技能（Skills）和命令（Commands）的分发中心，其“配置系统”并非传统意义上的应用运行时配置（如数据库连接、API 密钥等），而是侧重于**技能库的安装、环境依赖检查及目标路径配置**。其核心逻辑通过 Shell 脚本和环境变量实现，遵循“约定优于配置”的原则。

### 1. 配置加载与管理机制
*   **环境变量驱动的目标路径配置**：
    *   `SKILLS_DIR`：用于指定 Skills 的安装目标目录，默认为 `~/.qoder/skills`。
    *   `COMMANDS_DIR`：用于指定 Commands 的安装目标目录，默认为 `~/.agents/commands`。
    *   这些变量在 `scripts/install-skills.sh` 和 `scripts/install-commands.sh` 中通过 `${VAR:-default}` 语法进行加载，允许用户在执行安装前通过导出环境变量来自定义安装位置。
*   **交互式语言配置**：
    *   安装脚本在执行时会通过 `read` 命令发起交互式提示，要求用户选择源语言（English 或 中文）。根据选择，脚本会动态指向 `skills/` 或 `skills.zh-CN/` 目录作为数据源。
*   **本地与远程源切换**：
    *   支持通过 `--repo-dir` 命令行参数指定本地仓库路径，跳过 Git 克隆步骤，直接读取本地文件进行安装。这为开发调试提供了灵活的配置入口。

### 2. 运行时环境检查（Environment Checks）
部分技能（如 `changeset-gen`, `git-branch-prep`）内置了 `scripts/check-env.sh` 脚本，用于在执行核心逻辑前验证运行环境的配置状态：
*   **工具链依赖**：检查 `jq` 是否已安装，因为脚本严重依赖它进行 JSON 处理。
*   **Git 环境配置**：验证当前目录是否为 Git 仓库、Git 版本是否 >= 2.0、是否存在合并冲突或处于 detached HEAD 状态。
*   **项目级配置验证**：
    *   `changeset-gen` 会检查根目录下是否存在 `.changeset/` 目录以及 `package.json` 中是否包含 `@changesets/cli` 依赖。
    *   检查 `pnpm-workspace.yaml` 是否存在且包含 `packages` 字段，以确保技能在正确的 Monorepo 上下文中运行。
*   **输出标准化**：所有检查结果均以 JSON 格式输出到 stdout，便于上层 Agent 解析并决定后续动作。

### 3. 关键配置文件与约定
*   **安装脚本**：`scripts/install-skills.sh`, `scripts/install-commands.sh` 是配置分发的核心入口。
*   **技能元数据**：每个技能目录下的 `SKILL.md` 充当了该技能的“配置文件”，定义了其触发条件、执行逻辑和参考文档。
*   **迁移与集成配置**：在 `rush-to-nx` 等复杂技能中，涉及对 `nx.json`, `.changeset/config.json`, `pnpm-workspace.yaml` 等工程配置文件的生成与修改指导。

### 4. 开发者规范
*   **无硬编码路径**：在安装脚本中，严禁硬编码目标路径，必须使用环境变量并提供合理的默认值。
*   **环境自检**：如果技能依赖于特定的工程配置（如 pnpm workspace），必须在 `scripts/check-env.sh` 中实现对应的检查逻辑，并返回明确的 JSON 错误信息。
*   **多语言隔离**：英文和中文技能/命令必须严格存放在 `skills/` vs `skills.zh-CN/` 或 `commands/` vs `commands.zh-CN/` 目录中，由安装脚本统一处理分发逻辑。