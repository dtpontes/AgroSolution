# Quick Start - Todos os servicos
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Join-Path $PSScriptRoot ".." | Resolve-Path

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "   AgroSolutions - Quick Start (Todos os Servicos)         " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

$ErrorActionPreference = "Stop"

function Start-Postgres($name, $db, $user, $password, $port) {
    $existing = docker ps -a --filter "name=$name" --format "{{.Names}}"
    if ($existing -eq $name) {
        docker start $name | Out-Null
        Write-Host "[OK] $name iniciado" -ForegroundColor Green
    } else {
        docker run --name $name `
            -e POSTGRES_PASSWORD=$password `
            -e POSTGRES_USER=$user `
            -e POSTGRES_DB=$db `
            -p "$port:5432" `
            -d postgres:15-alpine | Out-Null
        Write-Host "[OK] $name criado" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
}

function Apply-Migration($projectPath, $context) {
    Set-Location $projectPath
    try {
        dotnet ef database update --context $context 2>&1 | Out-Null
        Write-Host "[OK] Migrations aplicadas: $context" -ForegroundColor Green
    } catch {
        Write-Host "[!] Falha ao aplicar migrations: $context" -ForegroundColor Yellow
    }
}

function Start-Service($projectPath, $port, $name) {
    $cmd = "cd '$projectPath'; `$env:ASPNETCORE_HTTP_PORTS='$port'; dotnet run"
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", $cmd | Out-Null
    Write-Host "[OK] $name iniciado na porta $port" -ForegroundColor Green
}

# Verificar Docker
Write-Host "`n[1/5] Verificando Docker..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    Write-Host "[OK] Docker rodando" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker nao esta rodando. Inicie o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Iniciar bancos
Write-Host "`n[2/5] Iniciando bancos..." -ForegroundColor Cyan
Start-Postgres "agro-identity-db" "identity_db" "identity_user" "identity_pass_123" 5433
Start-Postgres "agro-properties-db" "properties_db" "properties_user" "properties_pass_123" 5434
Start-Postgres "agro-sensors-db" "sensors_db" "sensors_user" "sensors_pass_123" 5435
Start-Postgres "agro-alerts-db" "alerts_db" "alerts_user" "alerts_pass_123" 5436

# Migrations
Write-Host "`n[3/5] Aplicando migrations..." -ForegroundColor Cyan
Apply-Migration (Join-Path $repoRoot "src\Services\Identity\AgroSolutions.Identity.Api") "IdentityDbContext"
Apply-Migration (Join-Path $repoRoot "src\Services\Properties\AgroSolutions.Properties.Api") "PropertiesDbContext"
Apply-Migration (Join-Path $repoRoot "src\Services\Sensors\AgroSolutions.Sensors.Api") "SensorsDbContext"
Apply-Migration (Join-Path $repoRoot "src\Services\Alerts\AgroSolutions.Alerts.Worker") "AlertsDbContext"
Set-Location $repoRoot

# Iniciar servicos
Write-Host "`n[4/5] Iniciando APIs..." -ForegroundColor Cyan
Start-Service (Join-Path $repoRoot "src\Services\Identity\AgroSolutions.Identity.Api") 5001 "Identity API"
Start-Service (Join-Path $repoRoot "src\Services\Properties\AgroSolutions.Properties.Api") 5002 "Properties API"
Start-Service (Join-Path $repoRoot "src\Services\Sensors\AgroSolutions.Sensors.Api") 5003 "Sensors API"
Start-Service (Join-Path $repoRoot "src\Services\Alerts\AgroSolutions.Alerts.Worker") 5004 "Alerts API"

Write-Host "`n[5/5] Pronto" -ForegroundColor Cyan
Write-Host "Swagger:" -ForegroundColor Yellow
Write-Host " - Identity:   http://localhost:5001" -ForegroundColor Yellow
Write-Host " - Properties: http://localhost:5002" -ForegroundColor Yellow
Write-Host " - Sensors:    http://localhost:5003" -ForegroundColor Yellow
Write-Host " - Alerts:     http://localhost:5004" -ForegroundColor Yellow
Write-Host ""
