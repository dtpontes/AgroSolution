# 🏗️ Arquitetura - GitHub Actions + Docker Hub

## 📁 Estrutura de Arquivos Criada

```
AgroSolution/
│
├── .github/
│   └── workflows/
│       ├── docker-build-push.yml          ⭐ PRINCIPAL
│       └── docker-build-push-advanced.yml   (Opcional)
│
├── scripts/
│   ├── docker-build-push.ps1      🪟 Windows
│   └── docker-build-push.sh        🐧 Linux/Mac
│
└── docs/
    ├── README-GITHUB-ACTIONS.md           📌 LER ISTO PRIMEIRO
    ├── GITHUB-ACTIONS-SETUP.md            📖 Documentação
    ├── GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md 👣 Guia Passo a Passo
    └── GITHUB-ACTIONS-ARCHITECTURE.md     🏗️ Esta arquivo
```

---

## 🔄 Fluxo Completo

### 1️⃣ Desenvolvimento Local
```
Você (Developer)
    │
    ├─ Escreve código
    ├─ Testa localmente
    ├─ Faz commit
    └─ git push origin master
        │
        ▼
    GitHub Repository
        │ (Webhook automático)
        ▼
    GitHub Actions Runner
```

### 2️⃣ Build das Imagens
```
GitHub Actions Runner (Ubuntu Linux)
    │
    ├─ Checkout do código
    ├─ Setup Docker Buildx
    │
    ├─ Parallel Build:
    │  ├─ Identity API       → docker build -f Dockerfile
    │  ├─ Properties API     → docker build -f Dockerfile
    │  ├─ Sensors API       → docker build -f Dockerfile
    │  └─ Alerts API        → docker build -f Dockerfile
    │
    └─ Tags das imagens:
       ├─ :latest (sempre)
       └─ :commit-sha (versão específica)
```

### 3️⃣ Push para Docker Hub
```
Docker Hub
    │
    ├─ agrosolution-identity-api
    │  ├─ :latest
    │  └─ :a1b2c3d
    │
    ├─ agrosolution-properties-api
    │  ├─ :latest
    │  └─ :a1b2c3d
    │
    ├─ agrosolution-sensors-api
    │  ├─ :latest
    │  └─ :a1b2c3d
    │
    └─ agrosolution-alerts-api
       ├─ :latest
       └─ :a1b2c3d
```

### 4️⃣ Uso em Produção
```
Servidor de Produção
    │
    ├─ docker pull seu-user/agrosolution-identity-api:latest
    ├─ docker pull seu-user/agrosolution-properties-api:latest
    ├─ docker pull seu-user/agrosolution-sensors-api:latest
    └─ docker pull seu-user/agrosolution-alerts-api:latest
    │
    └─ docker-compose up -d
```

---

## 🔐 Fluxo de Segurança

```
GitHub Secrets (Criptografado)
├─ DOCKER_USERNAME  ← Nunc aparece em logs
└─ DOCKER_PASSWORD  ← Nunca aparece em logs

        │
        ▼
GitHub Actions Runner (Isolado)
├─ Acessa secrets via ${{ secrets.* }}
├─ Mantém seguro na memória
└─ Docker login com credenciais

        │
        ▼
Docker Hub API
├─ Valida token
├─ Autoriza push
└─ Armazena imagens
```

---

## 📊 Matriz de Build Paralelo

O workflow usa `strategy.matrix` para builds paralelos:

```yaml
strategy:
  matrix:
    service:
      - { name: "identity-api", ... }
      - { name: "properties-api", ... }
      - { name: "sensors-api", ... }
      - { name: "alerts-api", ... }
```

Resultado na visualização:
```
GitHub Actions
├─ build-and-push [identity-api]       ⏱️ 3m 45s
├─ build-and-push [properties-api]     ⏱️ 3m 42s
├─ build-and-push [sensors-api]        ⏱️ 3m 50s
├─ build-and-push [alerts-api]         ⏱️ 3m 48s
└─ post-build (aguarda todos)          ⏱️ 0m 15s
   
   ✅ Total: ~4 minutos (não 15!)
```

---

## 🎯 Triggers do Workflow

```yaml
on:
  push:
    branches:
      - master  ← Dispara aqui
```

Cenários que disparam:

```
✅ DISPARA:
  • git push origin master (direto)
  • Pull Request → Merge na master
  • git rebase + push na master

❌ NÃO DISPARA:
  • Push em outras branches (develop, feature/*, etc)
  • PRs sem merge
  • Commits locais sem push
```

---

## 🏷️ Tagging Strategy

### Tag `:latest`
```
Sempre aponta para a versão mais recente
├─ Buildada no master
├─ Sobrescreve build anterior
└─ Ideal para development
```

### Tag `:SHORT_SHA`
```
Baseada no commit hash (primeiros 7 caracteres)
├─ a1b2c3d (exemplo)
├─ Nunca muda (imutável)
└─ Rastreável até commit específico
```

