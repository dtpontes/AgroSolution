# 🌾 AgroSolutions - Plataforma de Agricultura de Precisão

[![.NET 9](https://img.shields.io/badge/.NET-9.0-512BD4)](https://dotnet.microsoft.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)](https://www.postgresql.org/)
[![RabbitMQ](https://img.shields.io/badge/RabbitMQ-3-FF6600)](https://www.rabbitmq.com/)

Plataforma de IoT e análise de dados para agricultura de precisão desenvolvida para a cooperativa AgroSolutions.

## 📋 Sobre o Projeto

A AgroSolutions implementa conceitos de **Agricultura 4.0** através de:
- 🌡️ Monitoramento em tempo real de sensores de campo
- 📊 Análise de dados de umidade, temperatura e precipitação
- ⚠️ Sistema de alertas automáticos
- 📱 Dashboard para visualização de dados históricos

### Funcionalidades

- Autenticação de Usuário (Produtor Rural)
- Cadastro de Propriedade e Talhões
- Ingestão de Dados de Sensores (via API)
- Dashboard de Monitoramento
- Motor de Alertas

## 🏗️ Arquitetura

### Microserviços

```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Identity API  │   │ Properties API│   │ Sensors API   │   │ Alerts API    │
│   :8081       │   │   :8082       │   │   :8083       │   │   :8084       │
└─────┬─────────┘   └─────┬─────────┘   └─────┬─────────┘   └─────┬─────────┘
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ identity_db   │   │ properties_db │   │ sensors_db    │   │ alerts_db     │
│ PostgreSQL    │   │ PostgreSQL    │   │ PostgreSQL    │   │ PostgreSQL    │
└───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘
                                              │                   │
                                              ▼                   ▼
                        ┌───────────────────────────────────────────────────┐
                        │                  RabbitMQ (mensageria)            │
                        └───────────────────────────────────────────────────┘
```

### Tecnologias

- **Backend:** .NET 9 (C# 13)
- **Banco de Dados:** PostgreSQL 15 (1 banco por serviço)
- **Message Broker:** RabbitMQ
- **Autenticação:** JWT Bearer Token
- **ORM:** Entity Framework Core 9
- **Documentação:** Swagger/OpenAPI
- **Containerização:** Docker
- **Orquestração:** Docker Compose
- **Observabilidade:** Prometheus + Grafana

## 🚀 Como rodar toda a solução

1. **Pré-requisitos:**
   - Docker e Docker Compose instalados
   - .NET 9 SDK (apenas se for rodar/testar fora do Docker)

2. **Subir toda a stack:**
   ```bash
   docker-compose up -d --build
   ```
   Isso irá:
   - Buildar as imagens das APIs
   - Subir bancos, RabbitMQ, Prometheus e Grafana

3. **Parar tudo:**
   ```bash
   docker-compose down
   ```

## 🌐 URLs dos Serviços

| Serviço         | URL/localhost         | Observações                  |
|----------------|----------------------|------------------------------|
| Identity API   | http://localhost:8081 | Swagger na raiz              |
| Properties API | http://localhost:8082 | Swagger na raiz              |
| Sensors API    | http://localhost:8083 | Swagger na raiz              |
| Alerts API     | http://localhost:8084 | Swagger na raiz              |
| RabbitMQ       | http://localhost:15672| guest/guest                  |
| Prometheus     | http://localhost:9091 | Dashboards de métricas       |
| Grafana        | http://localhost:3000 | admin/admin (primeiro acesso)|

- **Swagger:** basta acessar a raiz de cada API (ex: http://localhost:8081/)
- **Métricas Prometheus:** cada API expõe `/metrics` na porta 9090 (usado pelo Prometheus)

## 📊 Observabilidade

- **Prometheus** coleta métricas de todas as APIs automaticamente (veja `prometheus.yml`)
- **Grafana** já está configurado para conectar no Prometheus (importar dashboards .NET é opcional)
- Para criar dashboards .NET, use templates da comunidade ou importe pelo ID no Grafana

## 🐳 CI/CD com GitHub Actions + Docker Hub

- Push na branch `master` dispara build e push das imagens Docker para o Docker Hub
- Secrets necessários: `DOCKER_USERNAME` e `DOCKER_PASSWORD` (token do Docker Hub)
- Workflows principais:
  - `.github/workflows/docker-build-push.yml` (recomendado)
  - `.github/workflows/docker-build-push-advanced.yml` (opcional, com scan de segurança)

## 📦 Estrutura do Projeto

```
AgroSolution/
├── src/
│   ├── Services/
│   │   ├── Identity/AgroSolutions.Identity.Api
│   │   ├── Properties/AgroSolutions.Properties.Api
│   │   ├── Sensors/AgroSolutions.Sensors.Api
│   │   └── Alerts/AgroSolutions.Alerts.API
│   └── Shared/AgroSolutions.Shared
├── scripts/                           # Scripts PowerShell/Bash
├── docker-compose.yml                 # Orquestração completa
├── prometheus.yml                     # Configuração Prometheus
└── README.md
```

## 🔑 Serviços

### 1. Identity API
- Registro de produtores rurais
- Autenticação via JWT
- Gerenciamento de sessões

### 2. Properties API
- Cadastro de propriedades rurais
- Gerenciamento de talhões
- Associação de culturas

### 3. Sensors API
- Recepção de dados de sensores
- Armazenamento de séries temporais
- Publicação em RabbitMQ

### 4. Alerts API
- Processamento assíncrono de dados
- Geração de alertas automáticos
- Regras de negócio:
  - 🌵 Alerta de Seca (umidade < 30% por 24h)
  - 🌡️ Alerta de Temperatura Alta (> 35°C)
  - 🌧️ Alerta de Chuva Excessiva (> 50mm/24h)

## 🗄️ Bancos de Dados

Cada serviço possui seu próprio banco de dados (Database per Service pattern):

| Serviço    | Database       | Porta | User            | Password            |
|------------|---------------|-------|-----------------|---------------------|
| Identity   | identity_db   | 5433  | identity_user   | identity_pass_123   |
| Properties | properties_db | 5434  | properties_user | properties_pass_123 |
| Sensors    | sensors_db    | 5435  | sensors_user    | sensors_pass_123    |
| Alerts     | alerts_db     | 5436  | alerts_user     | alerts_pass_123     |

## 🧪 Testando as APIs

### Via Swagger
Acesse a raiz de cada API (ex: http://localhost:8081)

### Via cURL
```bash
# Registrar usuário
curl -X POST http://localhost:8081/api/auth/register -H "Content-Type: application/json" -d '{"nome": "João Silva", "email": "joao@email.com", "password": "senha123", "telefone": "(11) 98765-4321"}'

# Login
curl -X POST http://localhost:8081/api/auth/login -H "Content-Type: application/json" -d '{"email": "joao@email.com", "password": "senha123"}'
```

## 📝 Scripts Disponíveis

```powershell
# Setup completo
./scripts/setup-identity-service.ps1
# Criar migration
./scripts/create-identity-migration.ps1
# Aplicar migration
./scripts/update-identity-database.ps1
```

## 🔐 Segurança

- JWT com assinatura HMAC-SHA256
- Senhas com hash BCrypt
- CORS configurável
- HTTPS obrigatório em produção
- Containers non-root

## 📧 Contato

Projeto desenvolvido para o curso **8NETT** da FIAP

- Equipe AgroSolutions
- Email: dtpontes@hotmail.com

## 📄 Licença

Este projeto é proprietário - AgroSolutions © 2024
