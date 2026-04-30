# Muninn

[English](README.md) · [中文](README.zh.md)

> *"Muninn (Old Norse: 'memory') — one of Odin's two ravens, who flies the world every day and brings back what it sees. The other one, Huginn, is 'thought'."*

**A constitution-driven personal knowledge management system for the AI era** — Obsidian vault skeleton, an explicit constitution, and 8 ready-to-paste AI collaboration workflows.

## Why "Muninn"?

Corvids (the raven family) are the IQ champions of the bird world:
- **High intelligence** — they recognize abstract symbols and solve multi-step tool problems
- **Long-term memory** — they remember individual human faces for years
- **Tool users** — they not only use tools, they **make and keep** tools — exactly what `_Skills/` workflows do
- **Collaborate with humans** — Nara crows in Japan share information with people while foraging

Those four traits are what a personal knowledge system in the AI era should look like:
**smart, persistent, equipped with reusable tools, and able to work with humans.**

## What this is

A public template repository that lets you spin up a working Obsidian KMS in 5 minutes, with the following properties built in:

1. **SSOT (Single Source of Truth)** — every core concept has exactly one authoritative card
2. **Arbiter–Executor boundary** — you decide; AI executes; explicit rules prevent AI from rewriting your definitions
3. **Lifecycle management** — every card carries `seedling / live / superseded / deprecated / retracted / archived` state
4. **Health dashboard** — a weekly script reports orphans, broken links, frontmatter coverage, etc. (8 metrics, R01–R08)

## Three profiles

| Profile | Status | For whom |
|---|---|---|
| **research** | ✅ stable | PhD students / researchers / academics |
| **product** | 🟡 WIP | PMs / designers / founders |
| **engineering** | 🟡 WIP | software engineers / architects / SREs |

Details: [docs/profile-comparison.md](docs/profile-comparison.md).

## Quick start (5 minutes)

```bash
# 1. Clone
git clone https://github.com/Flemyng1999/muninn.git
cd muninn

# 2. Generate your vault (pick a profile)
bash scripts/bootstrap.sh --profile research --out ~/my-vault

# 3. Open Obsidian → Open folder as vault → choose ~/my-vault

# 4. Read ~/my-vault/README.md and follow the 3-day onboarding
```

Full new-user guide: [QUICKSTART.md](QUICKSTART.md).

## Repository layout

```
muninn/
├── core/                         # 80% generic skeleton
│   ├── _Governance/              # constitution + rules + schemas
│   ├── _Skills/                  # 7 generic AI workflows (morning kickoff, evening wrap-up, ...)
│   ├── scripts/                  # profile-driven health dashboard
│   └── _Concepts / 00-Journal / 02-Projects / 03-Zettelkasten / .obsidian
│
├── profiles/
│   ├── research/                 # complete (literature workflow + experiment/gate schemas)
│   ├── product/                  # WIP — contributions welcome
│   └── engineering/              # WIP — contributions welcome
│
├── docs/
│   ├── philosophy.md             # why this design
│   ├── profile-comparison.md     # research vs product vs engineering
│   ├── repo-vault-interface.md   # repo ↔ vault contract template
│   ├── working-control-panel.md  # WORKING.md runtime-state rules
│   ├── agent-onboarding.md       # entry-file content contract (CLAUDE.md / AGENTS.md / ...)
│   └── known-issues.md           # debt log
│
├── examples/                     # 3 worked examples (28 files)
│   ├── research-full/            # complete fictional research project
│   ├── product-teaser/           # decision card + persona + North Star
│   └── engineering-teaser/       # ADR + postmortem + consistency boundary
│
└── scripts/bootstrap.sh          # core + profile overlay tool
```

## Core features

### 1. Constitution + R01–R08 hard rules

- **R01 SSOT** — core concepts only defined in master cards
- **R02 frontmatter coverage** ≥ 95%
- **R03 memory hygiene** — AI auto-memory does not hoard `project_*` originals
- **R04 narrative spine** — each project has one MOC
- **R05 orphan rate** = 0
- **R06 broken-link rate** < 10% (raw) / < 5% (actionable)
- **R07 upgrade queue** — `seedling → live` is a process
- **R08 lifecycle + edit-depth matrix** — three tiers; the deepest tier requires Q3 three-element approval

