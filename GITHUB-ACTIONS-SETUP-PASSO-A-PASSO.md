# 🚀 Setup GitHub Actions - Docker Hub Push

Guia completo para configurar a automatização de build e push das imagens Docker.

## 📋 Checklist Rápido

- [ ] Criar conta no [Docker Hub](https://hub.docker.com/)
- [ ] Gerar Access Token no Docker Hub
- [ ] Adicionar Secrets no GitHub
- [ ] Fazer um push/merge na master para testar

---

## 1️⃣ Criar/Configurar Conta no Docker Hub

### Se não tem conta:
1. Acesse [hub.docker.com](https://hub.docker.com/)
2. Clique em **Sign Up**
3. Preencha o formulário e confirme email

### Se já tem conta:
Prossiga para a próxima etapa.

---

## 2️⃣ Gerar Access Token no Docker Hub

1. **Acesse Docker Hub**: https://hub.docker.com/
2. **Clique no seu avatar** (canto superior direito)
3. **Selecione "Account Settings"**
4. **No menu lateral, clique em "Security"**
5. **Clique em "New Access Token"**

```
┌─────────────────────────────────┐
│ Docker Hub                      │
├─────────────────────────────────┤
│ Avatar ▼                        │
│   ├─ Account Settings           │
│   ├─ Security                   │
│   └─ ...                        │
│                                 │
│ Security                        │
│ [New Access Token] ← Clique aqui│
└─────────────────────────────────┘
```

6. **Preencha os dados**:
   - **Access Token Description**: `github-actions`
   - **Permissions**: Deixe como padrão (Read & Write)
   - Clique em **Generate**

7. **Copie o token** que aparecerá:
   ```
   ┌──────────────────────────────────────┐
   │ Your Access Token                    │
   │ dckr_pat_xxxxxxxxxxxxxxxxxxx         │
   │ [Copy button] ← Clique aqui          │
   └──────────────────────────────────────┘
   ```

8. **Salve em um lugar seguro** (será necessário para o GitHub)

⚠️ **Não compartilhe este token com ninguém!**

---

## 3️⃣ Adicionar Secrets no GitHub

### Abra seu repositório no GitHub

1. **Vá para**: `https://github.com/seu-usuario/AgroSolution`
2. **Clique em "Settings"** (no topo do repositório)
3. **No menu lateral, procure por "Secrets and variables"** (ou **Security** → **Secrets**)
4. **Clique em "Actions"**

```
Repository
├─ Settings
│  ├─ General
│  ├─ Security
│  │  └─ Secrets and variables  ← Aqui
│  │     └─ Actions             ← Aqui
```

### Adicione os Secrets

Clique em **"New repository secret"** e adicione:

#### Secret 1: `DOCKER_USERNAME`

```
Name:  DOCKER_USERNAME
Value: seu-usuario-docker-hub
```

#### Secret 2: `DOCKER_PASSWORD`

```
Name:  DOCKER_PASSWORD
Value: dckr_pat_xxxxxxxxxxxxxxxxxxx (token copiado acima)
```

**Resultado esperado**:
```
┌─────────────────────────────────────┐
│ Repository Secrets                  │
├─────────────────────────────────────┤
│ ✓ DOCKER_PASSWORD      Updated:xxx  │
│ ✓ DOCKER_USERNAME      Updated:xxx  │
└─────────────────────────────────────┘
```

---

## 4️⃣ Verificar o Arquivo de Workflow

O arquivo `.github/workflows/docker-build-push.yml` já está criado com:

```yaml
on:
  push:
    branches:
      - master
```

Isso significa que o workflow será acionado sempre que:
- ✅ Você faz `git push` na branch `master`
- ✅ Um Pull Request é feito merge na `master`

---

## 5️⃣ Testar o Workflow

### Opção A: Fazer um Push Simples (Recomendado)

```powershell
# No seu repositório local
git add .
git commit -m "chore: setup github actions para docker hub"
git push origin master
```

### Opção B: Testar Localmente com os Scripts

#### No Windows (PowerShell):

```powershell
# Build local (sem push)
.\scripts\docker-build-push.ps1 -DockerUsername "seu-usuario-docker"

# Build + Push
.\scripts\docker-build-push.ps1 -DockerUsername "seu-usuario-docker" -Push
```

#### No Linux/Mac (Bash):

```bash
# Build local (sem push)
./scripts/docker-build-push.sh -u "seu-usuario-docker"

# Build + Push
./scripts/docker-build-push.sh -u "seu-usuario-docker" -p
```

---

## 6️⃣ Monitorar o Workflow

Depois de fazer push:

1. **Vá para o repositório no GitHub**
2. **Clique na aba "Actions"**
3. **Procure pelo workflow "Build and Push Docker Images"**
4. **Clique para ver os detalhes**

```
Repository
├─ Actions                    ← Clique aqui
│  └─ Build and Push Docker Images
│     ├─ Workflow run #1
│     │  ├─ build-and-push   ✅ passed
│     │  │  ├─ identity-api  ✅
│     │  │  ├─ properties-api ✅
│     │  │  ├─ sensors-api   ✅
│     │  │  └─ alerts-api    ✅
│     │  └─ post-build       ✅ passed
```

---

## 7️⃣ Verificar as Imagens no Docker Hub

Depois de sucesso:

1. **Acesse**: https://hub.docker.com/repositories
2. **Procure por suas imagens**:
   - `seu-usuario/agrosolution-identity-api`
   - `seu-usuario/agrosolution-properties-api`
   - `seu-usuario/agrosolution-sensors-api`
   - `seu-usuario/agrosolution-alerts-api`

3. **Cada uma terá as tags**:
   - `:latest` (versão mais recente)
   - `:abc1234` (versão específica do commit)

---

## 🎯 Próximos Passos

### Usar as Imagens em Produção

Atualize seu `docker-compose.yml` para usar as imagens do Docker Hub:

```yaml
services:
  identity-api:
    image: seu-usuario/agrosolution-identity-api:latest
    # ... resto da config

  properties-api:
    image: seu-usuario/agrosolution-properties-api:latest
    # ... resto da config
```

### Usar em Outro Servidor

```bash
# Pull da imagem
docker pull seu-usuario/agrosolution-identity-api:latest

# Rodar container
docker run -p 8081:8081 seu-usuario/agrosolution-identity-api:latest
```

### Usar Versioning Semântico

Se quiser usar tags de versão (ex: `v1.0.0`):

1. Crie uma tag no Git:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. O workflow automaticamente criará imagens com:
   - `:v1.0.0` (versão exata)
   - `:latest` (sempre aponta para a última)

Para ativar isso, edite `.github/workflows/docker-build-push.yml`:

```yaml
on:
  push:
    branches:
      - master
    tags:
      - 'v*'  # Adicionar esta linha
```

Ou use a versão avançada: `.github/workflows/docker-build-push-advanced.yml`

---

## 🐛 Troubleshooting

### Erro: "invalid username/password"

**Solução**:
1. Verifique se os secrets foram adicionados corretamente
2. Certifique-se de que o token é válido (regenere no Docker Hub se necessário)
3. Limpe cache do navegador e tente novamente

### Erro: "Dockerfile not found"

**Solução**:
1. Verifique se todos os Dockerfiles existem nos caminhos especificados
2. Rode localmente: `.\scripts\docker-build-push.ps1 -DockerUsername "seu-usuario"`

### Build muito lento

**Solução**:
1. O cache do Docker Hub deve acelerar builds subsequentes
2. Aumentar recursos no runner do GitHub Actions (não é recomendado)

### Push falhou mas build foi bem-sucedido

**Causas possíveis**:
- Repositório privado no Docker Hub (mude para público nas configurações)
- Permissões de token insuficientes (regenere com permissões Read & Write)
- Nome de usuário incorreto nos secrets

---

## ✅ Checklist Final

Verifique se tudo está funcionando:

- [ ] Secrets `DOCKER_USERNAME` e `DOCKER_PASSWORD` adicionados
- [ ] Arquivo `.github/workflows/docker-build-push.yml` existe
- [ ] Fez um push na branch `master`
- [ ] Workflow aparece na aba "Actions"
- [ ] Workflow executou com sucesso (badges verdes)
- [ ] Imagens aparecem no Docker Hub
- [ ] É possível fazer `docker pull seu-usuario/agrosolution-identity-api:latest`

---

## 📞 Referências

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build and Push Action](https://github.com/docker/build-push-action)
- [Docker Hub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)

---

## 🎉 Pronto!

Seus builds agora são automatizados! Sempre que você fazer um merge na `master`, as imagens serão automaticamente buildadas e enviadas para o Docker Hub.

**Dúvidas? Consulte a documentação acima ou crie uma issue no repositório.**
