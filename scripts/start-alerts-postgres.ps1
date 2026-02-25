# Script para iniciar PostgreSQL do Alerts Service
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Iniciando PostgreSQL para Alerts Service..." -ForegroundColor Cyan

$containerName = "agro-alerts-db"
$existingContainer = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if ($existingContainer -eq $containerName) {
    Write-Host "`n[!] Container ja existe. Iniciando..." -ForegroundColor Yellow
    docker start $containerName
} else {
    Write-Host "`n[+] Criando novo container..." -ForegroundColor Green
    docker run --name $containerName `
        -e POSTGRES_PASSWORD=alerts_pass_123 `
        -e POSTGRES_USER=alerts_user `
        -e POSTGRES_DB=alerts_db `
        -p 5436:5432 `
        -d postgres:15-alpine
}

Write-Host "`n[OK] PostgreSQL rodando!" -ForegroundColor Green
Write-Host "    Host: localhost" -ForegroundColor Cyan
Write-Host "    Port: 5436" -ForegroundColor Cyan
Write-Host "    Database: alerts_db" -ForegroundColor Cyan
Write-Host "    User: alerts_user" -ForegroundColor Cyan
Write-Host "`n[i] Para parar: docker stop $containerName" -ForegroundColor Yellow
Write-Host "[i] Para remover: docker rm $containerName" -ForegroundColor Yellow
Write-Host ""
