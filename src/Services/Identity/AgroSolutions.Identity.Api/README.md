# 🌾 AgroSolutions Identity API

Serviço de autenticação e gerenciamento de usuários da plataforma AgroSolutions.

## 🚀 Tecnologias

- **.NET 9**
- **PostgreSQL** (Entity Framework Core)
- **JWT Authentication** (Bearer Token)
- **BCrypt** (Hash de senhas)
- **Swagger/OpenAPI**
- **Docker**

## 📋 Pré-requisitos

1. **.NET 9 SDK** instalado
2. **PostgreSQL** rodando na porta `5433` (ou Docker)
3. **EF Core Tools**: `dotnet tool install --global dotnet-ef`

## 🛠️ Configuração

### 1. Configurar PostgreSQL

#### Opção A: Docker
```bash
docker run --name agro-identity-db -e POSTGRES_PASSWORD=identity_pass_123 -e POSTGRES_USER=identity_user -e POSTGRES_DB=identity_db -p 5433:5432 -d postgres:15-alpine
```

#### Opção B: PostgreSQL Local
Crie o banco manualmente:
```sql
CREATE DATABASE identity_db;
CREATE USER identity_user WITH PASSWORD 'identity_pass_123';
GRANT ALL PRIVILEGES ON DATABASE identity_db TO identity_user;
```

### 2. Aplicar Migrations

```powershell
# Criar migration (primeira vez)
.\scripts\create-identity-migration.ps1

# Aplicar no banco
.\scripts\update-identity-database.ps1
```

Ou manualmente:
```bash
cd src/Services/Identity/AgroSolutions.Identity.Api
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### 3. Executar o Serviço

```bash
cd src/Services/Identity/AgroSolutions.Identity.Api
dotnet run
```

A API estará disponível em: **http://localhost:5001**

## 📚 Endpoints

### 🔓 Públicos (sem autenticação)

#### Registrar Usuário
```http
POST /api/auth/register
Content-Type: application/json

{
  "nome": "João Silva",
  "email": "joao@email.com",
  "password": "senha123",
  "telefone": "(11) 98765-4321",
  "cpf": "123.456.789-00"
}
```

**Resposta (201 Created):**
```json
{
  "id": "guid",
  "nome": "João Silva",
  "email": "joao@email.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2024-01-20T10:00:00Z"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "joao@email.com",
  "password": "senha123"
}
```

**Resposta (200 OK):**
```json
{
  "id": "guid",
  "nome": "João Silva",
  "email": "joao@email.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2024-01-20T10:00:00Z"
}
```

### 🔒 Autenticados (requer Bearer Token)

#### Obter Dados do Usuário
```http
GET /api/auth/me
Authorization: Bearer {seu-token}
```

**Resposta (200 OK):**
```json
{
  "id": "guid",
  "nome": "João Silva",
  "email": "joao@email.com",
  "telefone": "(11) 98765-4321",
  "cpf": "123.456.789-00",
  "dataCadastro": "2024-01-20T08:00:00Z",
  "ativo": true
}
```

### 🏥 Health Check
```http
GET /health
```

## 🐳 Docker

### Build da Imagem
```bash
docker build -t agrosolutions/identity-api:latest -f src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile .
```

### Executar Container
```bash
docker run -d \
  --name identity-api \
  -p 5001:8080 \
  -e ConnectionStrings__DefaultConnection="Host=host.docker.internal;Port=5433;Database=identity_db;Username=identity_user;Password=identity_pass_123" \
  -e Jwt__Key="sua-chave-secreta-muito-segura-com-pelo-menos-32-caracteres-aqui-para-jwt-token" \
  agrosolutions/identity-api:latest
```

## 🔐 JWT Token

O token JWT gerado contém as seguintes claims:

- `nameid`: ID do usuário (Guid)
- `email`: Email do usuário
- `name`: Nome completo do usuário
- `jti`: ID único do token
- `iat`: Timestamp de criação

**Validade:** 8 horas

## 🧪 Testes

Use o arquivo `AgroSolutions.Identity.Api.http` no Visual Studio 2026 para testar os endpoints.

### Exemplos com cURL:

```bash
# Registrar
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nome":"João Silva","email":"joao@email.com","password":"senha123"}'

# Login
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@email.com","password":"senha123"}'

# Obter usuário (substitua {TOKEN} pelo token recebido)
curl -X GET http://localhost:5001/api/auth/me \
  -H "Authorization: Bearer {TOKEN}"
```

## 📊 Swagger

Acesse a documentação interativa em: **http://localhost:5001**

## 🔧 Configuração (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5433;Database=identity_db;Username=identity_user;Password=identity_pass_123"
  },
  "Jwt": {
    "Key": "sua-chave-secreta-de-pelo-menos-32-caracteres",
    "Issuer": "AgroSolutions",
    "Audience": "AgroSolutions",
    "ExpirationHours": 8
  }
}
```

## 🚨 Validações

### Registro:
- ✅ Nome obrigatório (máx 200 chars)
- ✅ Email único e válido (máx 200 chars)
- ✅ Senha mínimo 6 caracteres
- ✅ CPF único (se fornecido)

### Login:
- ✅ Email e senha obrigatórios
- ✅ Usuário deve estar ativo

## 📝 Logs

```log
info: AgroSolutions.Identity.Api.Services.AuthService[0]
      Novo usuário registrado: {UserId} - {Email}

info: AgroSolutions.Identity.Api.Services.AuthService[0]
      Login bem-sucedido: {UserId} - {Email}

warn: AgroSolutions.Identity.Api.Services.AuthService[0]
      Tentativa de registro com email já existente: {Email}
```

## 🔒 Segurança

- ✅ Senhas com hash BCrypt
- ✅ HTTPS obrigatório em produção
- ✅ JWT com assinatura HMAC-SHA256
- ✅ CORS configurável
- ✅ User secrets para desenvolvimento
- ✅ Container não-root (usuário `appuser`)

## 📦 Estrutura do Projeto

```
AgroSolutions.Identity.Api/
├── Controllers/
│   └── AuthController.cs
├── Data/
│   └── IdentityDbContext.cs
├── DTOs/
│   └── AuthDtos.cs
├── Models/
│   └── User.cs
├── Services/
│   └── AuthService.cs
├── Program.cs
├── appsettings.json
├── Dockerfile
└── .dockerignore
```

## 👥 Autor

AgroSolutions Team - Projeto FIAP 8NETT

## 📄 Licença

Proprietary - AgroSolutions © 2024
