# Skills Collection

Each skill is a self-contained directory following the [agent-skills specification](https://agentskills.io).

## Skills

| Name | Description |
|------|-------------|
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | Generate Conventional Commits messages with AI analysis |
| [grill-me](./skills/grill-me/SKILL.md) | Stress-test plans and designs through relentless questioning |
| [grill-with-docs](./skills/grill-with-docs/SKILL.md) | Challenge designs against domain models and document decisions |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | Automate changeset file generation and commit for pnpm monorepos |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | Migrate Rush.js monorepo to Nx + pnpm workspace + Changesets |
| [write-a-skill](./skills/write-a-skill/SKILL.md) | Create agent skills with proper structure and progressive disclosure |
| [zoom-out](./skills/zoom-out/SKILL.md) | Get high-level context and module maps for unfamiliar code |

### Installation

#### npx skills

```bash
# Install all skills
npx skills add hz-9/skills

# Install a specific skill
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill grill-with-docs
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill write-a-skill
npx skills add hz-9/skills --skill zoom-out
```

#### Install script

Supports `SKILLS_DIR` environment variable to override the target path (default `~/.qoder/skills`).

```bash
bash scripts/install-skills.sh
```

One-liner (no clone required):

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)

# Specify a custom directory:
SKILLS_DIR=~/.qoder/skills bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)
```

### Deprecated

| Name | Description |
|------|-------------|
| [git-workflow-enhanced](./deprecated/skills/git-workflow-enhanced/SKILL.md) | Automate the full Git workflow: commit message → branch → prepare-commit-msg hook |

## Commands

The repository also provides reusable Qoder commands in the [commands/](./commands/) directory. Commands are `.md` files that can be invoked via the command palette in Qoder.

| Command | Description |
|---------|-------------|
| [git-ship](./commands/git-ship.md) | Create branch from staged changes, generate commit messages, push, and output PR link |

#### Install script

Supports `COMMANDS_DIR` environment variable to override the target path (default `~/.agents/commands`).

```bash
bash scripts/install-commands.sh
```

One-liner (no clone required):

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)

# Specify a custom directory:
COMMANDS_DIR=~/.qoder/commands bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)
```

## Step - 2: Document Sync

Ensure the skills under the `skills/` directory are consistent with the content under the `## Skills` section in README.zh-CN.md:
- New skills are added to the table and the `Install script` section;
- Deprecated skills are moved to the `### Deprecated` section and removed from the `Install script` section;
- Updated skills can be modified directly in the table;

Ensure the commands under the `commands/` directory are consistent with the content under the `## Commands` section in README.zh-CN.md:
- New commands are added to the table and the `Install script` section;
- Deprecated commands are moved to the `#### Deprecated` section and removed from the `Install script` section;
- Updated commands can be modified directly in the table;

## Step - 3: Chinese-English Sync

Translate README.zh-CN.md to English and synchronize to README.md to maintain the same directory structure and content.

## License

MIT
