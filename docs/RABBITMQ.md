# AgroSolutions - Arquitetura com RabbitMQ

## Comunicacao entre Microservicos

### Fluxo de Dados de Sensores

```
Sensors API → RabbitMQ → Alerts Worker
     ↓                         ↓
sensors_db              SensorDataCache (alerts_db)
```

### Como Funciona

1. **Sensors API** recebe dados via POST `/api/sensors/ingest`
2. **Armazena** em `sensors_db`
3. **Publica evento** no RabbitMQ (fila: `sensor-data-queue`)
4. **Alerts Worker** consome o evento
5. **Armazena cache local** em `SensorDataCache` (alerts_db)
6. **Processa alertas** a cada 5 minutos

### Vantagens

- ✅ Bancos isolados (cada serviço tem o seu)
- ✅ Comunicação assíncrona (desacoplamento)
- ✅ Resiliência (mensagens persistem no RabbitMQ)
- ✅ Escalabilidade (múltiplos consumers)
- ✅ Padrão enterprise

### RabbitMQ Management UI

```
http://localhost:15672
Usuário: guest
Senha: guest
```

### Filas

- `sensor-data-queue`: Dados de sensores

### Quick Start

```powershell
.\scripts\quick-start-all.ps1
```

Isso inicia:
- RabbitMQ (5672, 15672)
- PostgreSQL (4 bancos)
- 4 APIs

### Testar

1. Registre um usuário no Identity API
2. Crie uma propriedade e talhão no Properties API
3. Envie dados de sensor no Sensors API
4. Verifique o RabbitMQ Management UI (mensagens processadas)
5. Consulte o dashboard no Alerts API
