#!/usr/bin/env bash
# mudd.one — curate an ingested ATLAS dataset down to trainable classes.
# Drops non-diagnostic bag folders and classes below a hard frame minimum.
# (atlas_ingest.sh only FLAGS thin classes; this one EXCLUDES them.)
#
# Usage: scripts/atlas_curate.sh <ingested_dir> <out_dir> [min_total] [exclude...]
#   default min_total=12; default excludes: foto HM70A pliki kolory Jadra
# Created by M&K (c)2026 VetCoders
set -euo pipefail

SRC="${1:?usage: atlas_curate.sh <ingested_dir> <out_dir> [min_total] [exclude...]}"
OUT="${2:?out_dir required}"
MIN="${3:-12}"; shift 3 2>/dev/null || shift $#
EXCLUDE=" ${*:-foto HM70A pliki kolory Jadra} "

rm -rf "$OUT"; mkdir -p "$OUT/train" "$OUT/test"
kept=0; frames=0
for d in "$SRC"/train/*/; do
  cls=$(basename "$d")
  case "$EXCLUDE" in *" $cls "*) continue;; esac
  tr=$(find "$SRC/train/$cls" -name '*.png' 2>/dev/null | wc -l | tr -d ' ')
  te=$(find "$SRC/test/$cls" -name '*.png' 2>/dev/null | wc -l | tr -d ' ')
  (( tr + te < MIN )) && continue
  cp -R "$SRC/train/$cls" "$OUT/train/$cls"
  [ -d "$SRC/test/$cls" ] && cp -R "$SRC/test/$cls" "$OUT/test/$cls"
  kept=$((kept+1)); frames=$((frames+tr+te))
done
echo "curated $kept classes, $frames frames (min_total=$MIN) → $OUT"
