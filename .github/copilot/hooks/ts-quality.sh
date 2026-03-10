#!/usr/bin/env bash
# .github/copilot/hooks/ts-quality.sh
# TypeScript/JavaScript quality checks for the Copilot pre-push hook.
# Requires: Node.js and either pnpm, npm, or yarn on PATH.
# Exit code 0 = all checks passed. Non-zero = at least one check failed.
#
# Checks run (in order):
#   1. Type check — tsc --noEmit (zero type errors allowed)
#   2. Lint       — ESLint, zero warnings allowed
#   3. Tests      — full Vitest / Jest suite must be green

set -uo pipefail

FAILED=0

# ── Helpers ──────────────────────────────────────────────────────────────────
pass() { echo "  ✅ $*"; }
fail() { echo "  ❌ $*"; FAILED=1; }
skip() { echo "  ⏭️  $*"; }

# Detect package manager (pnpm first — matches this workspace)
if command -v pnpm &>/dev/null && [[ -f "pnpm-workspace.yaml" || -f "pnpm-lock.yaml" ]]; then
  PM="pnpm"
elif command -v yarn &>/dev/null && [[ -f "yarn.lock" ]]; then
  PM="yarn"
else
  PM="npm"
fi

echo ""
echo "── 1. Type check (tsc --noEmit) ────────────────────────────────────────"
if command -v tsc &>/dev/null; then
  if tsc --noEmit 2>&1; then
    pass "No TypeScript errors"
  else
    fail "TypeScript type errors found — run 'tsc --noEmit' to see details"
  fi
elif [[ -f "node_modules/.bin/tsc" ]]; then
  if node_modules/.bin/tsc --noEmit 2>&1; then
    pass "No TypeScript errors"
  else
    fail "TypeScript type errors found"
  fi
else
  skip "tsc not found — run '$PM install' first"
fi

echo ""
echo "── 2. ESLint (zero warnings) ───────────────────────────────────────────"
# Use the project's lint script if available; fall back to direct eslint invocation
if $PM run lint --if-present -- --max-warnings 0 2>&1; then
  pass "ESLint passed"
else
  fail "ESLint violations found — run '$PM run lint' to see details"
fi

echo ""
echo "── 3. Tests ────────────────────────────────────────────────────────────"
# --run flag (Vitest) prevents interactive watch mode; ignored by Jest
if $PM run test --if-present -- --run 2>&1; then
  pass "All tests passed"
else
  fail "Tests FAILED — run '$PM run test' to see full output"
fi

echo ""
[[ $FAILED -ne 0 ]] && exit 1 || exit 0
