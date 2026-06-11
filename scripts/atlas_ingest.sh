#!/usr/bin/env bash
# mudd.one — ingest the operator's folder-labeled ATLAS into a CreateML dataset.
#
# Doctrine: each LEAF case folder that contains images/clips is ONE class; the
# folder name (sanitized) is the label. This is the operator's "po mojemu" atlas
# shape — diagnosis-as-folder — scaled to 100+ classes. Empty folders (GDrive
# placeholders / organizational shells) are skipped, not faked.
#
# Output: <out>/train/<label>/*.png + <out>/test/<label>/*.png  (gitignored)
#         <out>/manifest.tsv  — honest per-class inventory + thin-class flags.
#
# Usage: scripts/atlas_ingest.sh <atlas_root> [out_dir] [min_per_class] [fps]
# Created by M&K (c)2026 VetCoders
set -euo pipefail

ATLAS="${1:?usage: atlas_ingest.sh <atlas_root> [out_dir] [min_per_class] [fps]}"
OUT="${2:-$(cd "$(dirname "$0")/.." && pwd)/models/_dataset_atlas}"
MIN="${3:-12}"        # classes with fewer frames than this are flagged THIN
FPS="${4:-2}"         # avi extraction rate (low — atlas clips are slow sweeps)

command -v ffmpeg >/dev/null || { echo "ffmpeg required" >&2; exit 1; }

rm -rf "$OUT"; mkdir -p "$OUT"
MANIFEST="$OUT/manifest.tsv"
printf 'label\tjpg\tavi\tframes_total\ttrain\ttest\tstatus\tsource_dir\n' > "$MANIFEST"

# Sanitize a folder name into a filesystem/label-safe slug (keep it readable).
slug() { echo "$1" | tr ' /' '__' | tr -cd '[:alnum:]_ąćęłńóśźżĄĆĘŁŃÓŚŹŻ-' ; }

# Walk leaf directories (no child dirs) that hold ≥1 image or clip.
classes=0; total_frames=0; thin=0
while IFS= read -r -d '' dir; do
  # leaf only: skip dirs that contain subdirectories
  if find "$dir" -mindepth 1 -maxdepth 1 -type d | read -r _; then continue; fi
  shopt -s nullglob nocaseglob
  jpgs=("$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png)
  avis=("$dir"/*.avi "$dir"/*.mov "$dir"/*.mp4)
  shopt -u nullglob nocaseglob
  njpg=${#jpgs[@]}; navi=${#avis[@]}
  (( njpg + navi == 0 )) && continue          # empty shell / placeholder → skip

  label="$(slug "$(basename "$dir")")"
  cdir="$OUT/train/$label"; mkdir -p "$cdir"
  # Resume numbering from existing frames so same-slug folders MERGE (e.g.
  # "Splenomegalia" + "Splenomegalia_2") into one class instead of clobbering.
  i=$(find "$cdir" -type f -name '*.png' | wc -l | tr -d ' ')
  for f in "${jpgs[@]}"; do cp "$f" "$cdir/$(printf 'img_%04d.png' "$i")" 2>/dev/null && i=$((i+1)); done
  for v in "${avis[@]}"; do
    ffmpeg -nostdin -y -v error -i "$v" -vf "fps=$FPS" "$cdir/vid$(printf '%02d' "$i")_%03d.png" 2>/dev/null || true
    i=$(find "$cdir" -type f -name '*.png' | wc -l | tr -d ' ')
  done
  frames=$(find "$cdir" -type f -name '*.png' | wc -l | tr -d ' ')
  if (( frames == 0 )); then rmdir "$cdir" 2>/dev/null || true; continue; fi

  # temporal/holdout: move ~1/7 (min 1) to test
  tdir="$OUT/test/$label"; mkdir -p "$tdir"
  k=$(( frames > 6 ? frames / 7 : 1 ))
  find "$cdir" -type f -name '*.png' | sort | tail -"$k" | while read -r f; do mv "$f" "$tdir/"; done
  tr_n=$(find "$cdir" -type f -name '*.png' | wc -l | tr -d ' ')
  te_n=$(find "$tdir" -type f -name '*.png' | wc -l | tr -d ' ')

  status="ok"; if (( frames < MIN )); then status="THIN"; thin=$((thin+1)); fi
  printf '%s\t%d\t%d\t%d\t%d\t%d\t%s\t%s\n' \
    "$label" "$njpg" "$navi" "$frames" "$tr_n" "$te_n" "$status" "$dir" >> "$MANIFEST"
  classes=$((classes+1)); total_frames=$((total_frames+frames))
done < <(find "$ATLAS" -type d -print0)

echo "ingested $classes classes, $total_frames frames ($thin flagged THIN < $MIN) → $OUT"
echo "manifest: $MANIFEST"
(( classes < 2 )) && { echo "WARNING: <2 usable classes — is the GDrive sync complete?" >&2; }
exit 0
