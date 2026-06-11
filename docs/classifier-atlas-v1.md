# mudd-classifier-atlas-v1 — 21-class veterinary ultrasound classifier

**Status: research model, NOT clinical.** Real diagnostic signal (71% top-1 over
21 classes vs ~4.8% random), but trained on small, clip-correlated per-class
sets. Do not present as a diagnostic tool.

## Source

Operator's curated atlas (`po mojemu` — diagnosis-as-folder), the materialized
local copy at `~/Library/Mobile Documents/com~apple~CloudDocs/weterynaryjne/ATLAS 7`
(1392 files materialized). Folder name = class label.

```bash
# 1. ingest the whole tree (folder = class, avi frames extracted at 2 fps)
scripts/atlas_ingest.sh "<ATLAS 7 root>" models/_dataset_atlas 12 2
# 2. curate to trainable classes (drop bags + classes < 12 frames)
scripts/atlas_curate.sh models/_dataset_atlas models/_dataset_atlas_curated 12
# 3. train + 4. verify
swift scripts/train_classifier.swift  models/_dataset_atlas_curated models/mudd-classifier-atlas-v1.mlmodel
swift scripts/verify_classifier.swift models/mudd-classifier-atlas-v1.mlmodel models/_dataset_atlas_curated/test
```

## Result

- **21 classes, 662 frames** (97 held out). Excluded non-diagnostic bags
  (`foto` 1179, `HM70A` 263, `pliki`, `kolory`, `Jadra`) and all classes < 12
  frames.
- **Training accuracy 81.6%; held-out 71.1%** (CreateML eval).
- **Vision/CoreML path: 70/97 = 72.2%** through the exact in-app path
  (`verify_classifier.swift` mirrors `ClassifierService`).

Classes include: Nefrokalcynoza, Nerka (TZW objaw rąbka), Zapalenie trzustki
(lewy/prawy płat + TRZ_ZAP), Prostnica, Splenomegalia (×2 cases),
Pęcherz moczowy psa, Nadnercze (lewe/prawe), cysta wątroba, Chłoniak,
Jajnik lewy proestrus, wątroba (×2 views), GUZY nerek, Myelolipoma.

## Known limitations (do not hide)

- **Small + clip-correlated.** Most classes are frames from one or two clips;
  held-out frames share clips with train, so 71% overstates real
  generalization. Expect lower on truly novel patients/machines.
- **Acquisition leakage.** Different cases come from different machines (Saote,
  SonoScape, United Imaging, HM70A...); the model can key on machine UI as much
  as anatomy. A larger, multi-machine-per-class set is the fix.
- **Near-duplicate-meaning classes kept** by operator's taxonomy choice
  (`Splenomegalia` + `Splenomegalia_2`; three pancreatitis variants). Intentional
  — not merged.
- **Vision toward 100+ classes**: the folder taxonomy already names ~60+ findings,
  but ~38 of them have < 12 frames (often 1–2). Reaching a real 100-class model
  needs more curated frames per finding, not more folders.

Model and dataset are local-only (`models/` gitignored).
