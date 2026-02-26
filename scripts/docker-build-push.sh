#!/bin/bash

##############################################################################
# Script para fazer build e push das imagens Docker para o Docker Hub
#
# Uso:
#   ./docker-build-push.sh [OPTIONS]
#
# Opções:
#   -u, --username USERNAME    Nome de usuário do Docker Hub
#   -v, --version VERSION      Versão/tag para as imagens
#   -p, --push                 Fazer push para Docker Hub
#   -h, --help                 Mostrar esta ajuda
#
# Exemplos:
#   ./docker-build-push.sh -u "seu-usuario"
#   ./docker-build-push.sh -u "seu-usuario" -v "1.0.0" -p
#   ./docker-build-push.sh -u "seu-usuario" -p
##############################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Variáveis
DOCKER_USERNAME="${DOCKER_USERNAME:-}"
VERSION=""
SHOULD_PUSH=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# ===== FUNÇÕES =====
print_header() {
    echo -e "${MAGENTA}==============================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${MAGENTA}==============================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

show_help() {
    head -n 20 "$0" | tail -n 19 | sed 's/# //g'
}

# ===== PARSING DE ARGUMENTOS =====
while [[ $# -gt 0 ]]; do
    case $1 in
    -u | --username)
        DOCKER_USERNAME="$2"
        shift 2
        ;;
    -v | --version)
        VERSION="$2"
        shift 2
        ;;
    -p | --push)
        SHOULD_PUSH=true
        shift
        ;;
    -h | --help)
        show_help
        exit 0
        ;;
    *)
        print_error "Argumento desconhecido: $1"
        show_help
        exit 1
        ;;
    esac
done

# ===== VALIDAÇÕES =====
print_header "🔍 Validando pré-requisitos"

if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado ou não está no PATH"
    exit 1
fi
print_success "Docker encontrado"

if [ -z "$DOCKER_USERNAME" ]; then
    print_error "DockerUsername não fornecido. Use -u ou defina DOCKER_USERNAME"
    exit 1
fi

# Obter versão (git SHA curto ou 'latest')
if [ -z "$VERSION" ]; then
    if [ -d "$REPO_ROOT/.git" ]; then
        VERSION=$(git -C "$REPO_ROOT" rev-parse --short HEAD)
        print_info "Versão obtida do Git: $VERSION"
    else
        VERSION="latest"
        print_warning "Não é um repositório Git, usando versão: latest"
    fi
fi

echo ""
print_info "Usuário Docker Hub: $DOCKER_USERNAME"
print_info "Versão: $VERSION"
if [ "$SHOULD_PUSH" = true ]; then
    print_info "Modo: Build + Push"
else
    print_info "Modo: Build (sem push)"
fi
echo ""

# ===== DEFINIR SERVIÇOS =====
declare -a SERVICES=(
    "identity-api:src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile"
    "properties-api:src/Services/Properties/AgroSolutions.Properties.Api/Dockerfile"
    "sensors-api:src/Services/Sensors/AgroSolutions.Sensors.Api/Dockerfile"
    "alerts-api:src/Services/Alerts/AgroSolutions.Alerts.API/Dockerfile"
)

# ===== BUILD DAS IMAGENS =====
cd "$REPO_ROOT"
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

for service_info in "${SERVICES[@]}"; do
    IFS=: read -r SERVICE_NAME DOCKERFILE <<<"$service_info"
    
    IMAGE_NAME="$DOCKER_USERNAME/agrosolution-$SERVICE_NAME"
    IMAGE_TAG="$IMAGE_NAME:$VERSION"
    IMAGE_LATEST="$IMAGE_NAME:latest"
    
    print_header "🔨 Building: $SERVICE_NAME"
    print_info "Dockerfile: $DOCKERFILE"
    print_info "Tags: $IMAGE_TAG, $IMAGE_LATEST"
    echo ""
    
    # Validar Dockerfile
    if [ ! -f "$DOCKERFILE" ]; then
        print_error "Dockerfile não encontrado: $DOCKERFILE"
        ((FAILED_BUILDS++))
        echo ""
        continue
    fi
    
    # Build da imagem
    print_info "Iniciando build..."
    if docker build -f "$DOCKERFILE" -t "$IMAGE_TAG" -t "$IMAGE_LATEST" .; then
        print_success "Build concluído com sucesso!"
        ((SUCCESSFUL_BUILDS++))
        
        # Push se solicitado
        if [ "$SHOULD_PUSH" = true ]; then
            print_info "Fazendo push para Docker Hub..."
            
            if docker push "$IMAGE_TAG"; then
                print_success "Push de versão concluído: $IMAGE_TAG"
            else
                print_error "Erro ao fazer push de versão: $IMAGE_TAG"
                ((FAILED_BUILDS++))
                echo ""
                continue
            fi
            
            if docker push "$IMAGE_LATEST"; then
                print_success "Push de latest concluído: $IMAGE_LATEST"
            else
                print_error "Erro ao fazer push de latest: $IMAGE_LATEST"
                ((FAILED_BUILDS++))
                echo ""
                continue
            fi
        fi
    else
        print_error "Erro ao fazer build!"
        ((FAILED_BUILDS++))
    fi
    
    echo ""
done

# ===== RESUMO =====
TOTAL_SERVICES=${#SERVICES[@]}

print_header "📊 RESUMO DO BUILD"
print_success "Sucessos: $SUCCESSFUL_BUILDS / $TOTAL_SERVICES"

if [ $FAILED_BUILDS -gt 0 ]; then
    print_error "Falhas: $FAILED_BUILDS"
    echo ""
    exit 1
fi

echo ""
if [ "$SHOULD_PUSH" = true ]; then
    echo -e "${GREEN}🎉 Todas as imagens foram buildadas e enviadas para Docker Hub!${NC}"
else
    echo -e "${GREEN}✅ Todas as imagens foram buildadas localmente!${NC}"
fi

echo ""
print_info "Imagens disponíveis em:"
for service_info in "${SERVICES[@]}"; do
    IFS=: read -r SERVICE_NAME _ <<<"$service_info"
    echo "   - $DOCKER_USERNAME/agrosolution-$SERVICE_NAME:$VERSION"
    echo "   - $DOCKER_USERNAME/agrosolution-$SERVICE_NAME:latest"
done

if [ "$SHOULD_PUSH" = false ]; then
    echo ""
    print_info "Para fazer push para Docker Hub, use:"
    echo "   ./docker-build-push.sh -u '$DOCKER_USERNAME' -v '$VERSION' -p"
fi

echo ""
