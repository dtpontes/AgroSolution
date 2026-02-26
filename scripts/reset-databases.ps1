# Reset Databases - Remove todos os containers PostgreSQL
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "===========================================================" -ForegroundColor Red
Write-Host "   AgroSolutions - Reset Databases                        " -ForegroundColor Red
Write-Host "===========================================================" -ForegroundColor Red
Write-Host ""
Write-Host "[!] ATENCAO: Este script ira DELETAR todos os dados!" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Deseja continuar? (S/N)"
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "[X] Operacao cancelada" -ForegroundColor Yellow
    exit 0
}

$ErrorActionPreference = "Continue"

Write-Host "`n[1/3] Parando containers PostgreSQL..." -ForegroundColor Cyan
docker stop agro-identity-db agro-properties-db agro-sensors-db agro-alerts-db 2>$null

Write-Host "`n[2/3] Removendo containers PostgreSQL..." -ForegroundColor Cyan
docker rm -f agro-identity-db agro-properties-db agro-sensors-db agro-alerts-db 2>$null

Write-Host "`n[3/3] Removendo RabbitMQ..." -ForegroundColor Cyan
docker stop agro-rabbitmq 2>$null
docker rm -f agro-rabbitmq 2>$null

Write-Host "`n[OK] Todas as bases de dados foram removidas!" -ForegroundColor Green
Write-Host ""
Write-Host "Para recriar tudo do zero, execute:" -ForegroundColor Yellow
Write-Host "  .\scripts\quick-start-all.ps1" -ForegroundColor Cyan
Write-Host ""
