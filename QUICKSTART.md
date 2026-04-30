# Muninn Quickstart (5 minutes)

[English](QUICKSTART.md) · [中文](QUICKSTART.zh.md)

## Who is this for

- You do research / product / engineering and need structured long-term notes
- You collaborate with AI and have been bitten by AI rewriting your notes
- You're willing to spend 1 hour now in exchange for years of orderly knowledge

If any of these don't fit you — start by reading [docs/philosophy.md](docs/philosophy.md) §"When not to use this" first.

## Step 0: Install Obsidian (5 min, one-time)

Download from <https://obsidian.md> and install for your OS.

## Step 1: Clone this repo (1 min)

```bash
git clone https://github.com/Flemyng1999/muninn.git
cd muninn
```

## Step 2: Generate your vault (1 min)

```bash
# Researcher
bash scripts/bootstrap.sh --profile research --out ~/my-vault

# Bare skeleton (product / engineering profiles are still WIP — use core only)
bash scripts/bootstrap.sh --profile none --out ~/my-vault
```

## Step 3: Open in Obsidian (2 min)

1. Launch Obsidian
2. Bottom-left → "Open another vault" → "Open folder as vault"
3. Select `~/my-vault/`
4. The left pane should show: `_Governance / _Skills / _Concepts / 00-Journal / 03-Zettelkasten / README.md`

## Step 4: Install 4 Obsidian plugins (10 min)

Bottom-left gear → Community plugins → Turn on → Browse, install in order:

- **Templater** (required)
- **Dataview** (required)
- **Obsidian Git** (strongly recommended)
- **Kanban** (optional)

Restart Obsidian after installing.

## Step 5: Set the project profile path (5 min, one-time)

Muninn tools are *profile-driven*. You don't edit any script — you set one environment variable:

```bash
export KMS_PROJECT_PROFILE="$HOME/my-vault/_Governance/project_<your_id>.yaml"
```

If you haven't created the profile yet, copy the template:

```bash
cp ~/my-vault/_Governance/project_TEMPLATE.yaml ~/my-vault/_Governance/project_<your_id>.yaml
```

Edit the new file. The minimum required fields:

```yaml
meta:
  project_id: "<your_id>"
  vault_path: "<absolute path of ~/my-vault>"
```

All other fields fall back to defaults defined in [`schemas/project_profile.yaml`](core/_Governance/schemas/project_profile.yaml).

For the full field reference, see `_Governance/schemas/project_profile.yaml` after Step 2.

## Step 6: Read the 4 essential docs (30 min)

Open these in order in Obsidian:

1. `~/my-vault/README.md` (top level)
2. `_Governance/@宪法.md` — focus on §三 (roles), §六 (rule overview), §R08 §8.7 (edit-depth matrix), and §8.8 (content hygiene)
3. `_Skills/02-Workflows/@工作流索引.md` — locate the 8 workflows
4. `_Concepts/README.md` + `03-Zettelkasten/README.md` — what goes where

## Step 7: Run the AI onboarding flow (10 min)

1. Open a fresh AI session (ChatGPT / Claude.ai / Gemini)
2. Open `_Skills/02-Workflows/工作流-AI接入KMS-正式提示词.md`
3. Copy everything between `---PROMPT START---` and `---PROMPT END---`, paste into the AI
4. The AI will ask you to paste a few governance files; do so in order
5. The AI must answer the 5-item acceptance checklist correctly — once it does, your first AI collaboration channel is established

## Step 8: Start daily usage (Day 1 onwards)

See `_Skills/02-Workflows/工作流-早间启动-条件Git-正式提示词.md` for the morning kickoff flow:

- **Morning**: create today's Journal + 2–3 core tasks
- **During the day**: log events with `[HH:MM]` timestamps; cite core concepts via `[[wiki-link]]`
- **Evening**: feed today's Journal to AI, let it surface promotion candidates

## Day 14: Acceptance check

```bash
cd ~/my-vault
bash scripts/kms_health.sh --verbose
```

Pass conditions:

- R02 frontmatter coverage ≥ 95%
- R05 orphan rate = 0
- R06 actionable broken-link rate < 5%
- `00-Journal/` has ≥ 10 files, every entry has an `[HH:MM]` prefix
- `_Concepts/概念-*.md` contains 3–10 seedling master cards

All pass → graduated; you can run independently.

## Which profile should I pick?

| You are | Pick |
|---|---|
| PhD student / researcher | `--profile research` |
| Product / design / founder | `--profile none` (wait for the product profile to mature) |
| Software engineer / architect | `--profile none` (wait for the engineering profile) |
| Not sure yet | `--profile none` — you'll know after two weeks |

Details: [docs/profile-comparison.md](docs/profile-comparison.md).

## Common issues

- **AI claims it edited `_Governance/`** — don't believe it. Re-paste the AI onboarding prompt and start over.
- **Scripts won't run** — the bottom of `scripts/README.md` lists common errors.
- **Wanting to change the constitution** — wait at least 2 months first. 90% of "I want to change the rules" turns out to be "I haven't fully understood them yet".
- **Want to stop using it** — your files are plain Markdown with no lock-in. Just close Obsidian.

## Next steps

- Deeper understanding: [docs/philosophy.md](docs/philosophy.md)
- Compare profiles: [docs/profile-comparison.md](docs/profile-comparison.md)
- Project ↔ vault contract: [docs/repo-vault-interface.md](docs/repo-vault-interface.md)
- AI entry-file content contract: [docs/agent-onboarding.md](docs/agent-onboarding.md)
- Contribute a profile / workflow: [CONTRIBUTING.md](CONTRIBUTING.md)
