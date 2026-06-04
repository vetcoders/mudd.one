# mudd.one - Veterinary Ultrasound Processing Pipeline
# Rust workspace: mudd-core + mudd-ffi
# Created by M&K (c)2026 VetCoders

.PHONY: all build release check fmt fmt-check lint test test-quick ci fix clean help \
        hooks-install hooks-uninstall pre-commit pre-push \
        version bump bump-patch bump-minor bump-major \
        bindings app xcode

SHELL := /bin/bash
VERSION_FILE := Cargo.toml

# ============================================================================
# Build
# ============================================================================

all: check

build:
	@echo "Building (debug)..."
	@cargo build --workspace

release:
	@echo "Building (release)..."
	@cargo build --workspace --release

# ============================================================================
# Quality
# ============================================================================

fmt:
	@cargo fmt --all

fmt-check:
	@cargo fmt --all -- --check

lint:
	@echo "=== Format Check ==="
	@cargo fmt --all -- --check
	@echo "=== Clippy ==="
	@cargo clippy --workspace --all-targets -- -D warnings

check:
	@echo "=== Format Check ==="
	@cargo fmt --all -- --check
	@echo "=== Clippy (workspace, all targets) ==="
	@cargo clippy --workspace --all-targets -- -D warnings
	@echo "Quality gate passed"

test:
	@echo "=== Tests (workspace) ==="
	@cargo test --workspace

test-quick:
	@echo "=== Tests (quick, lib only) ==="
	@cargo test --workspace --lib

ci: fmt-check lint test
	@echo "CI passed"

fix:
	@echo "=== Auto-fix ==="
	@cargo clippy --workspace --all-targets --fix --allow-dirty --allow-staged
	@cargo fmt --all
	@echo "Fixed"

# ============================================================================
# Version Bump
# ============================================================================

version:
	@grep '^version' $(VERSION_FILE) | head -1 | sed 's/.*"\(.*\)"/v\1/'

bump:
	@if [ -z "$(TYPE)" ]; then \
		echo "Usage: make bump TYPE=patch|minor|major"; \
		echo "Current: $$(grep '^version' $(VERSION_FILE) | head -1 | sed 's/.*\"\(.*\)\"/v\1/')"; \
		exit 1; \
	fi
	@current=$$(grep '^version' $(VERSION_FILE) | head -1 | sed 's/.*"\(.*\)"/\1/'); \
	IFS='.' read -r major minor patch <<< "$$current"; \
	case "$(TYPE)" in \
		patch) patch=$$((patch + 1)) ;; \
		minor) minor=$$((minor + 1)); patch=0 ;; \
		major) major=$$((major + 1)); minor=0; patch=0 ;; \
		*) echo "Invalid TYPE: $(TYPE)"; exit 1 ;; \
	esac; \
	new="$$major.$$minor.$$patch"; \
	sed -i '' "s/^version = \"$$current\"/version = \"$$new\"/" $(VERSION_FILE); \
	echo "Bumped: v$$current -> v$$new"

bump-patch:
	@$(MAKE) bump TYPE=patch

bump-minor:
	@$(MAKE) bump TYPE=minor

bump-major:
	@$(MAKE) bump TYPE=major

# ============================================================================
# UniFFI Bindings
# ============================================================================

bindings:
	@echo "Building mudd-ffi (release)..."
	@cargo build -p mudd-ffi --release
	@echo "Generating Swift bindings..."
	@cargo run -p uniffi-bindgen -- generate --library target/release/libmudd_ffi.dylib --language swift --out-dir app/mudd/Bridge/
	@echo "Bindings ready: app/mudd/Bridge/"

# ============================================================================
# macOS App
# ============================================================================

xcode:
	@cd app && xcodegen generate
	@echo "Xcode project generated: app/mudd.xcodeproj"

