# Skills Collection

Each skill is a self-contained directory following the [agent-skills specification](https://agentskills.io).

## Skills

| Skill Name | Description |
|---------|------|
| [git-branch-prep](./skills/git-branch-prep/SKILL.md) | Call git-commit-helper to generate commit message → derive branch name → confirm branch and push → create PR link |
| [git-cleanup](./skills/git-cleanup/SKILL.md) | Clean up stale branches and tags in a Git repository |
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | Intelligently generate Git commit messages following the Conventional Commits specification |
| [grill-me](./skills/grill-me/SKILL.md) | Continuously question plans and designs, traversing every branch of the decision tree |
| [grill-me-lite](./skills/grill-me-lite/SKILL.md) | Lite version of grill-me for quickly stress-testing plans and designs |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | Automatically generate and commit changeset files for pnpm monorepo |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | Migrate Rush.js monorepo to Nx + pnpm workspace + Changesets |
| [skill-create](./skills/skill-create/SKILL.md) | Create agent skills following the skill-evolve standard |
| [skill-evolve](./skills/skill-evolve/SKILL.md) | Optimize SKILL.md structure, streamline redundancy, split reference documents |
| [skill-evolve-cycle](./skills/skill-evolve-cycle/SKILL.md) | Execute cyclic evolution on a specified SKILL: optimize → review → fix → merge → backfeed |
| [zoom-out](./skills/zoom-out/SKILL.md) | Zoom out to get code module maps and high-level context |
| [zoom-out-lite](./skills/zoom-out-lite/SKILL.md) | Lite version of zoom-out for quickly getting high-level code context |

### Installation

#### npx skills

```bash
# Install all skills
npx skills add hz-9/skills

# Install only specific skills
npx skills add hz-9/skills --skill git-branch-prep
npx skills add hz-9/skills --skill git-cleanup
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill grill-me-lite
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill skill-create
npx skills add hz-9/skills --skill skill-evolve
npx skills add hz-9/skills --skill skill-evolve-cycle
npx skills add hz-9/skills --skill zoom-out
npx skills add hz-9/skills --skill zoom-out-lite
```

#### Install via Script

Supports `SKILLS_DIR` environment variable to override target path (default `~/.qoder/skills`).

```bash
bash scripts/install-skills.sh
```

One-liner (no clone needed):

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)

# Specify custom directory:
SKILLS_DIR=~/.qoder/skills bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-skills.sh)
```

### Deprecated

| Skill Name | Description |
|---------|------|
| [git-workflow-enhanced](./deprecated/skills/git-workflow-enhanced/SKILL.md) | Deprecated, no longer maintained |
| [grill-with-docs](./deprecated/skills/grill-with-docs/SKILL.md) | Deprecated, no longer maintained |
| [write-a-skill](./deprecated/skills/write-a-skill/SKILL.md) | Renamed to skill-create, please use the new name |

## Commands

The [commands/](./commands/) directory provides reusable Qoder commands. Commands are `.md` files that can be invoked via Qoder's command panel.

| Command | Description |
|------|------|
| [git-ship](./commands/git-ship.md) | Create branches, generate commit messages, and push based on staged content, finally outputting a PR link |

#### Install via Script

Supports `COMMANDS_DIR` environment variable to override target path (default `~/.agents/commands`).

```bash
bash scripts/install-commands.sh
```

One-liner (no clone needed):

```bash
bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)

# Specify custom directory:
COMMANDS_DIR=~/.qoder/commands bash <(curl -s https://raw.githubusercontent.com/hz-9/skills/master/scripts/install-commands.sh)
```

## License

MIT
