# Script para criar migrations do Sensors Service
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Criando Migration para Sensors Service..." -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$repoRoot = Join-Path $PSScriptRoot ".." | Resolve-Path

try {
    Set-Location (Join-Path $repoRoot "src\Services\Sensors\AgroSolutions.Sensors.Api")
    Write-Host "`n[+] Criando migration 'InitialCreate'..." -ForegroundColor Yellow
    dotnet ef migrations add InitialCreate --context SensorsDbContext
    Write-Host "`n[OK] Migration criada com sucesso!" -ForegroundColor Green
    Write-Host "`n[i] Para aplicar a migration, execute: dotnet ef database update" -ForegroundColor Cyan
} catch {
    Write-Host "`n[X] Erro ao criar migration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Set-Location $repoRoot
}
