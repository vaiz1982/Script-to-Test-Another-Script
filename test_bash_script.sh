#!/bin/bash

# This script will check the syntax, static analysis, and potentially dangerous commands in another script.
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
if command -v shellcheck >/dev/null 2>&1; then
    echo "ShellCheck is already installed."
else
    echo "ShellCheck not found. Installing ShellCheck..."
    sudo apt-get update && sudo apt-get install -y shellcheck
fi

echo "Running static analysis with ShellCheck..."
shellcheck "$SCRIPT"

# 3. Check for dangerous file permissions
echo "Checking for dangerous file permissions..."
if [ -x "$SCRIPT" ]; then
    echo "WARNING: $SCRIPT has executable permissions. Ensure this is intended."
fi

# 4. Check for dangerous commands
echo "Checking for potentially malicious commands..."
dangerous_commands=("rm -rf" "dd if=" "wget" "curl" "nc -e" "bash -i" "nc -l" "eval" "sudo" "su" "chmod 777" "chmod +x")
for cmd in "${dangerous_commands[@]}"; do
    if grep -q "$cmd" "$SCRIPT"; then
        echo "WARNING: Potentially dangerous command found: $cmd"
    fi
done

# 5. Check for suspicious file operations
echo "Checking for suspicious file operations..."
file_ops=("cp" "mv" "rm" "touch" "mkdir" "ln")
for cmd in "${file_ops[@]}"; do
    if grep -q "$cmd" "$SCRIPT"; then
        echo "WARNING: Potential dangerous file operation found: $cmd"
    fi
done

# 6. Check for root privileges requests
echo "Checking for root privileges requests..."
if grep -q "sudo" "$SCRIPT" || grep -q "su" "$SCRIPT"; then
    echo "WARNING: The script contains requests for root/superuser privileges!"
fi

# 7. Check for base64 encoding
echo "Checking for base64 encoding..."
if grep -q "base64" "$SCRIPT"; then
    echo "WARNING: Base64 encoding found in the script. This could be obfuscation."
fi

# 8. Check for sensitive information (passwords, tokens, etc.)
echo "Checking for sensitive information in the script..."
keywords=("password" "api_key" "secret" "token" "private_key")
for keyword in "${keywords[@]}"; do
    if grep -qi "$keyword" "$SCRIPT"; then
        echo "WARNING: Potential sensitive information found: $keyword"
    fi
done

echo "Static test completed!"
