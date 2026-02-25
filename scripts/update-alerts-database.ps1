# Script para aplicar migrations do Alerts Service
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Aplicando Migration para Alerts Database..." -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$repoRoot = Join-Path $PSScriptRoot ".." | Resolve-Path

try {
    Set-Location (Join-Path $repoRoot "src\Services\Alerts\AgroSolutions.Alerts.Worker")
    Write-Host "`n[+] Aplicando migrations no banco de dados..." -ForegroundColor Yellow
    dotnet ef database update --context AlertsDbContext
    Write-Host "`n[OK] Database atualizado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "`n[X] Erro ao aplicar migration: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n[i] Certifique-se de que o PostgreSQL esta rodando na porta 5436" -ForegroundColor Yellow
    exit 1
} finally {
    Set-Location $repoRoot
}
