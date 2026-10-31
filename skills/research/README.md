# research — research skills

A collection for document extraction, media processing, web research, diagrams, and report writing. Each skill can be used independently; `orchestrator` routes workflows with multiple steps.

## Skills

| Skill | Role |
|---|---|
| [`orchestrator`](orchestrator/SKILL.md) | Identify needs and coordinate skills |
| [`doc`](doc/SKILL.md) | Read/convert PDF, DOCX, and XLSX |
| [`media`](media/SKILL.md) | Process video, audio, and images |
| [`web`](web/SKILL.md) | Read and search online sources |
| [`paper`](paper/SKILL.md) | Write international-standard or Vietnamese public-facing reports |

## Session skills (fetched per session, not redistributed)

Third-party skills are fetched with `scripts/fetch-session.sh` (URL + commit-SHA pin only, nothing committed here):

| Skill | Source | Used for |
|---|---|---|
| `watch` | bradautomates/claude-video | media content summaries for `media` |
| `agent-reach` | Panniantong/Agent-Reach | web, social, and search backends for `web` |
| `docling` | docling-project/docling | PDF and DOCX conversion for `doc` |
| `docx` | anthropics/skills | styled DOCX export for `doc` |
| `pdf` | anthropics/skills | styled PDF export for `doc` |
| `citation-management` | K-Dense-AI/scientific-agent-skills | citation capture and management for `paper` |
| `litreview` | K-Dense-AI/scientific-agent-skills | literature review and source scoring for `paper` |
| `exploratory-data-analysis` | K-Dense-AI/scientific-agent-skills | data exploration methodology and checks for `doc` |
| `statistical-analysis` | K-Dense-AI/scientific-agent-skills | statistical method selection for `doc` |
| `matplotlib` | K-Dense-AI/scientific-agent-skills | standard charts for `doc` |
| `archify` | tt-a1i/archify | code-backed diagrams and explainers for `orchestrator` |
| `impeccable` | pbakaus/impeccable | system UI design language for `web` |
| `ppt-master` | hugohe3/ppt-master | PPTX deck creation for `paper` |
| `taste-skill` | Leonxlnx/taste-skill | HTML and one-page design quality checks for `web` |
| `deep-research` | asgeirtj/system_prompts_leaks | deep-research workflow for `web` |
| `last30days` | mvanhorn/last30days-skill | recent-signal discovery for `web` |
| `efficient-web-research` | sickn33/agentic-awesome-skills | token-efficient research for `web` |
| `wiki-researcher` | sickn33/agentic-awesome-skills | wiki research for `web` |
| `citation-verification` | galaxy-dawn/claude-scholar | authority-ordered citation verification for `paper` |
| `tech-writing-proofread` | sickn33/agentic-awesome-skills | technical writing proofreading for `paper` |
| `write-in-my-voice` | sickn33/agentic-awesome-skills | author-voice drafting for `paper` |
| `stakeholder-investor-reports` | sickn33/agentic-awesome-skills | investor and board reports for `paper` |
| `survey-generator` | sickn33/agentic-awesome-skills | source-backed survey papers for `paper` |
| `avoid-ai-writing` | conorbronsdon/avoid-ai-writing | prose audit and AI-ism removal for `paper` |

## Install

```bash
npx skills add tpc-pascal/skillsmith --skill orchestrator --skill doc --skill media --skill paper --skill web
```

Replace the skill list with the names of the skills to install individually.

## General flow

```text
Request ▸ orchestrator ▸ doc / media / web ▸ paper ▸ optional session tools ▸ verify
```

`▸` means hand off to the next step; `/` means choose the relevant skill, not necessarily run all of them. Web/API sources require connectivity; local-file processing prefers local tools and can continue offline when required tools are available.

## Reports

The `paper` skill supports exactly two forms:

- **International-standard report:** follow the requirements of the relevant field, journal, or organization and guidance for the study type.
- **Vietnamese public-facing report:** explain content to general readers in clear Vietnamese; this is an editorial form, not an official national standard.

Before writing, confirm purpose, audience, report form, language, output, and source scope when not already clear. Keep the main report focused on content; put long extractions, raw data, and supporting assets in separate files when useful.

## Checks

Run `bash scripts/smoke.sh` from the repository root to check syntax, frontmatter, structure, and secrets.
