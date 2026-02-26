#!/usr/bin/env pwsh

<#
.SYNOPSIS
Teste local do Docker Buildx para diagnosticar problemas antes de fazer push

.DESCRIPTION
Este script verifica:
- Docker instalado
- Docker Buildx disponível
- Espaço em disco
- Memória disponível
- Consegue fazer pull de imagens
- Bootstrap do buildx funciona

.EXAMPLE
.\test-docker-buildx.ps1
#>

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🔧 Teste Local - Docker Buildx Diagnostics                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$allTests = $true

# ===== TESTE 1: Docker Instalado =====
Write-Host "🔍 [1/7] Verificando Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>$null
if ($?) {
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Docker não está instalado" -ForegroundColor Red
    $allTests = $false
}

# ===== TESTE 2: Docker Rodando =====
Write-Host "`n🔍 [2/7] Verificando se Docker está rodando..." -ForegroundColor Yellow
docker ps >$null 2>&1
if ($?) {
    Write-Host "✅ Docker está rodando" -ForegroundColor Green
} else {
    Write-Host "❌ Docker não está rodando. Inicie Docker Desktop." -ForegroundColor Red
    $allTests = $false
}

# ===== TESTE 3: Docker Buildx =====
Write-Host "`n🔍 [3/7] Verificando Docker Buildx..." -ForegroundColor Yellow
$buildxVersion = docker buildx version 2>$null
if ($buildxVersion) {
    Write-Host "✅ Buildx: $buildxVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Docker Buildx não está disponível" -ForegroundColor Red
    Write-Host "   Solução: docker buildx create --use" -ForegroundColor Yellow
    $allTests = $false
}

# ===== TESTE 4: Espaço em Disco =====
Write-Host "`n🔍 [4/7] Verificando espaço em disco..." -ForegroundColor Yellow
$disk = Get-Volume | Where-Object { $_.DriveLetter -eq 'C' } | Select-Object -ExpandProperty SizeRemaining
$diskGB = [math]::Round($disk / 1GB, 2)
if ($diskGB -gt 20) {
    Write-Host "✅ Espaço em disco: ${diskGB}GB disponível" -ForegroundColor Green
} elseif ($diskGB -gt 10) {
    Write-Host "⚠️  Espaço em disco: ${diskGB}GB (recomendado >20GB)" -ForegroundColor Yellow
    $allTests = $false
} else {
    Write-Host "❌ Espaço em disco: ${diskGB}GB (crítico! Limpe o disco)" -ForegroundColor Red
    $allTests = $false
}

# ===== TESTE 5: Memória =====
Write-Host "`n🔍 [5/7] Verificando memória disponível..." -ForegroundColor Yellow
$memObj = Get-WmiObject -Class win32_operatingsystem
$memFree = [math]::Round($memObj.FreePhysicalMemory / 1MB, 2)
$memTotal = [math]::Round($memObj.TotalVisibleMemorySize / 1MB, 2)
if ($memFree -gt 2048) {
    Write-Host "✅ Memória: ${memFree}MB / ${memTotal}MB disponível" -ForegroundColor Green
} else {
    Write-Host "⚠️  Memória baixa: ${memFree}MB disponível" -ForegroundColor Yellow
}

# ===== TESTE 6: Buildx Builder =====
Write-Host "`n🔍 [6/7] Verificando Buildx Builder..." -ForegroundColor Yellow
$builder = docker buildx ls 2>$null | findstr "desktop-linux"
if ($builder) {
    Write-Host "✅ Builder disponível" -ForegroundColor Green
    Write-Host "   $builder" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Builder padrão não encontrado" -ForegroundColor Yellow
    Write-Host "   Tentando criar novo builder..." -ForegroundColor Yellow
    docker buildx create --name default-builder --use 2>$null
    if ($?) {
        Write-Host "✅ Builder criado" -ForegroundColor Green
    }
}

# ===== TESTE 7: Pull de Imagem =====
Write-Host "`n🔍 [7/7] Testando pull de imagem (moby/buildkit:latest)..." -ForegroundColor Yellow
docker pull moby/buildkit:latest --quiet 2>$null | Out-Null
if ($?) {
    Write-Host "✅ Pull de imagem: OK" -ForegroundColor Green
} else {
    Write-Host "⚠️  Não conseguiu fazer pull (pode ser problema de rede)" -ForegroundColor Yellow
}

# ===== TESTE BÔNUS: Build Simples =====
Write-Host "`n🔍 [BÔNUS] Testando build simples com Buildx..." -ForegroundColor Yellow
$testFile = "Dockerfile.test"

# Criar Dockerfile temporário
@"
FROM alpine:latest
RUN echo "Test successful"
"@ | Out-File -FilePath $testFile -Encoding UTF8 -Force

$buildResult = docker buildx build --dry-run -f $testFile . 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build simples: OK" -ForegroundColor Green
} else {
    Write-Host "⚠️  Build simples falhou" -ForegroundColor Yellow
    Write-Host "   Erro: $($buildResult | Select-Object -Last 1)" -ForegroundColor Gray
}

# Limpar arquivo temporário
Remove-Item $testFile -Force -ErrorAction SilentlyContinue

# ===== RESUMO =====
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  📊 RESUMO DO DIAGNÓSTICO                                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

if ($allTests) {
    Write-Host "✅ Tudo OK! Docker Buildx deve funcionar bem localmente." -ForegroundColor Green
    Write-Host "`n💡 Se tiver problema no GitHub Actions, as causas são:" -ForegroundColor Cyan
    Write-Host "   • Timeout (aumentar em .github/workflows/docker-build-push.yml)" -ForegroundColor Cyan
    Write-Host "   • Espaço em disco do runner (limpar ou usar outro runner)" -ForegroundColor Cyan
    Write-Host "   • Problema de rede (tentar novamente)" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Encontrei problemas. Corrija e tente novamente:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Soluções:" -ForegroundColor Cyan
    Write-Host "   1. Inicie Docker Desktop" -ForegroundColor Cyan
    Write-Host "   2. Limpe espaço em disco (mínimo 20GB livre)" -ForegroundColor Cyan
    Write-Host "   3. Feche outros programas que usem muita memória" -ForegroundColor Cyan
}

Write-Host "`n"
