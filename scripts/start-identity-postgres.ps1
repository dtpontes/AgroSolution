# Script para iniciar PostgreSQL do Identity Service
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Iniciando PostgreSQL para Identity Service..." -ForegroundColor Cyan

$containerName = "agro-identity-db"
$existingContainer = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if ($existingContainer -eq $containerName) {
    Write-Host "`n[!] Container ja existe. Iniciando..." -ForegroundColor Yellow
    docker start $containerName
} else {
    Write-Host "`n[+] Criando novo container..." -ForegroundColor Green
    docker run --name $containerName `
        -e POSTGRES_PASSWORD=identity_pass_123 `
        -e POSTGRES_USER=identity_user `
        -e POSTGRES_DB=identity_db `
        -p 5433:5432 `
        -d postgres:15-alpine
}

Write-Host "`n[OK] PostgreSQL rodando!" -ForegroundColor Green
Write-Host "    Host: localhost" -ForegroundColor Cyan
Write-Host "    Port: 5433" -ForegroundColor Cyan
Write-Host "    Database: identity_db" -ForegroundColor Cyan
Write-Host "    User: identity_user" -ForegroundColor Cyan
Write-Host "`n[i] Para parar: docker stop $containerName" -ForegroundColor Yellow
Write-Host "[i] Para remover: docker rm $containerName" -ForegroundColor Yellow
Write-Host ""
