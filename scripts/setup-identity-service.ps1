# Script completo para setup do Identity Service
# Encoding UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "   AgroSolutions Identity API - Setup Completo            " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

$ErrorActionPreference = "Stop"

# Funcao para verificar se o Docker esta rodando
function Test-Docker {
    try {
        docker ps | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Verificar Docker
Write-Host "`n[1] Verificando Docker..." -ForegroundColor Cyan
if (-not (Test-Docker)) {
    Write-Host "[X] Docker nao esta rodando. Inicie o Docker Desktop e tente novamente." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker funcionando" -ForegroundColor Green

# Iniciar PostgreSQL
Write-Host "`n[2] Iniciando PostgreSQL..." -ForegroundColor Cyan
& "$PSScriptRoot\start-identity-postgres.ps1"

# Aguardar PostgreSQL inicializar
Write-Host "`n[*] Aguardando PostgreSQL inicializar (10 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Restaurar pacotes
Write-Host "`n[3] Restaurando pacotes NuGet..." -ForegroundColor Cyan
Set-Location "src/Services/Identity/AgroSolutions.Identity.Api"
dotnet restore
Write-Host "[OK] Pacotes restaurados" -ForegroundColor Green

# Criar migrations
Write-Host "`n[4] Criando migrations..." -ForegroundColor Cyan
try {
    dotnet ef migrations add InitialCreate --context IdentityDbContext 2>&1 | Out-Null
    Write-Host "[OK] Migrations criadas" -ForegroundColor Green
} catch {
    Write-Host "[!] Migrations ja existem ou erro ao criar" -ForegroundColor Yellow
}

# Aplicar migrations
Write-Host "`n[5] Aplicando migrations no banco..." -ForegroundColor Cyan
$retries = 3
$retryCount = 0
$success = $false

while ($retryCount -lt $retries -and -not $success) {
    try {
        dotnet ef database update --context IdentityDbContext
        $success = $true
        Write-Host "[OK] Database atualizado" -ForegroundColor Green
    } catch {
        $retryCount++
        if ($retryCount -lt $retries) {
            Write-Host "[!] Tentativa $retryCount falhou. Tentando novamente em 5 segundos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        } else {
            Write-Host "[X] Falha ao aplicar migrations apos $retries tentativas" -ForegroundColor Red
            Set-Location "../../../.."
            exit 1
        }
    }
}

# Compilar projeto
Write-Host "`n[6] Compilando projeto..." -ForegroundColor Cyan
dotnet build --configuration Release
Write-Host "[OK] Projeto compilado" -ForegroundColor Green

Set-Location "../../../.."

# Resumo
Write-Host "`n===========================================================" -ForegroundColor Green
Write-Host "   Setup concluido com sucesso!                           " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

Write-Host "`nPROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Executar API:" -ForegroundColor White
Write-Host "   cd src\Services\Identity\AgroSolutions.Identity.Api" -ForegroundColor Yellow
Write-Host "   dotnet run" -ForegroundColor Yellow

Write-Host "`n2. Acessar Swagger:" -ForegroundColor White
Write-Host "   http://localhost:5001" -ForegroundColor Yellow

Write-Host "`n3. Testar endpoints:" -ForegroundColor White
Write-Host "   Use o arquivo AgroSolutions.Identity.Api.http no Visual Studio" -ForegroundColor Yellow

Write-Host "`nBANCO DE DADOS:" -ForegroundColor Cyan
Write-Host "   Host: localhost:5433" -ForegroundColor White
Write-Host "   Database: identity_db" -ForegroundColor White
Write-Host "   User: identity_user" -ForegroundColor White
Write-Host "   Password: identity_pass_123" -ForegroundColor White
Write-Host ""
