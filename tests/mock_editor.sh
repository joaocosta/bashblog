#!/usr/bin/env bash

# Mock editor for bb.sh tests
# Appends content from env var MOCK_EDITOR_CONTENT if set, else does nothing (saves as is)

if [ -n "$MOCK_EDITOR_CONTENT" ]; then
    echo "$MOCK_EDITOR_CONTENT" >> "$1"
fi

# Simulate user saving and exiting
exit 0