### Exemplo Real
```
Commit 1: a1b2c3d
  docker pull seu-user/agrosolution-identity-api:a1b2c3d
  docker pull seu-user/agrosolution-identity-api:latest

Commit 2: x7y8z9a
  docker pull seu-user/agrosolution-identity-api:x7y8z9a
  docker pull seu-user/agrosolution-identity-api:latest  ← Agora aponta para x7y8z9a
```

---

## 🚀 Performance & Cache

### Docker Buildx com Cache

```yaml
cache-from: type=registry,ref=seu-user/agrosolution-identity-api:buildcache
cache-to: type=registry,ref=seu-user/agrosolution-identity-api:buildcache,mode=max
```

**Benefício**:
```
Build 1 (cold): dotnet restore + build + publish = ~4 minutos
Build 2 (hot):  dotnet restore (cached) + build (cached) = ~30 segundos ⚡
```

---

## 📈 Logs & Monitoramento

### Ver Logs no GitHub

```
GitHub → Actions → docker-build-push → Run #1
├─ Setup
├─ Checkout code                      ✅
├─ Set up Docker Buildx               ✅
├─ Login to Docker Hub                ✅
├─ Extract version from tag           ✅
├─ Build and push identity-api        ✅
├─ Build and push properties-api      ✅
├─ Build and push sensors-api         ✅
├─ Build and push alerts-api          ✅
└─ Log build summary                  ✅
```

### Interpretar Resultado

```
✅ Workflow succeeded    = Tudo OK! Imagens no Docker Hub
⚠️  Workflow warning     = Compilou mas com aviso
❌ Workflow failed       = Erro, verifique logs
⏭️  Workflow skipped     = Não foi disparado (trigger não atendido)
```

---

## 🔄 Integração com Docker Compose

### Antes (imagens locais)
```yaml
services:
  identity-api:
    build:
      context: .
      dockerfile: src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile
```

### Depois (imagens Docker Hub)
```yaml
services:
  identity-api:
    image: seu-usuario/agrosolution-identity-api:latest
    environment:
      # ... config
```

**Vantagem**: Não precisa compilar no servidor! Apenas `docker pull`.

---

## 🛠️ Troubleshooting Visual

```
Erro: "invalid username/password"
    ↓
Verificar GitHub Secrets
├─ Repository → Settings → Secrets
├─ DOCKER_USERNAME deve existir
└─ DOCKER_PASSWORD deve estar preenchido
    ↓
Se vazio: Adicione novamente
Se errado: Regenere token no Docker Hub


Erro: "Dockerfile not found"
    ↓
Verificar caminhos dos Dockerfiles
├─ Deve existir: src/Services/Identity/.../Dockerfile
├─ Deve existir: src/Services/Properties/.../Dockerfile
├─ Deve existir: src/Services/Sensors/.../Dockerfile
└─ Deve existir: src/Services/Alerts/.../Dockerfile
    ↓
Teste localmente: docker build -f caminho/Dockerfile .


Erro: "Push falhou"
    ↓
Verificar Docker Hub
├─ Token pode estar expirado
├─ Repositório pode ser privado
└─ Permissões insuficientes
    ↓
Solução: Regenere token com permissões Read & Write
```

---

## 📚 Stack Tecnológico

```
┌─────────────────────────────────────┐
│    GitHub (Platform)                │
├─────────────────────────────────────┤
│  GitHub Actions (CI/CD)             │
│  ├─ docker/setup-buildx-action      │
│  ├─ docker/login-action             │
│  └─ docker/build-push-action        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Docker Hub (Registry)            │
├─────────────────────────────────────┤
│  • 4 Repositórios                   │
│  • Tags :latest e :SHORT_SHA        │
│  • Cache para builds rápidos        │
└─────────────────────────────────────┘
```

---

## 🎯 KPIs & Métricas

Acompanhe essas métricas:

```
✅ Build Success Rate      ← Deve ser 100%
⏱️  Average Build Time      ← Target: <5 min
📦 Image Size             ← Menor é melhor
🔒 Security Vulnerabilities ← Deve ser 0
📊 Push Success Rate       ← Deve ser 100%
🔄 Cache Hit Rate         ← Aumenta com o tempo
```

---

## 🎓 Aprendizado & Referências

Leia nesta ordem:

1. `README-GITHUB-ACTIONS.md` - Visão geral
2. `GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md` - Setup prático
3. `GITHUB-ACTIONS-SETUP.md` - Documentação detalhada
4. `.github/workflows/docker-build-push.yml` - Código YAML
5. Documentação oficial (links no README)

---

## 🎉 Resumo

Você agora tem:

✅ CI/CD completamente automatizado  
✅ Imagens sempre atualizadas no Docker Hub  
✅ Build paralelo de 4 serviços  
✅ Cache otimizado para performance  
✅ Rastreabilidade de versões  
✅ Segurança com secrets criptografados  
✅ Scripts locais para testar  
✅ Documentação completa  

**Próximo passo**: Adicione os secrets no GitHub e faça seu primeiro push! 🚀

---

*Diagrama criado em: 2026-02-26*
