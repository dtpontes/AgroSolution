#!/usr/bin/env pwsh

<#
.SYNOPSIS
Script para fazer build e push das imagens Docker para o Docker Hub

.DESCRIPTION
Faz build de todas as imagens Docker (Identity, Properties, Sensors, Alerts)
e faz push para o Docker Hub com as tags apropriadas.

.PARAMETER DockerUsername
Nome de usuário do Docker Hub (ou use variável de ambiente DOCKER_USERNAME)

.PARAMETER Version
Versão/tag para as imagens (default: git short SHA)

.PARAMETER Push
Se deve fazer push para Docker Hub (default: $false para testes)

.EXAMPLE
.\docker-build-push.ps1 -DockerUsername "seu-usuario" -Push
.\docker-build-push.ps1 -DockerUsername "seu-usuario" -Version "1.0.0" -Push
#>

param(
    [string]$DockerUsername = $env:DOCKER_USERNAME,
    [string]$Version,
    [switch]$Push
)

# ===== VALIDAÇÕES =====
Write-Host "🔍 Validando pré-requisitos..." -ForegroundColor Cyan

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker não está instalado ou não está no PATH" -ForegroundColor Red
    exit 1
}

if (-not $DockerUsername) {
    Write-Host "❌ DockerUsername não fornecido. Use -DockerUsername ou defina DOCKER_USERNAME" -ForegroundColor Red
    exit 1
}

# ===== CONFIGURAÇÃO =====
if (-not $Version) {
    $Version = git rev-parse --short HEAD
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Não é um repositório Git, usando 'latest'" -ForegroundColor Yellow
        $Version = "latest"
    }
}

Write-Host "✅ Docker encontrado" -ForegroundColor Green
Write-Host "📦 Usuário Docker Hub: $DockerUsername" -ForegroundColor Cyan
Write-Host "🏷️  Versão: $Version" -ForegroundColor Cyan
Write-Host ""

# ===== DEFINIR SERVIÇOS =====
$services = @(
    @{
        name       = "identity-api"
        dockerfile = "src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile"
    },
    @{
        name       = "properties-api"
        dockerfile = "src/Services/Properties/AgroSolutions.Properties.Api/Dockerfile"
    },
    @{
        name       = "sensors-api"
        dockerfile = "src/Services/Sensors/AgroSolutions.Sensors.Api/Dockerfile"
    },
    @{
        name       = "alerts-api"
        dockerfile = "src/Services/Alerts/AgroSolutions.Alerts.API/Dockerfile"
    }
)

# ===== BUILD DAS IMAGENS =====
$failedBuilds = @()
$successfulBuilds = @()

foreach ($service in $services) {
    $imageName = "$DockerUsername/agrosolution-$($service.name)"
    $imageTag = "$imageName`:$Version"
    $imageLatest = "$imageName`:latest"
    
    Write-Host "=" * 60 -ForegroundColor Magenta
    Write-Host "🔨 Building: $($service.name)" -ForegroundColor Cyan
    Write-Host "📄 Dockerfile: $($service.dockerfile)" -ForegroundColor Gray
    Write-Host "🏷️  Tags: $imageTag, $imageLatest" -ForegroundColor Gray
    Write-Host "=" * 60 -ForegroundColor Magenta
    Write-Host ""
    
    # Validar Dockerfile
    if (-not (Test-Path $service.dockerfile)) {
        Write-Host "❌ Dockerfile não encontrado: $($service.dockerfile)" -ForegroundColor Red
        $failedBuilds += $service.name
        continue
    }
    
    # Build da imagem
    Write-Host "[*] Iniciando build..." -ForegroundColor Yellow
    $buildOutput = docker build -f $service.dockerfile -t $imageTag -t $imageLatest . 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build concluído com sucesso!" -ForegroundColor Green
        $successfulBuilds += $service.name
        
        # Push se solicitado
        if ($Push) {
            Write-Host "[*] Fazendo push para Docker Hub..." -ForegroundColor Yellow
            
            $pushTag = docker push $imageTag 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Push de versão concluído: $imageTag" -ForegroundColor Green
            } else {
                Write-Host "❌ Erro ao fazer push de versão: $imageTag" -ForegroundColor Red
                Write-Host $pushTag -ForegroundColor Red
                $failedBuilds += "$($service.name) (push)"
                continue
            }
            
            $pushLatest = docker push $imageLatest 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Push de latest concluído: $imageLatest" -ForegroundColor Green
            } else {
                Write-Host "❌ Erro ao fazer push de latest: $imageLatest" -ForegroundColor Red
                Write-Host $pushLatest -ForegroundColor Red
                $failedBuilds += "$($service.name) (push latest)"
            }
        }
    } else {
        Write-Host "❌ Erro ao fazer build!" -ForegroundColor Red
        Write-Host $buildOutput -ForegroundColor Red
        $failedBuilds += $service.name
    }
    
    Write-Host ""
}

# ===== RESUMO =====
Write-Host "=" * 60 -ForegroundColor Magenta
Write-Host "📊 RESUMO DO BUILD" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Magenta
Write-Host "✅ Sucessos: $($successfulBuilds.Count) / $($services.Count)" -ForegroundColor Green
if ($successfulBuilds.Count -gt 0) {
    $successfulBuilds | ForEach-Object { Write-Host "   ✓ $_" -ForegroundColor Green }
}
Write-Host ""

if ($failedBuilds.Count -gt 0) {
    Write-Host "❌ Falhas: $($failedBuilds.Count)" -ForegroundColor Red
    $failedBuilds | ForEach-Object { Write-Host "   ✗ $_" -ForegroundColor Red }
    Write-Host ""
    exit 1
}

Write-Host ""
if ($Push) {
    Write-Host "🎉 Todas as imagens foram buildadas e enviadas para Docker Hub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Imagens disponíveis em:" -ForegroundColor Cyan
    foreach ($service in $services) {
        Write-Host "   - $DockerUsername/agrosolution-$($service.name):$Version" -ForegroundColor Cyan
        Write-Host "   - $DockerUsername/agrosolution-$($service.name):latest" -ForegroundColor Cyan
    }
} else {
    Write-Host "✅ Todas as imagens foram buildadas localmente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Para fazer push para Docker Hub, use:" -ForegroundColor Yellow
    Write-Host "   .\docker-build-push.ps1 -DockerUsername '$DockerUsername' -Version '$Version' -Push" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Magenta
