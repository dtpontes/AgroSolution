# AgroSolutions Sensors API

API de ingestao de dados de sensores para a plataforma AgroSolutions.

## Tecnologias

- .NET 9
- PostgreSQL
- Entity Framework Core
- JWT Bearer
- Swagger/OpenAPI

## Pre-requisitos

- .NET 9 SDK
- Docker Desktop
- EF Core Tools: `dotnet tool install --global dotnet-ef`

## Banco de Dados

- Host: localhost
- Porta: 5435
- Database: sensors_db
- User: sensors_user
- Password: sensors_pass_123

## Quick Start

```powershell
.\scripts\quick-start-sensors.ps1
```

Swagger:
```
http://localhost:5003
```

## Scripts

```powershell
# Iniciar PostgreSQL
.\scripts\start-sensors-postgres.ps1

# Criar migration
.\scripts\create-sensors-migration.ps1

# Aplicar migration
.\scripts\update-sensors-database.ps1
```

## Executar manualmente

```powershell
# 1) Iniciar PostgreSQL
.\scripts\start-sensors-postgres.ps1

# 2) Aplicar migrations
cd src\Services\Sensors\AgroSolutions.Sensors.Api
dotnet ef database update --context SensorsDbContext

# 3) Executar API
dotnet run
```

## Endpoints

- `POST /api/sensors/ingest` (JWT)
- `GET /api/sensors/talhao/{talhaoId}` (JWT)
- `GET /health`

## Autenticacao

Use token JWT gerado pelo `AgroSolutions.Identity.Api`:

```
Authorization: Bearer <seu_token>
```

## Testes

Use o arquivo `AgroSolutions.Sensors.Api.http` no Visual Studio.
