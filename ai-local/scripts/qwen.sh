#!/usr/bin/env bash

MODEL=~/ai-local/models/qwen/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf

if [ ! -f "$MODEL" ]; then
    echo "Model not found, downloading Qwen2.5-Coder-3B-Instruct..."
    hf download \
        bartowski/Qwen2.5-Coder-3B-Instruct-GGUF \
        Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf \
        --local-dir "$(dirname "$MODEL")"
fi

llama-cli \
    -m "$MODEL" \
    -ngl 99 \
    -c 4096 \
    "$@"
