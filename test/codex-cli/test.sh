#!/bin/bash
set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "node version" node --version
check "npm version" npm --version
check "codex cli installed" command -v codex
check "codex version" codex --version

# Report results
reportResults



