# AgroSolutions Alerts API

Servico de alertas e status de talhoes para a plataforma AgroSolutions.

## Tecnologias

- .NET 9
- PostgreSQL
- Entity Framework Core
- JWT Bearer
- Swagger/OpenAPI
- BackgroundService

## Bancos de Dados

- Alerts DB: localhost:5436 (alerts_db)
- Sensors DB: localhost:5435 (sensors_db)

## Quick Start

```powershell
.\scripts\quick-start-alerts.ps1
```

Swagger:
```
http://localhost:5004
```

## Scripts

```powershell
# Iniciar PostgreSQL (alerts_db)
.\scripts\start-alerts-postgres.ps1

# Criar migration
.\scripts\create-alerts-migration.ps1

# Aplicar migration
.\scripts\update-alerts-database.ps1
```

## Endpoints

- `GET /api/alerts/talhoes/{id}/status` (JWT)
- `GET /api/alerts/talhoes/{id}/dashboard` (JWT)
- `GET /health`

## Autenticacao

Use token JWT do `AgroSolutions.Identity.Api`:

```
Authorization: Bearer <seu_token>
```

## Processamento de Alertas

O worker executa a cada 5 minutos e gera alertas para:

- Umidade abaixo de 30% por 24h -> Alerta de Seca
- Temperatura acima de 35°C -> Alerta de Temperatura
- Precipitacao acima de 50mm/24h -> Alerta de Chuva

Alertas sao resolvidos automaticamente quando a condicao nao ocorre mais.
