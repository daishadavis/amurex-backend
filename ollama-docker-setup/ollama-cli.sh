#!/bin/bash
# Ollama CLI wrapper script

if [ $# -eq 0 ]; then
    echo "Usage: ./ollama-cli.sh [ollama commands]"
    echo "Examples:"
    echo "  ./ollama-cli.sh list"
    echo "  ./ollama-cli.sh run llama3.1:8b"
    echo "  ./ollama-cli.sh show llama3.1:8b"
    exit 1
fi

docker exec -it ollama ollama "$@"
