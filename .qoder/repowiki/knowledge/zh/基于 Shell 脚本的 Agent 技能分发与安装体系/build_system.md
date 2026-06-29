该项目是一个 AI Agent 技能（Skills）与命令（Commands）的分发中心，其构建与部署体系主要围绕 **Shell 脚本自动化安装** 和 **标准化目录结构** 展开。项目不包含传统的编译型构建流程（如 Makefile、Maven、Gradle 等），而是采用“即拷即用”的分发模式。

### 1. 核心构建与分发方式
- **脚本化安装器**：项目在 `scripts/` 目录下提供了一套 Bash 脚本，用于将技能和命令从仓库同步到本地 Agent 运行环境（默认为 `~/.qoder/skills` 或 `~/.agents/commands`）。
  - `install-skills.sh` / `install-commands.sh`：支持从 GitHub 远程克隆仓库并提取特定语言版本的资源。
  - `install-skills-local.sh` / `install-commands-local.sh`：支持直接从本地仓库路径进行同步，适用于离线或开发调试场景。
- **多语言支持机制**：安装脚本内置了交互式语言选择逻辑，允许用户在安装时选择 `English`（对应 `skills/` 目录）或 `中文`（对应 `skills.zh-CN/` 目录），实现了同一仓库下的多版本并行维护与按需分发。
- **一键远程部署**：通过 `curl` 管道执行远程脚本的方式（如 `bash <(curl -s ...)`），实现了无需手动 Clone 仓库即可快速集成技能的“零配置”部署体验。

### 2. 关键文件与目录结构
- **`scripts/`**：存放所有安装逻辑的核心脚本，处理 Git 克隆、目录扫描、冲突检测及文件拷贝。
- **`skills/` & `skills.zh-CN/`**：标准化的技能存储目录，每个子目录代表一个独立的 Skill，内部遵循 `SKILL.md` + `references/` + `scripts/` 的规范结构。
- **`commands/` & `commands.zh-CN/`**：存放可复用的 Qoder 命令定义文件（`.md` 格式）。
- **`deprecated/`**：用于归档已废弃的技能版本，确保主目录的整洁与稳定性。

### 3. 架构约定与开发者规范
- **原子化技能设计**：每个 Skill 必须是一个自包含的目录，且根目录下必须包含 `SKILL.md` 作为入口描述文件。
- **幂等性安装**：安装脚本具备冲突检测能力，若目标位置已存在同名技能，会提示用户选择是否覆盖，防止意外数据丢失。
- **环境隔离**：通过 `SKILLS_DIR` 和 `COMMANDS_DIR` 环境变量，允许用户自定义安装路径，适应不同的 Agent 客户端配置需求。

### 4. 总结
该项目的“构建系统”实质上是**资源同步与生命周期管理系统**。它通过轻量级的 Shell 脚本解决了跨环境、跨语言的 Agent 能力分发问题，强调了易用性（One-line install）和规范性（Standardized Directory Layout）。