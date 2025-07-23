#!/bin/bash

# Ollama Docker Setup Script
# This script sets up Ollama with Docker Compose and downloads llama3.1:8b

set -e  # Exit on any error

echo "🚀 Starting Ollama Docker Setup..."

# System Requirements Check
echo "🔍 Checking system requirements..."

# Check available RAM (at least 10GB recommended for llama3.1:8b)
if command -v free &> /dev/null; then
    # Linux
    TOTAL_RAM_KB=$(free | grep '^Mem:' | awk '{print $2}')
    TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac
    TOTAL_RAM_BYTES=$(sysctl -n hw.memsize)
    TOTAL_RAM_GB=$((TOTAL_RAM_BYTES / 1024 / 1024 / 1024))
else
    #scrutinize for Windows
    TOTAL_RAM_GB=16
    echo "⚠️  Cannot detect RAM on this system - proceeding anyway"
fi

if [ $TOTAL_RAM_GB -lt 10 ]; then
    echo "⚠️  WARNING: You have ${TOTAL_RAM_GB}GB RAM. llama3.1:8b needs ~8GB+ RAM to run properly."
    echo "    Consider using a smaller model like llama3.1:1b or phi3:mini"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
fi

# Check available disk space (at least 8GB for llama3.1:8b model)
AVAILABLE_SPACE_KB=$(df . | tail -1 | awk '{print $4}')
AVAILABLE_SPACE_GB=$((AVAILABLE_SPACE_KB / 1024 / 1024))

if [ $AVAILABLE_SPACE_GB -lt 10 ]; then
    echo "⚠️  WARNING: Only ${AVAILABLE_SPACE_GB}GB disk space available."
    echo "    llama3.1:8b model is ~4.7GB, plus Docker images need ~2GB"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
fi

echo "✅ System requirements check passed (RAM: ${TOTAL_RAM_GB}GB, Disk: ${AVAILABLE_SPACE_GB}GB)"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

#Detect operating system
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Windows;;
    MINGW*)     MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "🖥️  Detected OS: $MACHINE"

# Create project directory
PROJECT_DIR="ollama-docker-setup"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Create docker-compose.yml file


# Create .env file for environment variables


# Create model download script
cat > download-models.sh << 'EOF'
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
EOF

chmod +x download-models.sh

# Create utility scripts
cat > ollama-cli.sh << 'EOF'
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
EOF

chmod +x ollama-cli.sh

# Create README (for running ollama in a docker container)


#BElow is the main part that can be classified as a startup script

echo "📁 Created project directory: $PROJECT_DIR"
echo "📄 Files created:"
echo "   - docker-compose.yml"
echo "   - .env"
echo "   - download-models.sh"
echo "   - ollama-cli.sh"
echo "   - README.md"

# Start the services
echo "🐳 Starting Docker services..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    
    # Prompt to download model
    read -p "📥 Would you like to download the llama3.1:8b model now? This may take several minutes. (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./download-models.sh
    else
        echo "💡 You can download the model later by running: ./download-models.sh"
    fi
    
    echo ""
    echo "🎉 Setup complete!"
    echo "🌐 Access points:"
    echo "   - Ollama API: http://localhost:11434"
    echo "   - Web UI: http://localhost:3000"
    echo ""
    echo "📋 Next steps:"
    echo "   - Use './ollama-cli.sh run llama3.1:8b' to chat with the model"
    echo "   - Visit http://localhost:3000 for the web interface"
    echo "   - Check README.md for more information"
else
    echo "❌ Something went wrong. Check the logs with: docker-compose logs"
fi