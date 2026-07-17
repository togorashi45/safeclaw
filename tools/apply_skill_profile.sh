#!/usr/bin/env bash
# apply_skill_profile.sh - prune a skills tree to a profile and drop the index.
#
# Config-driven replacement for the hardcoded delete list in prune-skills.sh.
# Runs skills_manifest.py to compute the keeplist for a profile, deletes every
# skill NOT on it, and writes SKILL_INDEX.md (the always-loaded directory) into
# the skills tree so the agent can find what is left.
#
# Usage (image build or on-box):
#   apply_skill_profile.sh <profile> [skills_dir] [config_path]
#
# Example:
#   apply_skill_profile.sh reader /opt/hermes/skills
#
# Safe to run repeatedly. Does nothing if the skills dir is missing.

set -euo pipefail

PROFILE="${1:?usage: apply_skill_profile.sh <profile> [skills_dir] [config]}"
SKILLS_DIR="${2:-/opt/hermes/skills}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$HERE")"
CONFIG="${3:-$REPO_ROOT/config/skill-profiles.yaml}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

if [ ! -d "$SKILLS_DIR" ]; then
    echo "apply_skill_profile: $SKILLS_DIR missing - nothing to do." >&2
    exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 1. Build the manifest + keeplist for this profile.
INSTALLED_ARGS=()
if [ -n "${INSTALLED_JSON:-}" ] && [ -f "${INSTALLED_JSON:-}" ]; then
    INSTALLED_ARGS=(--installed "$INSTALLED_JSON")
fi
"$PYTHON_BIN" "$HERE/skills_manifest.py" \
    --profile "$PROFILE" \
    --skills-dir "$SKILLS_DIR" \
    --config "$CONFIG" \
    --out "$WORK" \
    "${INSTALLED_ARGS[@]}"

# 2. Delete every skill directory whose SKILL.md is not on the keeplist.
#    keeplist.txt holds SKILL.md paths relative to SKILLS_DIR.
before="$(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.git/*' | wc -l | tr -d ' ')"

# Normalize: drop any trailing slash so prefix-stripping is exact.
SKILLS_DIR="${SKILLS_DIR%/}"

while IFS= read -r rel; do
    [ -n "$rel" ] && printf '%s\n' "$(dirname "$rel")"
done < "$WORK/keeplist.txt" | sort -u > "$WORK/keepdirs.txt"

# PRUNE=0 (on-box toggling): keep pack files on disk, only the index changes.
# Hermes loads skills through SKILL_INDEX.md, so index-exclusion turns the
# behavior off; files staying put makes reinstall instant and reversible.
# PRUNE=1 (default, image builds): delete unkept packs as before.
if [ "${PRUNE:-1}" = "1" ]; then
find "$SKILLS_DIR" -name SKILL.md -not -path '*/.git/*' -print0 |
while IFS= read -r -d '' skillmd; do
    skilldir="$(dirname "$skillmd")"
    # Portable relative path: strip the "$SKILLS_DIR/" prefix (no GNU realpath).
    reldir="${skilldir#"$SKILLS_DIR"/}"
    if ! grep -qxF "$reldir" "$WORK/keepdirs.txt"; then
        rm -rf "$skilldir"
    fi
done
fi

# 3. Install the always-loaded directory into the skills tree.
cp "$WORK/SKILL_INDEX.md" "$SKILLS_DIR/SKILL_INDEX.md"
cp "$WORK/skills.index.json" "$SKILLS_DIR/skills.index.json"

after="$(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.git/*' | wc -l | tr -d ' ')"
echo "apply_skill_profile: profile=$PROFILE  SKILL.md ${before} -> ${after}"
echo "apply_skill_profile: wrote SKILL_INDEX.md + skills.index.json into $SKILLS_DIR"
