# Skills Collection

Each skill is a self-contained directory following the [agent-skills specification](https://agentskills.io).

## Skills

| Name | Description |
|------|-------------|
| [git-commit-helper](./skills/git-commit-helper/SKILL.md) | Generate Conventional Commits messages with AI analysis |
| [git-workflow-enhanced](./skills/git-workflow-enhanced/SKILL.md) | Automate the full Git workflow: commit message → branch → prepare-commit-msg hook |
| [grill-me](./skills/grill-me/SKILL.md) | Stress-test plans and designs through relentless questioning |
| [grill-with-docs](./skills/grill-with-docs/SKILL.md) | Challenge designs against domain models and document decisions |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | Automate changeset file generation and commit for pnpm monorepos |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | Migrate Rush.js monorepo to Nx + pnpm workspace + Changesets |
| [write-a-skill](./skills/write-a-skill/SKILL.md) | Create agent skills with proper structure and progressive disclosure |
| [zoom-out](./skills/zoom-out/SKILL.md) | Get high-level context and module maps for unfamiliar code |

## Installation

### Option 1: npx skills (recommended)

```bash
# Install all skills
npx skills add hz-9/skills

# Install a specific skill
npx skills add hz-9/skills --skill git-commit-helper
npx skills add hz-9/skills --skill git-workflow-enhanced
npx skills add hz-9/skills --skill grill-me
npx skills add hz-9/skills --skill grill-with-docs
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
npx skills add hz-9/skills --skill write-a-skill
npx skills add hz-9/skills --skill zoom-out
```

### Option 2: Manual copy

```bash
# Copy a skill to Qoder user skills directory
cp -r skills/<skill-name> ~/.qoder/skills/<skill-name>
```

### Option 3: Install script

```bash
# Install all skills
bash scripts/install.sh

# Install a specific skill
bash scripts/install.sh git-commit-helper
bash scripts/install.sh git-workflow-enhanced
bash scripts/install.sh grill-me
bash scripts/install.sh grill-with-docs
bash scripts/install.sh pnpm-changeset-workflow
bash scripts/install.sh rush-to-nx
bash scripts/install.sh write-a-skill
bash scripts/install.sh zoom-out
```

## Creating a New Skill

Use [templates/SKILL.md](./templates/SKILL.md) as a starting point:

```bash
cp -r templates skills/<your-skill-name>
# Edit skills/<your-skill-name>/SKILL.md
```

### SKILL.md Conventions

- `name` field must match the directory name (kebab-case)
- `description` briefly describes the skill's purpose and when to invoke it
- Body provides complete usage guide, steps, and examples
- Long documents should be split into `REFERENCE.md` and `EXAMPLES.md`

## License

MIT
