#!/usr/bin/env bash
# mudd.one — build the v0 path-validator dataset from local ATLAS clips.
# Sources live in iCloud (local-only); see docs/classifier-v0.md for honest scope.
# Output: models/_dataset_v0/{train,test}/{ovary,cardiac} (gitignored).
set -euo pipefail
A="${1:-/Users/maciejgad/iCloud Drive (Archive)/Desktop/Maciejowe 2/ATLAS}"
D="$(cd "$(dirname "$0")/.." && pwd)/models/_dataset_v0"
rm -rf "$D"; mkdir -p "$D"/train/{ovary,cardiac} "$D"/test/{ovary,cardiac}
extract(){ ffmpeg -y -v error -i "$1" -vf fps=5 "$D/train/$3/$2_%03d.png"; }
extract "$A/Masked Left ovary in dog.mp4" ov1 ovary
extract "$A/sam2_masked_video_1731974018507.mov" ov2 ovary
extract "$A/sam2_masked_video_1732139102314.mov" ca1 cardiac
cp "$A/frame_000000_0.000s.png" "$D/train/cardiac/ca0_000.png"
# temporal holdout: last ~1/7 of each clip's frames → test
for cls in ovary cardiac; do
  for pref in $(ls "$D/train/$cls" | sed 's/_[0-9]*\.png//' | sort -u); do
    files=$(ls "$D/train/$cls/${pref}_"*.png | sort); n=$(echo "$files" | wc -l | tr -d ' ')
    k=$(( n>6 ? n/7 : 1 )); echo "$files" | tail -"$k" | while read -r f; do mv "$f" "$D/test/$cls/"; done
  done
done
echo "dataset built at $D"
