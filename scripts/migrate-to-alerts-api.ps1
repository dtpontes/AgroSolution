# Migrar de Alerts.Worker para Alerts.API
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "   Migracao: Alerts.Worker -> Alerts.API                  " -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

Write-Host "`n[1/3] Removendo Alerts.Worker da solucao..." -ForegroundColor Yellow
dotnet sln AgroSolution.sln remove src/Services/Alerts/AgroSolutions.Alerts.Worker/AgroSolutions.Alerts.Worker.csproj

Write-Host "`n[2/3] Adicionando Alerts.API na solucao..." -ForegroundColor Yellow
dotnet sln AgroSolution.sln add src/Services/Alerts/AgroSolutions.Alerts.API/AgroSolutions.Alerts.API.csproj

Write-Host "`n[3/3] Removendo diretorio do Alerts.Worker (OPCIONAL)..." -ForegroundColor Yellow
Write-Host "[!] ATENCAO: Isso deletara o diretorio completo do Alerts.Worker" -ForegroundColor Red
$confirmation = Read-Host "Deseja continuar? (S/N)"
if ($confirmation -eq 'S' -or $confirmation -eq 's') {
    Remove-Item -Path "src/Services/Alerts/AgroSolutions.Alerts.Worker" -Recurse -Force
    Write-Host "[OK] Diretorio removido" -ForegroundColor Green
} else {
    Write-Host "[!] Diretorio mantido (voce pode deletar manualmente depois)" -ForegroundColor Yellow
}

Write-Host "`n[OK] Migracao concluida!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "1. Executar: .\scripts\reset-databases.ps1" -ForegroundColor White
Write-Host "2. Executar: .\scripts\quick-start-all.ps1" -ForegroundColor White
Write-Host ""
