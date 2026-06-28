# Skills Collection

Each skill is a self-contained directory following the [agent-skills specification](https://agentskills.io).

## Skills

| Skill Name | Description |
|------------|-------------|
| [changeset-gen](./skills/changeset-gen/SKILL.md) | Analyze affected packages based on staged changes and auto-generate pnpm changeset version files |
| [git-branch-prep](./skills/git-branch-prep/SKILL.md) | Generate commit message via git-commit-helper -> extract branch name -> confirm branch and push -> create PR link |
| [git-cleanup](./skills/git-cleanup/SKILL.md) | Clean up stale Worktrees, branches, and Tags in Git repositories |
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | Intelligently generate Git commit messages following Conventional Commits specification |
| [grill-me](./skills/grill-me/SKILL.md) | Continuously grill plans and designs, traversing every branch of the decision tree |
| [grill-me-lite](./skills/grill-me-lite/SKILL.md) | Lite version of grill-me, quick stress-test plans and designs |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | Migrate a Rush.js monorepo to Nx + pnpm workspace + Changesets |
| [skill-create](./skills/skill-create/SKILL.md) | Create agent skills following the skill-evolve standard |
| [skill-evolve](./skills/skill-evolve/SKILL.md) | Optimize SKILL.md structure, reduce redundancy, split reference docs |
| [skill-evolve-cycle](./skills/skill-evolve-cycle/SKILL.md) | Execute cyclic evolution on a specified SKILL: optimize -> review -> fix -> merge -> feedback |
| [zoom-out](./skills/zoom-out/SKILL.md) | Zoom out to get a code module map and high-level context |
| [zoom-out-lite](./skills/zoom-out-lite/SKILL.md) | Lite version of zoom-out, quickly get high-level code context |

### Installation

#### npx skills

```bash
# Install all skills
npx skills add hz-9/skills

# Install specific skills only
npx skills add hz-9/skills --skill changeset-gen
npx skills add hz-9/skills --skill git-branch-prep
npx skills add hz-9/skills --skill git-cleanup
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill grill-me-lite
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill skill-create
npx skills add hz-9/skills --skill skill-evolve
npx skills add hz-9/skills --skill skill-evolve-cycle
npx skills add hz-9/skills --skill zoom-out
npx skills add hz-9/skills --skill zoom-out-lite
```

#### Install via Script

Supports environment variable `SKILLS_DIR` to override target path (default `~/.qoder/skills`).

```bash
# Install from GitHub remotely
bash scripts/install-skills.sh

# Install directly from local repo (no network required)
bash scripts/install-skills-local.sh
```

One-line command (no need to clone the repo):

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)

# Specify custom directory:
SKILLS_DIR=~/.qoder/skills bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)
```

### Deprecated

| Skill Name | Description |
|------------|-------------|
| [git-workflow-enhanced](./deprecated/skills/git-workflow-enhanced/SKILL.md) | Deprecated, no longer maintained |
| [grill-with-docs](./deprecated/skills/grill-with-docs/SKILL.md) | Deprecated, no longer maintained |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | Deprecated, use changeset-gen instead |
| [write-a-skill](./deprecated/skills/write-a-skill/SKILL.md) | Renamed to skill-create, use the new name instead |

## Commands

The [commands/](./commands/) directory provides reusable Qoder commands. Commands are `.md` files that can be invoked via Qoder's command palette.

| Command | Description |
|---------|-------------|
| [review-and-fix-cycle](./commands/review-and-fix-cycle.md) | Perform Code Review on current code changes, output review log, fix issues and re-review until convergence |

### Commands - Deprecated

| Command | Description |
|---------|-------------|
| [git-ship](./commands/git-ship.md) | Deprecated, use git-branch-prep instead |

#### Install via Script

Supports environment variable `COMMANDS_DIR` to override target path (default `~/.agents/commands`).

```bash
# Install from GitHub remotely
bash scripts/install-commands.sh

# Install directly from local repo (no network required)
bash scripts/install-commands-local.sh
```

One-line command (no need to clone the repo):

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)

# Specify custom directory:
COMMANDS_DIR=~/.qoder/commands bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)
```

## License

MIT
