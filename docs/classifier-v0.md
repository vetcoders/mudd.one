# mudd-classifier-v0 — dataset notes (honest scope)

**Status: path-validator, NOT clinical.** This v0 model exists to prove the
train → CoreML → in-app inference path end to end with a real `.mlmodel`. It is
not a diagnostic tool and must never be presented as one.

## Source

Frames extracted (ffmpeg, 5 fps) from VetCoders ATLAS SAM2-masked ultrasound
clips:

| Class | Source clips | Machine / region |
|---|---|---|
| `ovary` | `Masked Left ovary in dog.mp4`, `sam2_masked_video_1731974018507.mov` | United Imaging (abdomen), VETISS C4-9 |
| `cardiac` | `sam2_masked_video_1732139102314.mov`, `frame_000000_0.000s.png` | Saote VETCARDIA (dog "STEFAN") |

Excluded: `sam2_masked_video_1731972219216.mov` (testicular — different organ,
kept out of a 2-class split); `35ABEA69-…​.mov` (corrupt — `moov atom not
found`, truncated iCloud download); `Final Capstone Rubric.png` (a generic
assignment rubric, not ultrasound).

## Known limitations (do not hide these)

- **Keys on acquisition context, not anatomy.** Each class comes from one or two
  clips on distinct machines with distinct on-screen UI and SAM2 overlay colors.
  The model almost certainly separates machine watermark + overlay hue, not the
  organ. This is the classic ultrasound-ML leakage trap.
- **Tiny, clip-correlated.** Train frames are near-duplicate neighbours from a
  handful of clips. The temporal-tail test split (~15%) still comes from the
  same clips, so reported accuracy overstates real generalization.
- **Two classes only**, by data availability — not a clinical taxonomy.

## Regenerate

```bash
# extraction: scripts/build_dataset_v0.sh (paths are local iCloud, not in repo)
# train:      swift scripts/train_classifier.swift models/_dataset_v0 models/mudd-classifier-v0.mlmodel
```

Everything under `models/` is gitignored — dataset frames and the `.mlmodel` are
local-only.
