#!/bin/bash

echo "Starting PatchCore Environment Setup..."

# 1. Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Detected Python version: $PYTHON_VERSION (README recommends Python 3.8)"

# 2. Check for python3-venv package
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    echo "python3-venv package is required to create a virtual environment."
    echo "Please run: sudo apt update && sudo apt install python3-venv"
    echo "Then rerun this script."
    exit 1
fi

# 3. Create and activate virtual environment
echo "Creating Python virtual environment in '.venv'..."
python3 -m venv .venv
source .venv/bin/activate

# 4. Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "==============================================================="
echo "Setup Complete!"
echo "To use the environment, activate it with: source .venv/bin/activate"
echo "Remember to set PYTHONPATH before running scripts:"
echo "export PYTHONPATH=src"
echo "==============================================================="
