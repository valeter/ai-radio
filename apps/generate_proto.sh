#!/bin/bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Создаем виртуальное окружение если его нет
VENV_DIR=".venv"
if [ ! -d "$VENV_DIR" ]; then
    echo_info "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

echo_info "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Устанавливаем зависимости в venv
echo_info "Installing Python dependencies in virtual environment..."
"$VENV_DIR/bin/pip" install "protobuf==5.29.1"
"$VENV_DIR/bin/pip" install "grpcio==1.68.0"
"$VENV_DIR/bin/pip" install "grpcio-tools==1.68.0"

# Проверка зависимостей
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo_error "$1 is not installed"
        return 1
    fi
    echo_info "$1 is installed"
    return 0
}

# Проверка Python модуля (используем python из venv)
check_python_module() {
    if "$VENV_DIR/bin/python" -c "import $1" &> /dev/null; then
        echo_info "Python module $1 is installed"
        return 0
    else
        echo_error "Python module $1 is NOT installed"
        return 1
    fi
}

echo_info "Checking dependencies..."
check_dependency protoc || exit 1
check_dependency git || exit 1

# Проверяем версию protoc
PROTOC_VERSION=$(protoc --version | cut -d' ' -f2)
echo_info "protoc version: $PROTOC_VERSION"

# Проверяем Python модули
echo_info "Checking Python modules..."
check_python_module grpc_tools || exit 1

# Проверяем go плагины
if command -v protoc-gen-go &> /dev/null; then
    echo_info "protoc-gen-go is installed"
else
    echo_error "protoc-gen-go is NOT installed"
    echo_warn "Install with: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
    exit 1
fi

echo_info "Cleaning and creating directories..."
rm -rf proto/generated
mkdir -p proto/generated/go
mkdir -p proto/generated/python

# Клонирование зависимостей
if [ ! -d "proto/googleapis" ]; then
  echo_info "Cloning googleapis..."
  git clone --depth 1 https://github.com/googleapis/googleapis.git proto/googleapis
else
  echo_info "googleapis already exists"
fi

if [ ! -d "proto/cloudapi" ]; then
  echo_info "Cloning cloudapi..."
  git clone --depth 1 https://github.com/yandex-cloud/cloudapi.git proto/cloudapi
else
  echo_info "cloudapi already exists"
fi

echo_info "Generating Go code..."

# Go: Генерация для cloudapi
if [ -d "proto/cloudapi/yandex/cloud/ai/tts/v3" ]; then
  echo_info "Generating Go code for cloudapi TTS v3..."
  protoc --proto_path=proto/googleapis \
    --proto_path=proto/cloudapi \
    --go_out=proto/generated/go \
    --go_opt=paths=source_relative \
    --go-grpc_out=proto/generated/go \
    --go-grpc_opt=paths=source_relative \
    $(find proto/cloudapi/yandex/cloud/ai/tts/v3 -name '*.proto' -type f | sort)
else
  echo_warn "proto/cloudapi/yandex/cloud/ai/tts/v3 not found"
fi

# Go: Генерация для наших proto
if [ -d "proto/src" ] && [ -n "$(find proto/src -name '*.proto' -type f)" ]; then
  echo_info "Generating Go code for custom proto files..."
  protoc --proto_path=proto/googleapis \
    --proto_path=proto/cloudapi \
    --proto_path=proto/src \
    --go_out=proto/generated/go \
    --go_opt=paths=source_relative \
    --go-grpc_out=proto/generated/go \
    --go-grpc_opt=paths=source_relative \
    $(find proto/src -name '*.proto' -type f | sort)
else
  echo_warn "No custom proto files found in proto/src"
fi

echo_info "Generating Python code..."

# Python: Генерация для cloudapi
if [ -d "proto/cloudapi/yandex/cloud/ai/tts/v3" ]; then
  echo_info "Generating Python code for cloudapi TTS v3..."
  "$VENV_DIR/bin/python" -m grpc_tools.protoc \
    -I=proto/googleapis \
    -I=proto/cloudapi \
    --python_out=proto/generated/python \
    --grpc_python_out=proto/generated/python \
    --pyi_out=proto/generated/python \
    $(find proto/cloudapi/yandex/cloud/ai/tts/v3 -name '*.proto' -type f | sort)
fi

# Python: Генерация для наших proto
if [ -d "proto/src" ] && [ -n "$(find proto/src -name '*.proto' -type f)" ]; then
  echo_info "Generating Python code for custom proto files..."
  "$VENV_DIR/bin/python" -m grpc_tools.protoc \
    -I=proto/googleapis \
    -I=proto/cloudapi \
    -I=proto/src \
    --python_out=proto/generated/python \
    --grpc_python_out=proto/generated/python \
    --pyi_out=proto/generated/python \
    $(find proto/src -name '*.proto' -type f | sort)
fi

# Копирование сгенерированных файлов
echo_info "Copying generated files..."

# Для Go
if [ -d "proto/generated/go" ] && [ -n "$(ls -A proto/generated/go 2>/dev/null)" ]; then
  rm -rf go/speech-generator/generated
  mkdir -p go/speech-generator/generated
  cp -r proto/generated/go/* go/speech-generator/generated/ 2>/dev/null || true
  echo_info "Go files copied successfully"
else
  echo_warn "No Go files generated"
fi

# Для Python
if [ -d "proto/generated/python" ] && [ -n "$(ls -A proto/generated/python 2>/dev/null)" ]; then
  # Создаем целевые директории
  mkdir -p python/fetch-news
  
  # Копируем с проверкой
  if [ -d "proto/generated/python" ]; then
    # Удаляем только если есть что копировать
    [ -d "python/fetch-news/voicegen" ] && rm -rf python/fetch-news/voicegen
    [ -d "python/fetch-news/yandex" ] && rm -rf python/fetch-news/yandex
    
    cp -r proto/generated/python/* python/fetch-news/ 2>/dev/null || true
    
    # Создаем __init__.py файлы
    mkdir -p python/fetch-news/voicegen
    touch python/fetch-news/voicegen/__init__.py
    
    mkdir -p python/fetch-news/yandex/cloud/ai/tts/v3
    touch python/fetch-news/yandex/__init__.py
    touch python/fetch-news/yandex/cloud/__init__.py
    touch python/fetch-news/yandex/cloud/ai/__init__.py
    touch python/fetch-news/yandex/cloud/ai/tts/__init__.py
    touch python/fetch-news/yandex/cloud/ai/tts/v3/__init__.py
    
    echo_info "Python files copied successfully"
  fi
else
  echo_warn "No Python files generated"
fi

echo_info "Proto generation completed!"