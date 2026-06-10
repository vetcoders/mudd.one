<!-- loctree-doctrine: v1 -->
## **LOCTREE + AICX + VIBECRAFTED — ZŁOTE RUNO**

> **Loctree first, brak doubt. Grep = potwierdzony hak.**

Strukturalna percepcja PRZED każdym sięgnięciem po `grep`/`awk`/`sed`/
`find`/`Read+offset`. Plus aicx jako historia intencji, vibecrafted jako
dyscyplina dowodu. Trio jest kanonem.

**Reguła operacyjna:**

- Pierwszy ruch przy każdym strukturalnym pytaniu (kto importuje X,
  gdzie żyje symbol Y, co pęknie po edycji Z, blast radius, struktura
  katalogu A) → `loctree-mcp` tool (`context` / `slice` / `impact` /
  `find` / `focus` / `follow`).
- Każde sięgnięcie po `grep`/`awk`/`sed`/`find` na rzeczy która
  **powinna być** loctree-side = **hak**. Zapisz wpis do backlogu
  (`cuts/loctree-haki.md` per-repo albo operator-managed global).
- "Doubt" w wyborze tool = anti-pattern. Albo loctree to znajdzie,
  albo nie umie i wtedy hak + fallback.
- Sfabrykowane doctriny ("CodeScribe grep-first", "szybciej grepem",
  "loctree pewnie nie ma") = halucynacja klasy `cutoffflu`. Zakaz.
- `loctree-mcp` niedostępne? Użyj `loct` cli, ale napisz 'haka'
   sygnalizującego ten problem.

**Lokalizacja backloga "Loctree fail":**

- Pisz **na końcu** pliku ~/.vibecrafted/loctree/loctree-fail.md
- Nie twórz na nowo, nie nadpisuj - to plik przeznaczony do appendowania. 
- Nie musisz czytać istniejących wpisów. Jeśli Twój hak jest zgłoszony
  kolejny raz to sygnał o jego trafności, a nie powielanie.

**Dlaczego:** Vista (duet weterynarzy × AI agents) to istniejący proof.
Loctree perfection skaluje ten model do każdego foundera nieprogramisty
bez milionów. Continuous backlog closure = warunek wiarygodności tej tezy.

<!-- /loctree-doctrine -->

# Repository Guidelines

## Project Structure & Module Organization

This repository is a Rust workspace (see `Cargo.toml`) with two crates:

- `core/` (`mudd-core`): DICOM/image/video loading, ROI detection + cropping, image filters/normalization, ONNX inference, and dataset export (COCO/YOLO).
- `ffi/` (`mudd-ffi`): UniFFI bridge exposing Swift-friendly types (`Ffi*`) and exported functions in `ffi/src/lib.rs`.

Generated or local-only directories: `target/` (build output) and `.loctree/` (tool cache). `models/` is local-only and fully gitignored (model binaries and CreateML projects live there). `README.md` describes the actual stack: Rust core + UniFFI + Swift/AppKit app, with the Swift-side CoreML classifier (`app/mudd/Services/ClassifierService.swift`).

## Build, Test, and Development Commands

Prefer the `Makefile` targets:

- `make build` / `make release`: build the workspace.
- `make fmt` / `make fmt-check`: format or verify formatting (`cargo fmt`).
- `make check`: format check + clippy with warnings as errors.
- `make test` / `make test-quick`: run tests (workspace / lib-only).
- `make fix`: apply clippy auto-fixes, then format.
- `make hooks-install`: install `.githooks/pre-commit` (fast) and `.githooks/pre-push` (CI gate).

## Coding Style & Naming Conventions

- Formatting is enforced by `cargo fmt`; linting by `cargo clippy -- -D warnings` (run `make check`).
- Follow standard Rust naming: `snake_case` modules/functions, `CamelCase` types, `SCREAMING_SNAKE_CASE` consts.
- Keep the FFI surface stable: use flat `Ffi*` records/enums and explicit `#[uniffi::export]` functions.

## Testing Guidelines

- Run `make test` before opening a PR.
- Add unit tests alongside code with `#[cfg(test)] mod tests { ... }` (e.g., under `core/src/**`), or integration tests under `core/tests/`.
- Avoid network/model downloads in default tests; keep inference tests deterministic.

## Commit & Pull Request Guidelines

- Commit messages in this repo are short and imperative (examples from history: `Add ...`, `Update ...`).
- PRs should include: summary + rationale, how you validated (`make check && make test`), and any breaking changes (especially for `ffi/` exports). If changes depend on external tooling (FFmpeg / ONNX Runtime), mention setup notes.

## Security & Configuration Tips

- Do not commit patient data or proprietary datasets.
- Model resolution supports `MUDD_MODEL_PATH` and Hugging Face cache locations (`MUDD_HF_CACHE`, `HF_HOME`, etc.); keep large model files out of git.
