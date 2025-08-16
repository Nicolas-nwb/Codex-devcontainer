#!/bin/bash
set -e

# Import test lib
source dev-container-features-test-lib

# Tests
check "codex cli installed" command -v codex
check "codex version" codex --version

reportResults


