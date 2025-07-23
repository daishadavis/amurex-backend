#!/bin/bash

echo "📥 Starting model download..."

# Wait for Ollama service to be ready
echo "⏳ Waiting for Ollama service to start..."
until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama..."
    sleep 5
done

echo "✅ Ollama is ready!"

# Download llama3.1:8b model
echo "📦 Downloading llama3.1:8b model (this may take a while)..."
docker exec ollama ollama pull llama3.1:8b

echo "🎉 Model download complete!"
echo "🌐 You can now access:"
echo "   - Ollama API: http://localhost:11434"
echo "   - Web UI: http://localhost:3000"
