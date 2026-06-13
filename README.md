# Skills Collection

Each skill is a self-contained directory following the [agent-skills specification](https://agentskills.io).

## Skills

| Name | Description |
|------|-------------|
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | Generate Conventional Commits messages with AI analysis |
| [git-workflow-enhanced](./skills/git-workflow-enhanced/SKILL.md) | Automate the full Git workflow: commit message → branch → prepare-commit-msg hook |
| [grill-me](./skills/grill-me/SKILL.md) | Stress-test plans and designs through relentless questioning |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | Automate changeset file generation and commit for pnpm monorepos |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | Migrate Rush.js monorepo to Nx + pnpm workspace + Changesets |
| [skill-create](./skills/skill-create/SKILL.md) | Create agent skills with proper structure and progressive disclosure |
| [skill-optimizer](./skills/skill-optimizer/SKILL.md) | Optimize SKILL.md structure, condense redundant content, split reference docs |
| [zoom-out](./skills/zoom-out/SKILL.md) | Get high-level context and module maps for unfamiliar code |

### Installation

#### npx skills

```bash
# Install all skills
npx skills add hz-9/skills

# Install a specific skill
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill git-workflow-enhanced
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill skill-create
npx skills add hz-9/skills --skill skill-optimizer
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
| [grill-me-lite](./deprecated/skills/grill-me-lite/SKILL.md) | Original lite version of grill-me, deprecated, use full [grill-me](./skills/grill-me/SKILL.md) instead |
| [write-a-skill](./deprecated/skills/write-a-skill/SKILL.md) | Renamed to skill-create, please use the new name |

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

## License

MIT
