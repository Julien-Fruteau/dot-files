#!/usr/bin/env bash

MODEL=~/AI/models/qwen/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf

llama-cli \
    -m "$MODEL" \
    -ngl 99 \
    -c 4096 \
    "$@"
