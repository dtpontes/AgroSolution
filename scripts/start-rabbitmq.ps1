# Script para iniciar RabbitMQ
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Iniciando RabbitMQ..." -ForegroundColor Cyan

$containerName = "agro-rabbitmq"
$existingContainer = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if ($existingContainer -eq $containerName) {
    Write-Host "`n[!] Container ja existe. Iniciando..." -ForegroundColor Yellow
    docker start $containerName
} else {
    Write-Host "`n[+] Criando novo container..." -ForegroundColor Green
    docker run --name $containerName `
        -p 5672:5672 `
        -p 15672:15672 `
        -d rabbitmq:3-management-alpine
}

Write-Host "`n[OK] RabbitMQ rodando!" -ForegroundColor Green
Write-Host "    Host: localhost" -ForegroundColor Cyan
Write-Host "    Port: 5672 (AMQP)" -ForegroundColor Cyan
Write-Host "    Port: 15672 (Management UI)" -ForegroundColor Cyan
Write-Host "`n[i] Management UI: http://localhost:15672" -ForegroundColor Yellow
Write-Host "[i] Usuario: guest / Senha: guest" -ForegroundColor Yellow
Write-Host "`n[i] Para parar: docker stop $containerName" -ForegroundColor Yellow
Write-Host "[i] Para remover: docker rm $containerName" -ForegroundColor Yellow
Write-Host ""
