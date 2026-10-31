#!/usr/bin/env bash
# fetch-session.sh — fetch skills from their official source repos into a TEMP session directory.
# Nothing is installed permanently: the directory disappears on reboot / tmp cleanup.
# Every source is pinned by commit SHA (no tags/branches, to avoid silent drift).
set -euo pipefail



WATCH_URL="https://github.com/bradautomates/claude-video.git"
WATCH_SHA="03ceb42f7fa2c4439aca01752118044baabffb8f"

AGENTREACH_URL="https://github.com/Panniantong/Agent-Reach.git"
AGENTREACH_SHA="14c213405669414492bda0f8d52cc6531d062c45"

DOCLING_URL="https://github.com/docling-project/docling.git"
DOCLING_SHA="764b5d4dc22b03ea87afd4c2207f510300b27a5b"

AS_URL="https://github.com/anthropics/skills.git"
AS_SHA="ca45fc496a3436251f191354091d557da31c15b5"

KS_URL="https://github.com/K-Dense-AI/scientific-agent-skills.git"
KS_SHA="5f2bc0341354fd5590aef76a533ada1e1e5b4e62"

AX_URL="https://github.com/tt-a1i/archify.git"
AX_SHA="a4065941f12be7967436261d9934784e381d423c"

IM_URL="https://github.com/pbakaus/impeccable.git"
IM_SHA="4f956490f0056ae1ff5ea80372cf56e83c001d3c"

PX_URL="https://github.com/hugohe3/ppt-master.git"
PX_SHA="5e8856be0da8e6bc85c4aa28acc614478f7b7137"

TS_URL="https://github.com/Leonxlnx/taste-skill.git"
TS_SHA="12af471f627f866411b4bd785b19646d3672784c"

ASG_URL="https://github.com/asgeirtj/system_prompts_leaks.git"
ASG_SHA="50a261ebbea7942fa98254a583d02434fdfd03e7"

L30_URL="https://github.com/mvanhorn/last30days-skill.git"
L30_SHA="7efc0ef764765ed9ceff5ce1204462b35b89d680"

AAS_URL="https://github.com/sickn33/agentic-awesome-skills.git"
AAS_SHA="1ed5976b000fc0df2910d32ed33717794da1bee2"

GD_URL="https://github.com/galaxy-dawn/claude-scholar.git"
GD_SHA="d394fb599ed9e6ea2212a9e6daa864345fe97a26"

CB_URL="https://github.com/conorbronsdon/avoid-ai-writing.git"
CB_SHA="9cd07215982eca9736e14caaa63241c0264856f3"

HM_URL="https://github.com/blader/humanizer.git"
HM_SHA="0ef9fe5bc3572734fd3ae6c448fe00a30cd5dcf0"

ARS_URL="https://github.com/Imbad0202/academic-research-skills.git"
ARS_SHA="f2d109ea815f4b2f68a2eeee1ed9630bfc0cb302"

# name|url|sha|skill path in the repo
TABLE='
watch|$WATCH_URL|$WATCH_SHA|skills/watch
agent-reach|$AGENTREACH_URL|$AGENTREACH_SHA|agent_reach/skill
docling|$DOCLING_URL|$DOCLING_SHA|docling/.agents/skills/docling
docx|$AS_URL|$AS_SHA|skills/docx
pdf|$AS_URL|$AS_SHA|skills/pdf
citation-management|$KS_URL|$KS_SHA|skills/citation-management
litreview|$KS_URL|$KS_SHA|skills/literature-review
exploratory-data-analysis|$KS_URL|$KS_SHA|skills/exploratory-data-analysis
statistical-analysis|$KS_URL|$KS_SHA|skills/statistical-analysis
matplotlib|$KS_URL|$KS_SHA|skills/matplotlib
archify|$AX_URL|$AX_SHA|archify
impeccable|$IM_URL|$IM_SHA|.agents/skills/impeccable
ppt-master|$PX_URL|$PX_SHA|skills/ppt-master
taste-skill|$TS_URL|$TS_SHA|skills/taste-skill
deep-research|$ASG_URL|$ASG_SHA|Anthropic/claude-code/skills/anthropic-skills/deep-research
last30days|$L30_URL|$L30_SHA|skills/last30days
efficient-web-research|$AAS_URL|$AAS_SHA|plugins/agentic-awesome-skills-claude/skills/efficient-web-research
wiki-researcher|$AAS_URL|$AAS_SHA|plugins/agentic-awesome-skills-claude/skills/wiki-researcher
citation-verification|$GD_URL|$GD_SHA|skills/citation-verification
tech-writing-proofread|$AAS_URL|$AAS_SHA|plugins/agentic-awesome-skills-claude/skills/tech-writing-proofread
write-in-my-voice|$AAS_URL|$AAS_SHA|plugins/agentic-awesome-skills-claude/skills/write-in-my-voice
stakeholder-investor-reports|$AAS_URL|$AAS_SHA|plugins/agentic-awesome-skills-claude/skills/stakeholder-investor-reports
survey-generator|$AAS_URL|$AAS_SHA|plugins/agentic-awesome-skills-claude/skills/survey-generator
avoid-ai-writing|$CB_URL|$CB_SHA|skills/avoid-ai-writing
humanizer|$HM_URL|$HM_SHA|.
academic-paper|$ARS_URL|$ARS_SHA|academic-paper
academic-paper-reviewer|$ARS_URL|$ARS_SHA|academic-paper-reviewer
academic-pipeline|$ARS_URL|$ARS_SHA|academic-pipeline
academic-deep-research|$ARS_URL|$ARS_SHA|deep-research
sr-screener|$ARS_URL|$ARS_SHA|sr-screener
'