### 2. R08 §8.7 edit-depth matrix + §8.8 content hygiene

When AI is asked to modify a card, classify by verb:

| Tier | Trigger verbs | AI behavior |
|---|---|---|
| 🟢 content_patch | append / fix / add / review | edit directly, report diff |
| 🟡 structure_refactor | split / merge / promote / rename / move | Arbiter approves once, then execute + provide grep impact report |
| 🔴 definition_governance | change definition / flip / deprecate / retract / change rules | **draft only**, wait for Q3 three-element written approval |

Q3 three-element: (a) Arbiter has read it (b) impact assessed via grep (c) explicit written judgment (not just "OK").

R08 §8.8 adds content-quality rules for long-lived cards: decontextualize temporary route names, keep short-term task state out of evergreen cards, mark evidence strength where useful, and remove agent-process wording unless the card is about agent/tool behavior.

### 3. Eight ready-to-paste AI workflows

| Workflow | Trigger |
|---|---|
| Morning kickoff (conditional Git) | start of day |
| Evening wrap-up (Git close-out) | end of day, AI picks promotion candidates |
| Inbox triage / sorting | clearing daily inbox |
| Meeting capture | after a meeting |
| Card draft + maintenance | new card / orphan rescue / broken-link fixes |
| AI onboarding to KMS | bringing an external AI (ChatGPT / Gemini / Claude.ai) into the vault |
| KMS handoff | passing the system to another person |
| Literature capture | after reading a paper *(research profile)* |

Each workflow comes as a **pair**: an explainer (`.md`) and a paste-into-AI prompt (`-正式提示词.md`).

### 4. Health dashboard

```bash
export KMS_PROJECT_PROFILE="$HOME/my-vault/_Governance/project_<id>.yaml"
bash scripts/kms_health.sh                    # markdown report to stdout
bash scripts/kms_health.sh --save             # also save to <repo>/out/kms_health/<date>.md
python scripts/kms_r06_classify.py --verbose  # deep dive on broken links
```

Run weekly. The pass line: R02 ≥ 95% / R05 = 0 / R06-actionable < 5%.

## Who should (or shouldn't) use this

### A good fit ✅

- You do research / product / engineering, with at least 5 worth-recording info points per week
- You collaborate with AI and have been bitten by AI rewriting your notes
- You're willing to spend 1 hour reading the constitution in exchange for 3 years of structured records

### Not a good fit ❌

- Your work doesn't need cross-month accumulation
- You haven't yet built a habit of writing daily / weekly notes — start with Notion for 3 months first
- You don't intend to collaborate with AI — half of Muninn's value disappears
- You only want a knowledge-graph toy — Logseq or Roam is closer

## Design philosophy

See [docs/philosophy.md](docs/philosophy.md). Three principles:

1. **SSOT** — core definitions in exactly one place
2. **Arbiter–Executor boundary** — AI is bound by explicit institutional rules
3. **Three-layer separation** — constitution / workflows / data evolve independently

## Key documents

| Document | Purpose |
|---|---|
| [docs/philosophy.md](docs/philosophy.md) | Why this design |
| [docs/profile-comparison.md](docs/profile-comparison.md) | research vs product vs engineering |
| [docs/repo-vault-interface.md](docs/repo-vault-interface.md) | Project repo ↔ vault contract template |
| [docs/agent-onboarding.md](docs/agent-onboarding.md) | Required content for entry files (CLAUDE.md / AGENTS.md / ...) |
| [docs/known-issues.md](docs/known-issues.md) | Debt log |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute starting guide |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Adding profiles / workflows / schema extensions |

## Contributing

- **New profile** — `profiles/<name>/`; see `profiles/research/` as the reference; PRs welcome
- **New workflow** — `core/_Skills/02-Workflows/<workflow-scenario-goal>.md` plus its paired `-正式提示词.md`
- **Constitution change** — open a proposal under `core/_Governance/proposals/`; do not patch `@宪法.md` / `rules.yaml` directly

Details: [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. The constitution text, workflows, scripts, and schemas can all be modified, used commercially, and redistributed.

## Acknowledgments

- Norse mythology gave this project its name
- Obsidian gives this project its substrate
- Many session-disasters of "AI rewriting my notes" gave this project its motivation

## Contact

Issues / PRs welcome. For commercial inquiries, custom profiles, or team editions, please open an issue.
