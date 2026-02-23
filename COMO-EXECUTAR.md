# GUIA RAPIDO - Como Executar

## PROBLEMA RESOLVIDO
Todos os scripts foram corrigidos para remover emojis que causavam erros de encoding.

## OPCAO 1: Setup Completo (Primeira vez)

```powershell
# No diretorio raiz (C:\Users\Daniel Pontes\source\repos\AgroSolution\)
.\scripts\setup-identity-service.ps1
```

Depois execute a API:
```powershell
cd src\Services\Identity\AgroSolutions.Identity.Api
dotnet run
```

## OPCAO 2: Quick Start (Mais Rapido)

```powershell
# Inicia PostgreSQL + Migrations + API tudo de uma vez
.\scripts\quick-start.ps1
```

## OPCAO 3: Passo a Passo Manual

```powershell
# 1. Iniciar PostgreSQL
.\scripts\start-identity-postgres.ps1

# 2. Aguardar 5 segundos

# 3. Aplicar migrations (primeira vez)
.\scripts\update-identity-database.ps1

# 4. Executar API
cd src\Services\Identity\AgroSolutions.Identity.Api
dotnet run
```

## Testar a API

### Via Swagger (Recomendado)
1. Abra: http://localhost:5001
2. Teste os endpoints interativamente

### Via Script Automatizado
```powershell
# Em outro terminal (com a API rodando)
.\scripts\test-identity-api.ps1
```

### Via HTTP File (Visual Studio)
1. Abra: AgroSolutions.Identity.Api.http
2. Clique em "Send Request" nos endpoints

## Scripts Disponiveis

- `setup-identity-service.ps1` - Setup completo
- `quick-start.ps1` - Inicia tudo de uma vez
- `start-identity-postgres.ps1` - Apenas PostgreSQL
- `create-identity-migration.ps1` - Criar migration
- `update-identity-database.ps1` - Aplicar migration
- `test-identity-api.ps1` - Testar todos os endpoints

## Comandos Uteis

```powershell
# Ver containers rodando
docker ps

# Parar PostgreSQL
docker stop agro-identity-db

# Remover PostgreSQL
docker rm agro-identity-db

# Limpar tudo e comecar de novo
docker rm -f agro-identity-db
.\scripts\setup-identity-service.ps1
```

## Troubleshooting

### Erro de encoding
- RESOLVIDO: Todos os scripts foram atualizados

### Docker nao esta rodando
```powershell
# Abra o Docker Desktop
# Aguarde inicializar
docker ps
```

### Porta 5001 em uso
```powershell
netstat -ano | findstr :5001
taskkill /PID <PID> /F
```

### Migrations nao aplicadas
```powershell
cd src\Services\Identity\AgroSolutions.Identity.Api
dotnet ef database update
```
