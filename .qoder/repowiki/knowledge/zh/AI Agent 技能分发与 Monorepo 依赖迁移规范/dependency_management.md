该仓库并非传统意义上的软件库，而是一个 **AI Agent 技能（Skills）与命令（Commands）的分发中心**。其“依赖管理”主要体现在两个维度：一是技能本身的**分发与安装机制**，二是技能内容中蕴含的 **Monorepo 依赖管理与迁移最佳实践**。

### 1. 技能分发与安装系统
仓库采用基于文件系统的轻量级分发模式，不依赖传统的包管理器（如 npm/pip）来管理技能本身。
- **安装方式**：
  - **官方 CLI**：支持通过 `npx skills add hz-9/skills` 进行远程安装。
  - **自动化脚本**：提供 `scripts/install-skills.sh` 和 `scripts/install-commands.sh`，支持从 GitHub 远程克隆或本地目录直接拷贝。
  - **多语言支持**：脚本内置语言选择逻辑，可根据用户选择安装 `skills/`（英文）或 `skills.zh-CN/`（中文）目录下的内容。
- **目标路径**：默认安装至 `~/.qoder/skills` 或 `~/.agents/commands`，遵循 AI Agent 工具的标准加载路径。
- **冲突处理**：安装脚本会自动检测已存在的同名技能，并提供覆盖确认机制，防止意外丢失用户自定义配置。

### 2. Monorepo 依赖管理实践（技能核心内容）
仓库内的多个核心技能（如 `changeset-gen`、`rush-to-nx`）深度集成了现代 JavaScript/TypeScript Monorepo 的依赖管理方案：
- **pnpm + Changesets**：作为推荐的依赖管理与版本发布标准。`changeset-gen` 技能通过分析 `git diff` 和 `pnpm-workspace.yaml`，自动识别受影响包并生成符合规范的 changeset 文件。
- **Rush.js 到 Nx 的迁移**：`rush-to-nx` 技能提供了一套完整的自动化流程，将基于 Rush.js 的旧式 Monorepo 迁移至 `Nx + pnpm workspace + Changesets` 体系。该过程包括：
  - 解析 `rush.json` 并重构为 `packages/` 扁平结构。
  - 生成 `nx.json`、`project.json` 及 `pnpm-workspace.yaml`。
  - 迁移 Git Hooks（Husky）与 CI/CD 配置（从 `actions-rush` 转向 `pnpm/action-setup`）。
- **环境预检**：相关技能在执行前会通过 `scripts/check-env.sh` 严格校验 Node.js、pnpm、Git 及 `jq` 等底层依赖的版本与存在性，确保依赖环境的稳定性。

### 3. 开发者规范
- **技能开发**：新技能应遵循 `templates/SKILL.md` 定义的元数据格式（name, description）与目录结构。
- **依赖声明**：若技能依赖外部工具（如 `jq`、`pnpm`），必须在 `SKILL.md` 的 Prerequisites 章节明确声明，并在执行流第一步进行环境检查。
- **版本策略**：在涉及包版本变更时，强制使用 Changesets 工作流，禁止手动修改 `package.json` 中的 version 字段。