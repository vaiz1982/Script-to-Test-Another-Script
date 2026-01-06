#!/bin/bash

# This script will check the syntax and static analysis of another script
# Usage: ./test_bash_script.sh <script_to_test.sh>

SCRIPT="$1"

# Check if the script file is provided and exists
if [ -z "$SCRIPT" ]; then
    echo "Usage: $0 <script_to_test.sh>"
    exit 1
fi

if [ ! -f "$SCRIPT" ]; then
    echo "Error: $SCRIPT not found!"
    exit 1
fi

# 1. Syntax check with bash -n
echo "Running syntax check with bash -n..."
bash -n "$SCRIPT"
if [ $? -eq 0 ]; then
    echo "No syntax errors detected."
else
    echo "Syntax errors found!"
    exit 1
fi

# 2. Static analysis with ShellCheck (if installed)
echo "Running static analysis with ShellCheck..."
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$SCRIPT"
else
    echo "ShellCheck not installed. Please install it for better analysis."
fi

echo "Static test completed!"
