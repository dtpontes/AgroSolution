# Stop All - Para e remove todos os servicos
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "===========================================================" -ForegroundColor Red
Write-Host "   AgroSolutions - Stop All (Limpeza Completa)            " -ForegroundColor Red
Write-Host "===========================================================" -ForegroundColor Red

$ErrorActionPreference = "Continue"

# Parar containers
Write-Host "`n[1/2] Parando containers Docker..." -ForegroundColor Cyan

$containers = @(
    "agro-identity-db",
    "agro-properties-db",
    "agro-sensors-db",
    "agro-alerts-db",
    "agro-rabbitmq"
)

foreach ($container in $containers) {
    $exists = docker ps -a --filter "name=$container" --format "{{.Names}}"
    if ($exists -eq $container) {
        Write-Host "[*] Parando $container..." -ForegroundColor Yellow
        docker stop $container | Out-Null
        Write-Host "[OK] $container parado" -ForegroundColor Green
    } else {
        Write-Host "[!] $container nao encontrado" -ForegroundColor Gray
    }
}

# Remover containers
Write-Host "`n[2/2] Removendo containers..." -ForegroundColor Cyan

foreach ($container in $containers) {
    $exists = docker ps -a --filter "name=$container" --format "{{.Names}}"
    if ($exists -eq $container) {
        Write-Host "[*] Removendo $container..." -ForegroundColor Yellow
        docker rm $container | Out-Null
        Write-Host "[OK] $container removido" -ForegroundColor Green
    }
}

Write-Host "`n===========================================================" -ForegroundColor Green
Write-Host "   Limpeza concluida!                                     " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

Write-Host "`n[i] Containers removidos:" -ForegroundColor Yellow
Write-Host "    - agro-identity-db (PostgreSQL - porta 5433)" -ForegroundColor Gray
Write-Host "    - agro-properties-db (PostgreSQL - porta 5434)" -ForegroundColor Gray
Write-Host "    - agro-sensors-db (PostgreSQL - porta 5435)" -ForegroundColor Gray
Write-Host "    - agro-alerts-db (PostgreSQL - porta 5436)" -ForegroundColor Gray
Write-Host "    - agro-rabbitmq (RabbitMQ - portas 5672, 15672)" -ForegroundColor Gray

Write-Host "`n[i] As APIs precisam ser paradas manualmente:" -ForegroundColor Yellow
Write-Host "    - Feche as janelas do PowerShell das APIs" -ForegroundColor Gray
Write-Host "    - Ou pressione Ctrl+C em cada terminal" -ForegroundColor Gray
Write-Host ""
