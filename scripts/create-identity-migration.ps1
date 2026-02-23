# Script para criar migrations do Identity Service
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Criando Migration para Identity Service..." -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

try {
    # Navegar para o diretorio do projeto
    Set-Location "src/Services/Identity/AgroSolutions.Identity.Api"
    
    # Criar migration
    Write-Host "`n[+] Criando migration 'InitialCreate'..." -ForegroundColor Yellow
    dotnet ef migrations add InitialCreate --context IdentityDbContext
    
    Write-Host "`n[OK] Migration criada com sucesso!" -ForegroundColor Green
    Write-Host "`n[i] Para aplicar a migration, execute: dotnet ef database update" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n[X] Erro ao criar migration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Voltar para o diretorio raiz
    Set-Location "../../../.."
}
