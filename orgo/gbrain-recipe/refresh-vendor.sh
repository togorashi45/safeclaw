#!/usr/bin/env bash
# Refresh the vendored gbrain provisioning script from our fork.
#
#   bash orgo/gbrain-recipe/refresh-vendor.sh            # diff only, changes nothing
#   bash orgo/gbrain-recipe/refresh-vendor.sh --apply    # take the new copy
#
# Never hand edit vm-hermes-setup.sh. Our overrides live in orgo/install-box.sh
# and run after it. See VENDOR.md.
set -euo pipefail

FORK="${GBRAIN_FORK_URL:-https://github.com/togorashi45/gbrain.git}"
REF="${GBRAIN_FORK_REF:-master}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HERE/vm-hermes-setup.sh"
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[refresh] cloning $FORK ($REF)"
git clone --depth 1 -b "$REF" "$FORK" "$TMP/gbrain" >/dev/null 2>&1

NEW="$TMP/gbrain/scripts/vm-hermes-setup.sh"
[ -f "$NEW" ] || { echo "[refresh] ERROR: scripts/vm-hermes-setup.sh missing in the fork" >&2; exit 1; }

COMMIT="$(git -C "$TMP/gbrain" rev-parse HEAD)"
VERSION="$(cat "$TMP/gbrain/VERSION" 2>/dev/null || echo unknown)"
SUM="$(shasum -a 256 "$NEW" | awk '{print $1}')"

if diff -u "$TARGET" "$NEW"; then
  echo "[refresh] no change. vendored copy already matches $COMMIT ($VERSION)."
  exit 0
fi

if [ "$APPLY" -ne 1 ]; then
  echo
  echo "[refresh] diff shown above. Re-run with --apply to take it."
  exit 0
fi

cp "$NEW" "$TARGET"
python3 - "$HERE/VENDOR.md" "$COMMIT" "$VERSION" "$SUM" "$(date -u +%Y-%m-%d)" <<'PY'
import re, sys
path, commit, version, checksum, today = sys.argv[1:6]
s = open(path).read()
s = re.sub(r"(\| Vendored commit \| )`[^`]*`", r"\1`%s`" % commit, s)
s = re.sub(r"(\| Vendored gbrain version \| )`[^`]*`", r"\1`%s`" % version, s)
s = re.sub(r"(\| SHA256 of the vendored file \| )`[^`]*`", r"\1`%s`" % checksum, s)
s = re.sub(r"(\| Vendored on \| )[0-9-]+", r"\g<1>%s" % today, s)
open(path, "w").write(s)
print("[refresh] VENDOR.md provenance updated")
PY
echo "[refresh] vendored $COMMIT ($VERSION). Commit the change."