app: bindings xcode
	@echo "Building mudd.app..."
	@rm -rf build/DerivedData build/mudd.app
	@set -o pipefail && xcodebuild -project app/mudd.xcodeproj -scheme mudd -configuration Debug -derivedDataPath build/DerivedData build 2>&1 | tail -20
	@BUILT_APP=$$(find build/DerivedData -name mudd.app -type d | head -1); \
		if [ -z "$$BUILT_APP" ]; then \
			echo "ERROR: mudd.app not found in build/DerivedData"; \
			exit 1; \
		fi; \
		cp -R "$$BUILT_APP" build/mudd.app
	@echo "App built: build/mudd.app"

dmg:
	@./scripts/build-dmg.sh

dmg-signed:
	@SIGNING_IDENTITY="Developer ID Application: Maciej Gad (MW223P3NPX)" ./scripts/build-dmg.sh

# ============================================================================
# Git Hooks
# ============================================================================

hooks-install:
	@echo "Installing git hooks..."
	@cp .githooks/pre-commit .git/hooks/pre-commit
	@cp .githooks/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-commit .git/hooks/pre-push
	@echo "Hooks installed: pre-commit + pre-push"

hooks-uninstall:
	@echo "Removing git hooks..."
	@rm -f .git/hooks/pre-commit .git/hooks/pre-push
	@echo "Hooks removed"

pre-commit: fmt-check
	@cargo check --workspace
	@echo "Pre-commit passed"

pre-push: ci

# ============================================================================
# Cleanup
# ============================================================================

clean:
	@cargo clean
	@rm -rf .loctree
	@echo "Cleaned"

# ============================================================================
# Help
# ============================================================================

# Help colors
HELP_C_CYAN   := \033[36m
HELP_C_GREEN  := \033[32m
HELP_C_YELLOW := \033[33m
HELP_C_RESET  := \033[0m

help:
	@printf '\n$(HELP_C_CYAN)%s$(HELP_C_RESET)\n' 'mudd.one - Veterinary Ultrasound Processing'
	@printf '\n'
	@printf '  $(HELP_C_YELLOW)%s$(HELP_C_RESET)\n' 'BUILD'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'build' 'Build debug (workspace)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'release' 'Build release (workspace)'
	@printf '\n'
	@printf '  $(HELP_C_YELLOW)%s$(HELP_C_RESET)\n' 'QUALITY'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'fmt' 'Format all code'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'fmt-check' 'Check formatting (no changes)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'lint' 'Format check + clippy -D warnings'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'check' 'Full quality gate (fmt + clippy)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'test' 'Run all tests'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'test-quick' 'Run lib tests only (fast)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'ci' 'Full CI: fmt-check + lint + test'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'fix' 'Auto-fix clippy + format'
	@printf '\n'
	@printf '  $(HELP_C_YELLOW)%s$(HELP_C_RESET)\n' 'VERSION'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'version' 'Show current version'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'bump-patch' 'Bump patch (0.1.0 -> 0.1.1)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'bump-minor' 'Bump minor (0.1.0 -> 0.2.0)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'bump-major' 'Bump major (0.1.0 -> 1.0.0)'
	@printf '\n'
	@printf '  $(HELP_C_YELLOW)%s$(HELP_C_RESET)\n' 'HOOKS'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'hooks-install' 'Install pre-commit + pre-push hooks'
	@printf '%s\n' '  make hooks-uninstall Remove hooks'
	@printf '\n'
	@printf '  $(HELP_C_YELLOW)%s$(HELP_C_RESET)\n' 'APP'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'bindings' 'Build FFI + generate Swift bindings'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'xcode' 'Regenerate Xcode project (xcodegen)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'app' 'Full app build (bindings + xcode + build)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'dmg' 'Build release DMG (ad-hoc signed)'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'dmg-signed' 'Build release DMG (Developer ID signed)'
	@printf '\n'
	@printf '  $(HELP_C_YELLOW)%s$(HELP_C_RESET)\n' 'OTHER'
	@printf '    $(HELP_C_GREEN)%-18s$(HELP_C_RESET) %s\n' 'clean' 'cargo clean + remove caches'
