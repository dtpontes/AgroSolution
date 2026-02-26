# 🔴 Erro: "Password required" - Solução Rápida

## O Problema

Seu GitHub Actions recebeu este erro:

```
Run docker/login-action@v3
Error: Password required
```

**Causa**: Os secrets `DOCKER_USERNAME` e `DOCKER_PASSWORD` não estão configurados no GitHub.

---

## ✅ Solução em 3 Passos (2 minutos)

### PASSO 1: Gerar Access Token no Docker Hub

1. Vá para: **https://hub.docker.com**
2. Clique no seu avatar (canto superior direito)
3. Clique em **Account Settings**
4. No menu lateral, clique em **Security**
5. Clique em **New Access Token**
6. Preencha:
   ```
   Access Token Description: github-actions
   Permissions: Read & Write (padrão)
   ```
7. Clique em **Generate**
8. **Copie o token que aparecer**:
   ```
   dckr_pat_xxxxxxxxxxxxxxxxxxxxxx
   ```
9. **Salve em um local seguro** (será deletado após sair da página!)

---

### PASSO 2: Adicionar Secrets no GitHub

1. Vá para seu repositório: **https://github.com/dtpontes/AgroSolution**
2. Clique na aba **Settings**
3. No menu lateral, clique em **Security** (se houver)
4. Procure por **Secrets and variables**
5. Clique em **Actions**

**Você verá uma tela como essa:**
```
Repository secrets
┌─────────────────────────────────┐
│ [New repository secret]         │
└─────────────────────────────────┘
```

---

### PASSO 3: Criar os Dois Secrets

#### Secret #1: DOCKER_USERNAME

```
Clique em "New repository secret"

Name:  DOCKER_USERNAME
Value: seu-username-docker-hub

Clique em "Add secret"
```

**Resultado esperado:**
```
✓ DOCKER_USERNAME    Added
```

#### Secret #2: DOCKER_PASSWORD

```
Clique novamente em "New repository secret"

Name:  DOCKER_PASSWORD
Value: dckr_pat_xxxxxxxxxxxxxxxxxxxxxx

Clique em "Add secret"
```

**Resultado esperado:**
```
✓ DOCKER_PASSWORD    Added
```

---

## 📋 Verificação

Após adicionar os secrets, você deve ver:

```
Repository secrets
├─ DOCKER_PASSWORD      Updated just now
└─ DOCKER_USERNAME      Updated just now
```

---

## 🚀 Próximas Ações

Agora o GitHub Actions conseguirá fazer login no Docker Hub!

### Opção A: Fazer Push Novamente (Recomendado)

Se já fez commit anterior:

```bash
git commit --allow-empty -m "retry: github actions docker login"
git push origin master
```

### Opção B: Aguardar o Próximo Push

Próximo push automático disparará o workflow com os secrets configurados.

---

## ✅ Validação

Após fazer push:

1. Vá para: **GitHub → Actions**
2. Procure pelo workflow **"Build and Push Docker Images"**
3. Veja o progresso

**Esperado**:
```
✅ Checkout code
✅ Free up disk space
✅ Set up Docker Buildx
✅ Login to Docker Hub        ← Agora funciona!
✅ Build and push services
✅ post-build
```

---

## ⚠️ Troubleshooting

### Se ainda der erro "Password required":

1. **Verifique se os secrets foram adicionados:**
   - GitHub → Settings → Secrets → Você vê os 2 secrets?

2. **Verifique se o token é válido:**
   - Docker Hub → Security → Veja se o token está lá
   - Não foi deletado?

3. **Regenere o token:**
   - Às vezes o GitHub não sincroniza imediatamente
   - Delete o secret e adicione novamente
   - Gere um novo token no Docker Hub

### Se der erro de autenticação (credenciais inválidas):

1. Verifique se o token é de fato um Access Token
2. Verifique se o `DOCKER_USERNAME` é seu username (não email)
3. Regenere o token

---

## 🎯 Resumo Rápido

| Ação | Resultado |
|------|-----------|
| Gerar token Docker Hub | ✅ `dckr_pat_...` copiado |
| Adicionar `DOCKER_USERNAME` | ✅ Secret adicionado |
| Adicionar `DOCKER_PASSWORD` | ✅ Secret adicionado |
| Fazer push na master | ✅ Workflow dispara |
| Workflow roda sem erro | ✅ Imagens no Docker Hub |

---

**Pronto! Seu GitHub Actions agora consegue fazer login no Docker Hub!** ✅

*Solução criada em: 2026-02-26*
