# Script para aplicar migrations do Identity Service
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Aplicando Migration para Identity Database..." -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

try {
    # Navegar para o diretorio do projeto
    Set-Location "src/Services/Identity/AgroSolutions.Identity.Api"
    
    # Aplicar migration
    Write-Host "`n[+] Aplicando migrations no banco de dados..." -ForegroundColor Yellow
    dotnet ef database update --context IdentityDbContext
    
    Write-Host "`n[OK] Database atualizado com sucesso!" -ForegroundColor Green
    
} catch {
    Write-Host "`n[X] Erro ao aplicar migration: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n[i] Certifique-se de que o PostgreSQL esta rodando na porta 5433" -ForegroundColor Yellow
    exit 1
} finally {
    # Voltar para o diretorio raiz
    Set-Location "../../../.."
}
