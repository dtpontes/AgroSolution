# 🌾 AgroSolutions - Plataforma de Agricultura de Precisão

[![.NET 9](https://img.shields.io/badge/.NET-9.0-512BD4)](https://dotnet.microsoft.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)](https://www.postgresql.org/)
[![RabbitMQ](https://img.shields.io/badge/RabbitMQ-3-FF6600)](https://www.rabbitmq.com/)

Plataforma de IoT e análise de dados para agricultura de precisão desenvolvida para a cooperativa AgroSolutions.

## 📋 Sobre o Projeto

A AgroSolutions é uma plataforma que implementa conceitos de **Agricultura 4.0** através de:
- 🌡️ **Monitoramento em tempo real** de sensores de campo
- 📊 **Análise de dados** de umidade, temperatura e precipitação
- ⚠️ **Sistema de alertas** automáticos
- 📱 **Dashboard** para visualização de dados históricos

### Requisitos Funcionais Implementados

✅ Autenticação de Usuário (Produtor Rural)  
✅ Cadastro de Propriedade e Talhões  
✅ Ingestão de Dados de Sensores (via API)  
✅ Dashboard de Monitoramento  
✅ Motor de Alertas Simples  

## 🏗️ Arquitetura

### Microserviços

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Identity API   │     │ Properties API  │     │  Sensors API    │
│     :5001       │     │     :5002       │     │     :5003       │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  identity_db    │     │ properties_db   │     │  sensors_db     │
│   PostgreSQL    │     │   PostgreSQL    │     │   PostgreSQL    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │    RabbitMQ     │
                                                 │     :5672       │
                                                 └────────┬────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │ Alerts Worker   │
                                                 │ (Background)    │
                                                 └────────┬────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │   alerts_db     │
                                                 │   PostgreSQL    │
                                                 └─────────────────┘
```

### Tecnologias

- **Backend:** .NET 9 (C# 13)
- **Banco de Dados:** PostgreSQL 15 (1 banco por serviço)
- **Message Broker:** RabbitMQ
- **Autenticação:** JWT Bearer Token
- **ORM:** Entity Framework Core 9
- **Documentação:** Swagger/OpenAPI
- **Containerização:** Docker
- **Orquestração:** Kubernetes (preparado)

## 🚀 Quick Start

### Pré-requisitos

- ✅ .NET 9 SDK
- ✅ Docker Desktop
- ✅ Visual Studio 2026 (ou VS Code)
- ✅ PowerShell 7+

### Setup Rápido - Identity API

```powershell
# 1. Clone o repositório
git clone <seu-repo>
cd AgroSolution

# 2. Execute o setup automático
.\scripts\setup-identity-service.ps1

# 3. Inicie a API
cd src/Services/Identity/AgroSolutions.Identity.Api
dotnet run

# 4. Acesse o Swagger
# http://localhost:5001
```

## 📦 Estrutura do Projeto

```
AgroSolution/
├── src/
│   ├── Services/
│   │   ├── Identity/                  # ✅ Implementado
│   │   │   └── AgroSolutions.Identity.Api/
│   │   ├── Properties/                # 🚧 Em desenvolvimento
│   │   │   └── AgroSolutions.Properties.Api/
│   │   ├── Sensors/                   # 🚧 Em desenvolvimento
│   │   │   └── AgroSolutions.Sensors.Api/
│   │   └── Alerts/                    # 🚧 Em desenvolvimento
│   │       └── AgroSolutions.Alerts.Worker/
│   └── Shared/
│       └── AgroSolutions.Shared/      # ✅ Implementado
├── scripts/                           # Scripts PowerShell
├── k8s/                              # Manifests Kubernetes
├── docker-compose.yml                # 🚧 Em desenvolvimento
└── README.md
```

## 🔑 Serviços Implementados

### 1. Identity API ✅

**Porta:** 5001  
**Database:** identity_db (porta 5433)

Responsável por:
- Registro de produtores rurais
- Autenticação via JWT
- Gerenciamento de sessões

**Endpoints:**
- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Dados do usuário (autenticado)
- `GET /health` - Health check

📖 [Documentação completa](src/Services/Identity/AgroSolutions.Identity.Api/README.md)

### 2. Properties API 🚧

**Porta:** 5002  
**Database:** properties_db (porta 5434)

Responsável por:
- Cadastro de propriedades rurais
- Gerenciamento de talhões
- Associação de culturas

### 3. Sensors API 🚧

**Porta:** 5003  
**Database:** sensors_db (porta 5435)

Responsável por:
- Recepção de dados de sensores
- Armazenamento de séries temporais
- Publicação em RabbitMQ

### 4. Alerts Worker 🚧

**Database:** alerts_db (porta 5436)

Responsável por:
- Processamento assíncrono de dados
- Geração de alertas automáticos
- Regras de negócio:
  - 🌵 Alerta de Seca (umidade < 30% por 24h)
  - 🌡️ Alerta de Temperatura Alta (> 35°C)
  - 🌧️ Alerta de Chuva Excessiva (> 50mm/24h)

## 🗄️ Bancos de Dados

Cada serviço possui seu próprio banco de dados (Database per Service pattern):

| Serviço | Database | Porta | User | Password |
|---------|----------|-------|------|----------|
| Identity | identity_db | 5433 | identity_user | identity_pass_123 |
| Properties | properties_db | 5434 | properties_user | properties_pass_123 |
| Sensors | sensors_db | 5435 | sensors_user | sensors_pass_123 |
| Alerts | alerts_db | 5436 | alerts_user | alerts_pass_123 |

## 🧪 Testando a API

### Via HTTP File (Visual Studio)

Use os arquivos `.http` em cada projeto:
```
src/Services/Identity/AgroSolutions.Identity.Api/AgroSolutions.Identity.Api.http
```

### Via cURL

```bash
# Registrar
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@email.com",
    "password": "senha123",
    "telefone": "(11) 98765-4321"
  }'

# Login
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@email.com",
    "password": "senha123"
  }'
```

### Via Swagger

Acesse: http://localhost:5001

## 🐳 Docker

### Serviços Individuais

```bash
# Identity API
docker build -t agrosolutions/identity-api -f src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile .
docker run -p 5001:8080 agrosolutions/identity-api
```

### Docker Compose (Em breve)

```bash
docker-compose up -d
```

## 📊 Monitoramento (Planejado)

- **Prometheus** - Coleta de métricas
- **Grafana** - Visualização de dashboards
- **Zabbix** - Monitoramento de infraestrutura

## 🔐 Segurança

- ✅ JWT com assinatura HMAC-SHA256
- ✅ Senhas com hash BCrypt
- ✅ CORS configurável
- ✅ HTTPS obrigatório em produção
- ✅ User Secrets para desenvolvimento
- ✅ Containers non-root

## 📝 Scripts Disponíveis

```powershell
# Identity Service
.\scripts\setup-identity-service.ps1          # Setup completo
.\scripts\start-identity-postgres.ps1         # Apenas PostgreSQL
.\scripts\create-identity-migration.ps1       # Criar migration
.\scripts\update-identity-database.ps1        # Aplicar migration
```

## 🎓 Requisitos do Projeto FIAP

### Requisitos Técnicos Obrigatórios

- ✅ Arquitetura baseada em Microsserviços
- 🚧 Orquestração com Kubernetes
- 🚧 Observabilidade (Grafana/Zabbix)
- 🚧 Mensageria (RabbitMQ)
- 🚧 Pipeline CI/CD (GitHub Actions)
- ✅ Melhores práticas de arquitetura

### Entregáveis

1. ✅ Desenho da Solução MVP
2. 🚧 Demonstração da Infraestrutura
3. 🚧 Demonstração da Esteira de CI/CD
4. 🚧 Demonstração do MVP Funcional

## 🤝 Contribuindo

Este é um projeto acadêmico. Contribuições são bem-vindas!

1. Fork o projeto
2. Crie uma feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📧 Contato

Projeto desenvolvido para o curso **8NETT** da FIAP

- 👥 Equipe AgroSolutions
- 📧 Email: contato@agrosolutions.com

## 📄 Licença

Este projeto é proprietário - AgroSolutions © 2024

---

⭐ **Status do Projeto:** Em Desenvolvimento Ativo  
🎯 **Próximo Milestone:** Properties API + Sensors API + RabbitMQ Integration
