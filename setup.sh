#!/usr/bin/env bash

# Setup script for BashBlog development
set -euo pipefail

printf "Checking dependencies...\n"
if ! command -v shellcheck &> /dev/null; then
    printf "Error: 'shellcheck' is not installed. Please install it before setting up the development environment.\n"
    exit 1
fi

printf "Setting up Git hooks...\n"
git config core.hooksPath hooks

printf "Initializing submodules...\n"
git submodule update --init --recursive

printf "\nSetup complete! You can now run tests with:\n"
printf "./tests/bats-core/bin/bats tests/bb.bats\n"
