#!/bin/bash

##############################################################################
# Script para testar Docker Buildx localmente
#
# Uso:
#   ./test-docker-buildx.sh
#
# Testa:
#   1. Docker instalado
#   2. Docker rodando
#   3. Docker Buildx disponível
#   4. Espaço em disco
#   5. Memória disponível
#   6. Buildx builder
#   7. Pull de imagem
#   8. Build simples
##############################################################################

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  $1${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

ALL_TESTS=true

echo ""
print_header "🔧 Teste Local - Docker Buildx Diagnostics"
echo ""

# ===== TESTE 1: Docker Instalado =====
echo -e "${YELLOW}🔍 [1/7] Verificando Docker...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker: $DOCKER_VERSION"
else
    print_error "Docker não está instalado"
    ALL_TESTS=false
fi

# ===== TESTE 2: Docker Rodando =====
echo ""
echo -e "${YELLOW}🔍 [2/7] Verificando se Docker está rodando...${NC}"
if docker ps &>/dev/null; then
    print_success "Docker está rodando"
else
    print_error "Docker não está rodando. Inicie Docker Desktop."
    ALL_TESTS=false
fi

# ===== TESTE 3: Docker Buildx =====
echo ""
echo -e "${YELLOW}🔍 [3/7] Verificando Docker Buildx...${NC}"
if BUILDX_VERSION=$(docker buildx version 2>/dev/null); then
    print_success "Buildx: $BUILDX_VERSION"
else
    print_error "Docker Buildx não está disponível"
    print_info "Solução: docker buildx create --use"
    ALL_TESTS=false
fi

# ===== TESTE 4: Espaço em Disco =====
echo ""
echo -e "${YELLOW}🔍 [4/7] Verificando espaço em disco...${NC}"
DISK_FREE=$(df / | awk 'NR==2 {print int($4 / 1024 / 1024)}')
if [ "$DISK_FREE" -gt 20 ]; then
    print_success "Espaço em disco: ${DISK_FREE}GB disponível"
elif [ "$DISK_FREE" -gt 10 ]; then
    print_warning "Espaço em disco: ${DISK_FREE}GB (recomendado >20GB)"
    ALL_TESTS=false
else
    print_error "Espaço em disco: ${DISK_FREE}GB (crítico! Limpe o disco)"
    ALL_TESTS=false
fi

# ===== TESTE 5: Memória =====
echo ""
echo -e "${YELLOW}🔍 [5/7] Verificando memória disponível...${NC}"
if command -v free &> /dev/null; then
    MEM_FREE=$(free -g | awk 'NR==2 {print $7}')
    MEM_TOTAL=$(free -g | awk 'NR==2 {print $2}')
    if [ "$MEM_FREE" -gt 2 ]; then
        print_success "Memória: ${MEM_FREE}GB / ${MEM_TOTAL}GB disponível"
    else
        print_warning "Memória baixa: ${MEM_FREE}GB disponível"
    fi
else
    print_info "Não conseguiu verificar memória (ok em macOS)"
fi

# ===== TESTE 6: Buildx Builder =====
echo ""
echo -e "${YELLOW}🔍 [6/7] Verificando Buildx Builder...${NC}"
if docker buildx ls 2>/dev/null | grep -q "default\|docker-container"; then
    print_success "Builder disponível"
    docker buildx ls | head -2
else
    print_warning "Builder padrão não encontrado"
    print_info "Tentando criar novo builder..."
    if docker buildx create --name default-builder --use 2>/dev/null; then
        print_success "Builder criado"
    fi
fi

# ===== TESTE 7: Pull de Imagem =====
echo ""
echo -e "${YELLOW}🔍 [7/7] Testando pull de imagem (moby/buildkit:latest)...${NC}"
if docker pull moby/buildkit:latest --quiet 2>/dev/null; then
    print_success "Pull de imagem: OK"
else
    print_warning "Não conseguiu fazer pull (pode ser problema de rede)"
fi

# ===== TESTE BÔNUS: Build Simples =====
echo ""
echo -e "${YELLOW}🔍 [BÔNUS] Testando build simples com Buildx...${NC}"
TEST_FILE="/tmp/Dockerfile.test"

# Criar Dockerfile temporário
cat > "$TEST_FILE" << 'EOF'
FROM alpine:latest
RUN echo "Test successful"
EOF

if docker buildx build --dry-run -f "$TEST_FILE" . &>/dev/null; then
    print_success "Build simples: OK"
else
    print_warning "Build simples falhou (pode ser problema de setup)"
fi

# Limpar arquivo temporário
rm -f "$TEST_FILE"

# ===== RESUMO =====
echo ""
echo ""
print_header "📊 RESUMO DO DIAGNÓSTICO"
echo ""

if [ "$ALL_TESTS" = true ]; then
    print_success "Tudo OK! Docker Buildx deve funcionar bem localmente."
    echo ""
    print_info "Se tiver problema no GitHub Actions, as causas são:"
    echo "   • Timeout (aumentar em .github/workflows/docker-build-push.yml)"
    echo "   • Espaço em disco do runner (limpar ou usar outro runner)"
    echo "   • Problema de rede (tentar novamente)"
else
    print_warning "Encontrei problemas. Corrija e tente novamente:"
    echo ""
    print_info "Soluções:"
    echo "   1. Inicie Docker Desktop"
    echo "   2. Limpe espaço em disco (mínimo 20GB livre)"
    echo "   3. Feche outros programas que usem muita memória"
fi

echo ""
