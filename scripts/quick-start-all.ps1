# Quick Start - Todos os servicos
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Join-Path $PSScriptRoot ".." | Resolve-Path

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "   AgroSolutions - Quick Start (Todos os Servicos)         " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

$ErrorActionPreference = "Stop"

function Ensure-DockerImage($imageName) {
    Write-Host "[*] Verificando imagem: $imageName..." -ForegroundColor Yellow
    $imageExists = docker images -q $imageName 2>$null
    
    if ($imageExists) {
        Write-Host "[OK] Imagem $imageName ja existe" -ForegroundColor Green
    } else {
        Write-Host "[*] Baixando imagem: $imageName..." -ForegroundColor Cyan
        docker pull $imageName | Out-Null
        Write-Host "[OK] Imagem $imageName baixada" -ForegroundColor Green
    }
}

function Start-Postgres($name, $db, $user, $password, $port) {
    $existing = docker ps -a --filter "name=$name" --format "{{.Names}}" 2>$null
    
    if ($existing -eq $name) {
        $running = docker ps --filter "name=$name" --format "{{.Names}}" 2>$null
        
        if ($running -eq $name) {
            Write-Host "[OK] $name ja esta rodando" -ForegroundColor Green
        } else {
            docker start $name | Out-Null
            Write-Host "[OK] $name iniciado" -ForegroundColor Green
        }
    } else {
        docker run --name $name `
            -e POSTGRES_PASSWORD=$password `
            -e POSTGRES_USER=$user `
            -e POSTGRES_DB=$db `
            -p ${port}:5432 `
            -d postgres:15-alpine | Out-Null
        Write-Host "[OK] $name criado e iniciado" -ForegroundColor Green
    }
}

function Start-Service($projectPath, $port, $name) {
    $cmd = "cd '$projectPath'; `$env:ASPNETCORE_HTTP_PORTS='$port'; dotnet run"
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", $cmd | Out-Null
    Write-Host "[OK] $name iniciado na porta $port (migrations automaticas)" -ForegroundColor Green
}

# Verificar Docker
Write-Host "`n[1/6] Verificando Docker..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    Write-Host "[OK] Docker rodando" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker nao esta rodando. Inicie o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Verificar e baixar imagens necessarias
Write-Host "`n[2/6] Verificando imagens Docker..." -ForegroundColor Cyan
Ensure-DockerImage "postgres:15-alpine"
Ensure-DockerImage "rabbitmq:3-management-alpine"

# Iniciar RabbitMQ
Write-Host "`n[3/6] Iniciando RabbitMQ..." -ForegroundColor Cyan
$rabbitContainer = docker ps -a --filter "name=agro-rabbitmq" --format "{{.Names}}" 2>$null

if ($rabbitContainer -eq "agro-rabbitmq") {
    $rabbitRunning = docker ps --filter "name=agro-rabbitmq" --format "{{.Names}}" 2>$null
    
    if ($rabbitRunning -eq "agro-rabbitmq") {
        Write-Host "[OK] RabbitMQ ja esta rodando" -ForegroundColor Green
    } else {
        docker start agro-rabbitmq | Out-Null
        Write-Host "[OK] RabbitMQ iniciado" -ForegroundColor Green
    }
} else {
    docker run --name agro-rabbitmq `
        -p 5672:5672 `
        -p 15672:15672 `
        -d rabbitmq:3-management-alpine | Out-Null
    Write-Host "[OK] RabbitMQ criado e iniciado" -ForegroundColor Green
}

# Iniciar bancos
Write-Host "`n[4/6] Iniciando bancos PostgreSQL..." -ForegroundColor Cyan
Start-Postgres "agro-identity-db" "identity_db" "identity_user" "identity_pass_123" "5433"
Start-Postgres "agro-properties-db" "properties_db" "properties_user" "properties_pass_123" "5434"
Start-Postgres "agro-sensors-db" "sensors_db" "sensors_user" "sensors_pass_123" "5435"
Start-Postgres "agro-alerts-db" "alerts_db" "alerts_user" "alerts_pass_123" "5436"

Write-Host "`n[*] Aguardando bancos ficarem prontos (20 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Iniciar servicos (migrations serao aplicadas automaticamente ao iniciar)
Write-Host "`n[5/6] Iniciando APIs (migrations automaticas)..." -ForegroundColor Cyan
Write-Host "[i] Cada API aplicara suas migrations ao iniciar" -ForegroundColor Yellow

Start-Service (Join-Path $repoRoot "src\Services\Identity\AgroSolutions.Identity.Api") 5001 "Identity API"
Start-Sleep -Seconds 5

Start-Service (Join-Path $repoRoot "src\Services\Properties\AgroSolutions.Properties.Api") 5002 "Properties API"
Start-Sleep -Seconds 5

Start-Service (Join-Path $repoRoot "src\Services\Sensors\AgroSolutions.Sensors.Api") 5003 "Sensors API"
Start-Sleep -Seconds 5

Start-Service (Join-Path $repoRoot "src\Services\Alerts\AgroSolutions.Alerts.API") 5004 "Alerts API"

Write-Host "`n[6/6] Pronto!" -ForegroundColor Cyan
Write-Host "`n[i] Aguarde ~30s para todas as migrations serem aplicadas automaticamente" -ForegroundColor Yellow
Write-Host "`nSwagger:" -ForegroundColor Yellow
Write-Host " - Identity:   http://localhost:5001" -ForegroundColor Yellow
Write-Host " - Properties: http://localhost:5002" -ForegroundColor Yellow
Write-Host " - Sensors:    http://localhost:5003" -ForegroundColor Yellow
Write-Host " - Alerts:     http://localhost:5004" -ForegroundColor Yellow
Write-Host "`nRabbitMQ Management:" -ForegroundColor Yellow
Write-Host " - UI: http://localhost:15672 (guest/guest)" -ForegroundColor Yellow
Write-Host "`nContainers:" -ForegroundColor Yellow
Write-Host " - docker ps (para ver todos rodando)" -ForegroundColor Cyan
Write-Host ""
