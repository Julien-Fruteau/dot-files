#!/usr/bin/env bash

MODEL=~/ai-local/models/qwen/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf
MCP_CONFIG=~/ai-local/mcp/servers.json
HOST=0.0.0.0
PORT=8081

if [ ! -f "$MODEL" ]; then
    echo "Model not found, downloading Qwen2.5-Coder-3B-Instruct..."
    hf download \
        bartowski/Qwen2.5-Coder-3B-Instruct-GGUF \
        Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf \
        --local-dir "$(dirname "$MODEL")"
fi

ARGS=(
    -m "$MODEL"
    -ngl 99
    -c 4096
    --host "$HOST"
    --port "$PORT"
)

if [ -f "$MCP_CONFIG" ]; then
    ARGS+=(--mcp-servers-config "$MCP_CONFIG" --ui-mcp-proxy)
fi

llama-server "${ARGS[@]}" "$@"
