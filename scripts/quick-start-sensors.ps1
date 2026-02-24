# Quick Start - Sensors API
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Join-Path $PSScriptRoot ".." | Resolve-Path

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "   AgroSolutions Sensors API - Quick Start                " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

$ErrorActionPreference = "Stop"

# Verificar Docker
Write-Host "`n[1/4] Verificando Docker..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    Write-Host "[OK] Docker rodando" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker nao esta rodando. Inicie o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Iniciar PostgreSQL
Write-Host "`n[2/4] Iniciando PostgreSQL..." -ForegroundColor Cyan
$containerName = "agro-sensors-db"
$existingContainer = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if ($existingContainer -eq $containerName) {
    docker start $containerName | Out-Null
    Write-Host "[OK] Container iniciado" -ForegroundColor Green
} else {
    docker run --name $containerName `
        -e POSTGRES_PASSWORD=sensors_pass_123 `
        -e POSTGRES_USER=sensors_user `
        -e POSTGRES_DB=sensors_db `
        -p 5435:5432 `
        -d postgres:15-alpine | Out-Null
    Write-Host "[OK] Container criado" -ForegroundColor Green
    Start-Sleep -Seconds 5
}

# Aplicar migrations
Write-Host "`n[3/4] Aplicando migrations..." -ForegroundColor Cyan
Set-Location (Join-Path $repoRoot "src\Services\Sensors\AgroSolutions.Sensors.Api")
try {
    dotnet ef database update --context SensorsDbContext 2>&1 | Out-Null
    Write-Host "[OK] Database atualizado" -ForegroundColor Green
} catch {
    Write-Host "[!] Erro ao aplicar migrations (pode ja estar aplicado)" -ForegroundColor Yellow
}
Set-Location $repoRoot

# Iniciar API
Write-Host "`n[4/4] Iniciando API..." -ForegroundColor Cyan
Write-Host "`n===========================================================" -ForegroundColor Green
Write-Host "   API sera iniciada agora...                             " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green
Write-Host "`n[i] Swagger: http://localhost:5003" -ForegroundColor Yellow
Write-Host "[i] Pressione Ctrl+C para parar" -ForegroundColor Yellow
Write-Host ""

Set-Location (Join-Path $repoRoot "src\Services\Sensors\AgroSolutions.Sensors.Api")
dotnet run
