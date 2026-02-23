# Test Script para Identity API
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseUrl = "http://localhost:5001"

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "   Testando AgroSolutions Identity API                    " -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# 1. Health Check
Write-Host "`n[1] Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get
    Write-Host "[OK] API esta saudavel!" -ForegroundColor Green
    $health | ConvertTo-Json | Write-Host -ForegroundColor Gray
} catch {
    Write-Host "[X] API nao esta respondendo" -ForegroundColor Red
    Write-Host "[i] Certifique-se de que a API esta rodando em $baseUrl" -ForegroundColor Yellow
    exit 1
}

# 2. Registrar usuario
Write-Host "`n[2] Registrando novo usuario..." -ForegroundColor Yellow
$email = "teste.$(Get-Random)@email.com"
$registerBody = @{
    nome = "Usuario Teste"
    email = $email
    password = "senha123"
    telefone = "(11) 98765-4321"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" `
        -Method Post `
        -ContentType "application/json" `
        -Body $registerBody
    
    Write-Host "[OK] Usuario registrado com sucesso!" -ForegroundColor Green
    Write-Host "    ID: $($registerResponse.id)" -ForegroundColor Gray
    Write-Host "    Nome: $($registerResponse.nome)" -ForegroundColor Gray
    Write-Host "    Email: $($registerResponse.email)" -ForegroundColor Gray
    
    $token = $registerResponse.token
    Write-Host "    Token: $($token.Substring(0, 50))..." -ForegroundColor Gray
} catch {
    Write-Host "[X] Erro ao registrar usuario" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 3. Testar endpoint autenticado
Write-Host "`n[3] Buscando dados do usuario autenticado..." -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $token"
}

try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/me" `
        -Method Get `
        -Headers $headers

    Write-Host "[OK] Dados do usuario obtidos:" -ForegroundColor Green
    $userResponse | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
} catch {
    Write-Host "[X] Erro ao buscar dados do usuario" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 4. Testar login
Write-Host "`n[4] Testando login..." -ForegroundColor Yellow
$loginBody = @{
    email = $email
    password = "senha123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "[OK] Login bem-sucedido!" -ForegroundColor Green
    Write-Host "    Token valido ate: $($loginResponse.expiresAt)" -ForegroundColor Gray
} catch {
    Write-Host "[X] Erro ao fazer login" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 5. Testar validacao de email duplicado
Write-Host "`n[5] Testando validacao de email duplicado..." -ForegroundColor Yellow
try {
    $duplicateResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" `
        -Method Post `
        -ContentType "application/json" `
        -Body $registerBody
    
    Write-Host "[X] ERRO: Sistema permitiu email duplicado!" -ForegroundColor Red
    exit 1
} catch {
    Write-Host "[OK] Validacao de email duplicado funcionando!" -ForegroundColor Green
}

# Resumo
Write-Host "`n===========================================================" -ForegroundColor Green
Write-Host "   Todos os testes passaram!                              " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green

Write-Host "`nResumo dos testes:" -ForegroundColor Cyan
Write-Host "  [OK] Health Check" -ForegroundColor White
Write-Host "  [OK] Registro de usuario" -ForegroundColor White
Write-Host "  [OK] Autenticacao JWT" -ForegroundColor White
Write-Host "  [OK] Endpoint autenticado" -ForegroundColor White
Write-Host "  [OK] Login" -ForegroundColor White
Write-Host "  [OK] Validacao de email duplicado" -ForegroundColor White
Write-Host ""
