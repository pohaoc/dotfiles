#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
UV_CACHE_DIR="/mnt/cache/uv"
HF_CACHE_DIR="/mnt/cache/huggingface"
PROFILE_FILE="${HOME}/.bashrc"

# --- Ensure cache dirs exist ---
mkdir -p "$UV_CACHE_DIR" "$HF_CACHE_DIR"

# --- Install uv ---
curl -LsSf https://astral.sh/uv/install.sh | sh

# Make uv available in this script's shell (installer adds it to PATH for future shells only)
export PATH="${HOME}/.local/bin:${PATH}"

# --- Install huggingface CLI (via uv, falls back to pip if uv missing) ---
if command -v uv >/dev/null 2>&1; then
    uv tool install -U "huggingface_hub"
else
    pip install -U "huggingface_hub"
fi

# --- Persist env vars in shell profile ---
if ! grep -q "UV_CACHE_DIR" "$PROFILE_FILE" 2>/dev/null; then
    echo "export UV_CACHE_DIR=\"$UV_CACHE_DIR\"" >> "$PROFILE_FILE"
fi
if ! grep -q "HF_HOME" "$PROFILE_FILE" 2>/dev/null; then
    echo "export HF_HOME=\"$HF_CACHE_DIR\"" >> "$PROFILE_FILE"
fi

# --- Export for current shell/script execution ---
export UV_CACHE_DIR="$UV_CACHE_DIR"
export HF_HOME="$HF_CACHE_DIR"

echo "uv and huggingface CLI installed."
echo "UV_CACHE_DIR set to: $UV_CACHE_DIR"
echo "HF_HOME set to: $HF_CACHE_DIR"
echo "Run 'source ~/.bashrc' or start a new shell to pick up the change."
