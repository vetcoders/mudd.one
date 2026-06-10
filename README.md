# mudd.one — Multimodal Ultrasound Data Distiller

![License](https://img.shields.io/github/license/Szowesgad/mudd.one)
![Rust](https://img.shields.io/badge/Rust-edition%202024-orange)
![Swift](https://img.shields.io/badge/Swift-6.0%20%2F%20AppKit-blue)
![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey)

> Native macOS app for veterinary ultrasound processing: load DICOM/video/images,
> detect and crop the ultrasound region, apply filters, run SAM-style segmentation,
> classify frames, and export annotated ML datasets (COCO/YOLO).

## Architecture

Pure **Rust core + Swift/AppKit UI**, bridged with UniFFI. No server, no runtime
dependencies beyond FFmpeg — everything runs locally.

```
┌─────────────────────────────────────────────────┐
│ mudd.app (Swift 6 / AppKit, macOS 14+)          │
│   Canvas · Sidebar · Inspector                  │
│   ClassifierService (CoreML/Vision)  ←─ .mlmodel│
└──────────────────┬──────────────────────────────┘
                   │ UniFFI (ffi/ → Bridge/mudd_ffi.swift)
┌──────────────────┴──────────────────────────────┐
│ mudd-core (Rust, edition 2024)                  │
│   dicom/    DICOM + image + video loading       │
│   video/    FFmpeg decode → RGB frames          │
│   imaging/  ROI (Otsu), crop, filters, resize   │
│   inference/ SegmenterBackend → ORT (CoreML EP) │
│   export/   COCO JSON · YOLO txt + images       │
└─────────────────────────────────────────────────┘
```

### Processing pipeline

```
RawFrame → CroppedFrame → ProcessedFrame → AnnotatedFrame → ExportItem
```

### ML runtimes — by design

| Stage | Runtime | Where |
|---|---|---|
| Segmentation (SAM-style, point prompts) | ONNX Runtime with CoreML EP (ANE/GPU) | Rust core, behind the `SegmenterBackend` trait |
| Classification | CoreML / Vision (CreateML model drops in) | Swift app (`ClassifierService`) |

The `SegmenterBackend` trait (`core/src/inference/backend.rs`) is the seam for
future runtimes. Classification results flow back into the Rust core through
FFI and land in COCO export (`classification` / `classification_confidence`
per image). Python lives only in offline training tooling — never in the app.

## Build

Requires: Rust (edition 2024), FFmpeg (`brew install ffmpeg`), xcodegen
(`brew install xcodegen`), Xcode 16+.

```bash
make build          # cargo build --workspace (debug)
make check          # fmt-check + clippy -D warnings (quality gate)
make test           # cargo test --workspace

make bindings       # build mudd-ffi (release) + generate Swift bridge
make xcode          # xcodegen generate → app/mudd.xcodeproj
make app            # bindings + xcode + xcodebuild → build/mudd.app
make dmg            # release DMG (ad-hoc signed)
make hooks-install  # pre-commit (fast) + pre-push (full CI gate)
```

## Models

Model binaries are **not** in the repo (`models/` is local-only, gitignored).

- **Segmentation** — any SAM-style ONNX model. Resolution order:
  1. `MUDD_MODEL_PATH` env var
  2. HF cache (`MUDD_HF_CACHE` / `HUGGINGFACE_HUB_CACHE` / `HF_HUB_CACHE` /
     `HF_HOME` / `~/.cache/huggingface/hub`)
  3. In-app: *Load Model...* file picker
- **Classification** — CoreML model (`.mlmodel` / `.mlpackage` / `.mlmodelc`),
  trained in CreateML (project scaffold: `models/mudd-classifier.mlproj`).
  Loaded in-app via *Load Classifier...*; compiled on the fly when needed.

## Usage

1. `make app && open build/mudd.app`
2. Open a DICOM / video / image file
3. **Auto ROI** → **Crop** (or draw ROI manually on canvas)
4. Apply filters in the Inspector (histogram EQ, contrast, Canny, ...)
5. Load a segmentation model → **Prompt Mode** → click point prompts
6. Load a classifier → **Classify Frame**
7. **Export...** → COCO or YOLO dataset

## Workspace layout

| Crate / dir | Purpose |
|---|---|
| `core/` (`mudd-core`) | all processing logic, zero UI |
| `ffi/` (`mudd-ffi`) | UniFFI bridge — flat `Ffi*` records, `#[uniffi::export]` fns |
| `uniffi-bindgen/` | CLI to generate the Swift bridge |
| `app/` | xcodegen spec + Swift/AppKit sources |
| `models/` | local model assets (gitignored) |

## Contributing

- `make check && make test` must pass before any PR (pre-push hook enforces it)
- Keep the FFI surface flat and explicit; regenerate bindings with `make bindings`
- Do **not** commit patient data, datasets, or model binaries

## License

MIT — see [LICENSE](LICENSE).

---

**mudd.one** is the first phase of the **mudd suite** — a toolkit for processing,
analyzing, and preparing veterinary ultrasound imaging data for ML.

Created by M&K (c)2026 VetCoders · [hiai.vision](https://hiai.vision) (the AMLT.ai brand)
