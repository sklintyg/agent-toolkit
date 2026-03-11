#!/usr/bin/env bash
# .github/copilot/hooks/java-quality.sh
# Java quality checks for the Copilot pre-push hook.
# Requires: Java, Gradle or Maven on PATH.
# Exit code 0 = all checks passed. Non-zero = at least one check failed.
#
# Checks run (in order):
#   1. Compile — fails fast if the code does not compile
#   2. Checkstyle — style violations
#   3. SpotBugs — static bug analysis (skipped gracefully if not configured)
#   4. SonarLint CLI — BLOCKER/CRITICAL issues only (skipped if not installed)
#   5. Tests — full test suite must be green

set -uo pipefail

FAILED=0

# ── Helpers ──────────────────────────────────────────────────────────────────
info()  { echo "  ℹ️  $*"; }
pass()  { echo "  ✅ $*"; }
fail()  { echo "  ❌ $*"; FAILED=1; }
skip()  { echo "  ⏭️  $*"; }

# Detect build tool
if [[ -f "build.gradle" || -f "build.gradle.kts" ]]; then
  BUILD_CMD="./gradlew"
elif [[ -f "pom.xml" ]]; then
  BUILD_CMD="mvn"
else
  fail "No build.gradle or pom.xml found — cannot run Java quality checks."
  exit 1
fi

echo ""
echo "── 1. Compile ──────────────────────────────────────────────────────────"
if [[ "$BUILD_CMD" == "./gradlew" ]]; then
  if $BUILD_CMD compileJava compileTestJava --quiet 2>&1; then
    pass "Compilation succeeded"
  else
    fail "Compilation FAILED — fix errors before pushing"
    exit 1   # No point running further checks if it doesn't compile
  fi
else
  if mvn compile test-compile --quiet 2>&1; then
    pass "Compilation succeeded"
  else
    fail "Compilation FAILED — fix errors before pushing"
    exit 1
  fi
fi

echo ""
echo "── 2. Checkstyle ───────────────────────────────────────────────────────"
if [[ "$BUILD_CMD" == "./gradlew" ]]; then
  if $BUILD_CMD checkstyleMain checkstyleTest --quiet 2>&1; then
    pass "Checkstyle passed"
  else
    fail "Checkstyle violations found — run './gradlew checkstyleMain' to see details"
  fi
else
  if mvn checkstyle:check --quiet 2>&1; then
    pass "Checkstyle passed"
  else
    fail "Checkstyle violations found — run 'mvn checkstyle:check' to see details"
  fi
fi

echo ""
echo "── 3. SpotBugs (static analysis) ──────────────────────────────────────"
if [[ "$BUILD_CMD" == "./gradlew" ]]; then
  if $BUILD_CMD tasks --quiet 2>/dev/null | grep -q "spotbugsMain"; then
    if $BUILD_CMD spotbugsMain --quiet 2>&1; then
      pass "SpotBugs passed"
    else
      fail "SpotBugs found issues — run './gradlew spotbugsMain' to see the report"
    fi
  else
    skip "SpotBugs not configured in this project"
  fi
else
  if mvn help:describe -Dplugin=com.github.spotbugs:spotbugs-maven-plugin -q 2>/dev/null; then
    if mvn spotbugs:check --quiet 2>&1; then
      pass "SpotBugs passed"
    else
      fail "SpotBugs found issues — run 'mvn spotbugs:check' to see the report"
    fi
  else
    skip "SpotBugs not configured in this project"
  fi
fi

echo ""
echo "── 4. SonarLint CLI (BLOCKER/CRITICAL only) ────────────────────────────"
if command -v sonarlint &>/dev/null; then
  # Only fail on BLOCKER or CRITICAL severity — warnings and INFO are noise during migration
  SONAR_OUTPUT=$(sonarlint analyze --format json 2>/dev/null || true)
  BLOCKERS=$(echo "$SONAR_OUTPUT" | grep -c '"severity":"BLOCKER"\|"severity":"CRITICAL"' || true)
  if [[ "$BLOCKERS" -eq 0 ]]; then
    pass "SonarLint: no BLOCKER or CRITICAL issues"
  else
    fail "SonarLint found $BLOCKERS BLOCKER/CRITICAL issue(s) — run 'sonarlint analyze' to see details"
  fi
else
  skip "SonarLint CLI not installed — install from https://docs.sonarsource.com/sonarlint/vs-code/"
fi

echo ""
echo "── 5. Tests ────────────────────────────────────────────────────────────"
if [[ "$BUILD_CMD" == "./gradlew" ]]; then
  if $BUILD_CMD test 2>&1; then
    pass "All tests passed"
  else
    fail "Tests FAILED — run './gradlew test' to see full output"
  fi
else
  if mvn test 2>&1; then
    pass "All tests passed"
  else
    fail "Tests FAILED — run 'mvn test' to see full output"
  fi
fi

echo ""
[[ $FAILED -ne 0 ]] && exit 1 || exit 0