OUT="" LICENSES_OUT="" PICK=()
while [ $# -gt 0 ]; do
  case "$1" in
    --list)   awk -F'|' '$1{gsub(/ /,"",$1);print $1}' <<<"$TABLE"; exit 0 ;;
    --all)    mapfile -t PICK < <(awk -F'|' '$1{gsub(/ /,"",$1);print $1}' <<<"$TABLE") ;;
    --skill)  PICK+=("$2"); shift ;;
    --out)    OUT="$2"; shift ;;
    --licenses-out) LICENSES_OUT="$2"; shift ;;
    *) echo "usage: $0 [--list|--all|--skill NAME] [--out DIR] [--licenses-out DIR]" >&2; exit 2 ;;
  esac
  shift
done
[ ${#PICK[@]} -gt 0 ] || { echo "need --all or --skill NAME (see --list)" >&2; exit 2; }
OUT="${OUT:-$(mktemp -d "${TMPDIR:-/tmp}/skillsmith.XXXXXX")}"
mkdir -p "$OUT"
WORK=$(mktemp -d) ; trap 'rm -rf "$WORK"' EXIT

# clone+fetch the exact SHA, sparse-checkout only what is needed, copy into $OUT/<name>
grab() { # url sha path dest
  local url=$1 sha=$2 path=$3 dest=$4
  local key="${url##*/}-$sha" dir="$WORK/${url##*/}-$sha"
  if [ ! -d "$dir" ]; then
    git clone -q --filter=blob:none --no-checkout "$url" "$dir"
    git -C "$dir" sparse-checkout init --no-cone
    git -C "$dir" fetch -q --depth 1 origin "$sha"
  fi
  if [ "$path" = "." ] || [ -z "$path" ]; then
    git -C "$dir" sparse-checkout set "/*"
    git -C "$dir" checkout -q FETCH_HEAD
    rm -rf "$OUT/$dest"
    mkdir -p "$OUT/$dest"
    (shopt -s dotglob; cp -R "$dir"/* "$OUT/$dest"/)
    rm -rf "$OUT/$dest/.git"
  else
    git -C "$dir" sparse-checkout set "$path"
    git -C "$dir" checkout -q FETCH_HEAD
    rm -rf "$OUT/$dest"
    cp -R "$dir/$path" "$OUT/$dest"
  fi
  if [ -n "$LICENSES_OUT" ]; then
    local license_dir="$LICENSES_OUT/$dest"
    mkdir -p "$license_dir"
    for license_file in LICENSE LICENSE.md LICENSE.txt COPYING COPYING.md COPYING.txt; do
      rm -f -- "$license_dir/$license_file"
      if git -C "$dir" cat-file -e "FETCH_HEAD:$license_file" 2>/dev/null; then
        git -C "$dir" show "FETCH_HEAD:$license_file" > "$license_dir/$license_file"
      fi
    done
  fi
}

for name in "${PICK[@]}"; do
  line=$(grep -E "^$name\|" <<<"$TABLE") || { echo "unknown skill '$name' (see --list)" >&2; exit 1; }
  IFS='|' read -r _ url sha path <<<"$line"
  if [[ "$url" =~ ^\$([A-Z0-9]+)_URL$ ]]; then
    variable="${BASH_REMATCH[1]}_URL"
    url="${!variable:?missing source variable $variable}"
  fi
  if [[ "$sha" =~ ^\$([A-Z0-9]+)_SHA$ ]]; then
    variable="${BASH_REMATCH[1]}_SHA"
    sha="${!variable-}"
  fi
  grab "$url" "$sha" "$path" "$name"
  echo "✓ $name → $OUT/$name"
done
echo "SESSION DIR: $OUT (${#PICK[@]} skills) — session-only, nothing is installed"
