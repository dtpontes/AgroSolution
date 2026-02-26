# AgroSolutions Alerts API

## 📋 Descrição

API responsável por:
- **Alertas**: Criação e gerenciamento de alertas automáticos baseados em dados de sensores
- **Dashboard**: Visualização de status e histórico de leituras
- **Background Services**: 
  - Processamento de alertas a cada 5 minutos
  - Consumo de dados de sensores via RabbitMQ

## 🚀 Endpoints

### Alertas

```http
GET /api/alerts/talhoes/{talhaoId}/status
```
Retorna o status atual e alertas ativos de um talhão.

```http
GET /api/alerts/talhoes/{talhaoId}/dashboard?start=2024-01-01&end=2024-12-31
```
Retorna dashboard completo com status, alertas e histórico de leituras.

```http
GET /health
```
Health check da API.

## ⚙️ Configuração

### appsettings.json

```json
{
  "ConnectionStrings": {
    "AlertsConnection": "Host=localhost;Port=5436;Database=alerts_db;Username=alerts_user;Password=alerts_pass_123"
  },
  "RabbitMQ": {
    "Host": "localhost"
  },
  "Jwt": {
    "Key": "sua-chave-secreta",
    "Issuer": "AgroSolutions",
    "Audience": "AgroSolutions"
  }
}
```

## 🔧 Executar

```bash
dotnet run --project src/Services/Alerts/AgroSolutions.Alerts.API
```

Swagger: http://localhost:5004

## 📊 Background Services

### AlertWorker
- **Frequência**: A cada 5 minutos
- **Função**: Processa dados de sensores das últimas 24h e cria/resolve alertas automaticamente

**Tipos de Alertas:**
- **Seca**: Umidade do solo < 30% por 24h consecutivas
- **TemperaturaAlta**: Temperatura > 35°C
- **ChuvaExcessiva**: Precipitação acumulada > 50mm em 24h

### SensorDataConsumerService
- **Função**: Consome mensagens da fila `sensor-data-queue` do RabbitMQ
- **Ação**: Armazena dados de sensores no cache local para análise

## 🗄️ Banco de Dados

PostgreSQL na porta **5436**

**Tabelas:**
- `Alerts`: Alertas criados automaticamente
- `SensorDataCache`: Cache de dados de sensores para análise

## 🔐 Autenticação

Todos os endpoints (exceto `/health`) requerem JWT Bearer Token.
