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
AS_SHA="dbd4588f9e1033efb41dad4bef2f7947c8993d44"

KS_URL="https://github.com/K-Dense-AI/scientific-agent-skills.git"
KS_SHA="593377bb048752abb0152deab9fbb1083a6087df"

AX_URL="https://github.com/tt-a1i/archify.git"
AX_SHA="25cf37080fc8b1dbe758a4efc3935b55f3327083"

IM_URL="https://github.com/pbakaus/impeccable.git"
IM_SHA="936867543ac2576920d663cc9803597f6044f3ac"

PX_URL="https://github.com/hugohe3/ppt-master.git"
PX_SHA="687a00affb5d65075f9904927d6212a6ffe1c0b7"

TS_URL="https://github.com/Leonxlnx/taste-skill.git"
TS_SHA="6010f91a9935f1c167dfc500fb1a475681892e6b"

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
