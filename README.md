# Skills Collection

Each skill is a self-contained directory following the [agent-skills specification](https://agentskills.io).

## Skills

| Name | Description |
|------|-------------|
| [git-workflow-enhanced](./skills/git-workflow-enhanced/SKILL.md) | Complete Git workflow automation with branch creation and Conventional Commits |
| [pnpm-changeset-workflow](./skills/pnpm-changeset-workflow/SKILL.md) | Automate changeset file generation and commit for pnpm monorepos |
| [rush-to-nx](./skills/rush-to-nx/SKILL.md) | Migrate Rush.js monorepo to Nx + pnpm workspace + Changesets |

## Installation

### Option 1: npx skills (recommended)

```bash
# Install all skills
npx skills add hz-9/skills

# Install a specific skill
npx skills add hz-9/skills --skill git-workflow-enhanced
npx skills add hz-9/skills --skill pnpm-changeset-workflow
npx skills add hz-9/skills --skill rush-to-nx
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
bash scripts/install.sh git-workflow-enhanced
bash scripts/install.sh pnpm-changeset-workflow
bash scripts/install.sh rush-to-nx
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
