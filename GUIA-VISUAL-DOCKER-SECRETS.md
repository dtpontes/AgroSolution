# 📖 Guia Visual - Adicionar Docker Hub Secrets no GitHub

## 🎯 Objetivo
Resolver o erro `Password required` adicionando credenciais do Docker Hub no GitHub.

---

## 📋 PRÉ-REQUISITOS

- [ ] Conta no GitHub (você já tem)
- [ ] Conta no Docker Hub (crie em docker.com se não tiver)
- [ ] Ser owner ou ter permissão de admin no repositório

---

## 🔑 ETAPA 1: Gerar Token no Docker Hub (3 min)

### Passo 1.1: Acessar Docker Hub

Abra: **https://hub.docker.com**

Tela esperada:
```
┌──────────────────────────────────────┐
│  Docker                              │
│  [Search] [SignIn] [Sign Up]        │
│                                      │
│  Welcome to Docker Hub               │
│  The world's leading...              │
└──────────────────────────────────────┘
```

### Passo 1.2: Acessar Conta

Clique no seu avatar:

```
┌──────────────────────────────────────┐
│  Docker Hub                          │
│  [Search]        [seu-avatar▼]      │
│                   ├─ Your repositories
│                   ├─ Saved
│                   ├─ Account Settings ← Aqui
│                   ├─ Subscriptions
│                   ├─ Billing
│                   ├─ Logout
│                   └─ ...
└──────────────────────────────────────┘
```

### Passo 1.3: Ir para Security

Clique em **Account Settings**:

```
┌──────────────────────────────────────┐
│  Docker Hub - Account Settings       │
│                                      │
│  Menu Lateral:                       │
│  ├─ Profile                          │
│  ├─ Personal Access Tokens           │
│  ├─ Security        ← Clique aqui    │
│  ├─ Notifications                    │
│  ├─ Billing                          │
│  └─ ...                              │
└──────────────────────────────────────┘
```

### Passo 1.4: Criar Novo Token

Na página Security:

```
┌──────────────────────────────────────┐
│  Account Settings > Security         │
│                                      │
│  Access Tokens                       │
│  ┌────────────────────────────────┐ │
│  │ [New Access Token]           │ │ ← Clique
│  └────────────────────────────────┘ │
│                                      │
│  Your Access Tokens:                 │
│  (Nenhum ainda)                      │
└──────────────────────────────────────┘
```

### Passo 1.5: Preencher Informações

Depois de clicar em "New Access Token":

```
┌──────────────────────────────────────┐
│  Create Access Token                 │
│                                      │
│  Access Token Name:                  │
│  ┌────────────────────────────────┐ │
│  │ github-actions                 │ │ ← Digite aqui
│  └────────────────────────────────┘ │
│                                      │
│  Permissions (Select scopes):        │
│  ☑ Read & Write  ← Deixe marcado    │
│                                      │
│  [Generate]  ← Clique para gerar    │
└──────────────────────────────────────┘
```

### Passo 1.6: Copiar Token

Após clicar "Generate":

```
┌──────────────────────────────────────┐
│  Your Access Token                   │
│                                      │
│  dckr_pat_XXXXXXXXXXXXXXXXXXXXXXXXXXx│
│  [Copy] ← Clique para copiar         │
│                                      │
│  ⚠️ Este token será mostrado apenas  │
│  uma vez. Salve em lugar seguro!     │
└──────────────────────────────────────┘
```

**IMPORTANTE**: 
- Copie este token
- Salve em um local seguro (arquivo de texto temporário)
- Não o compartilhe

---

## 🔐 ETAPA 2: Adicionar Secrets no GitHub (3 min)

### Passo 2.1: Acessar Repositório

Abra: **https://github.com/dtpontes/AgroSolution**

Tela esperada:
```
┌──────────────────────────────────────┐
│  dtpontes/AgroSolution               │
│  [Code] [Issues] [Pull requests]    │
│  [Actions] [Settings] [...]          │
│                                      │
│  Main  [↓] | Your branches | Tags   │
│  AgroSolution repo                   │
└──────────────────────────────────────┘
```

### Passo 2.2: Ir para Settings

Clique em **Settings** (no topo):

```
┌──────────────────────────────────────┐
│  dtpontes / AgroSolution             │
│  Settings                            │
│  ┌─ General                          │
│  ├─ Collaborators                    │
│  ├─ Branches                         │
│  ├─ Webhooks                         │
│  ├─ Deploy keys                      │
│  ├─ Security & analysis              │
│  ├─ Secrets and variables ← Aqui     │
│  └─ ...                              │
└──────────────────────────────────────┘
```

### Passo 2.3: Ir para Actions Secrets

Na seção "Secrets and variables":

```
┌──────────────────────────────────────┐
│  Secrets and variables               │
│                                      │
│  ├─ [Secrets]                        │
│  ├─ Variables                        │
│  └─ Actions       ← Clique aqui      │
│                                      │
│  Action secrets                      │
│  ┌────────────────────────────────┐ │
│  │ [New repository secret]        │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Passo 2.4: Criar Primeiro Secret (DOCKER_USERNAME)

Clique em "New repository secret":

```
┌──────────────────────────────────────┐
│  New Repository Secret               │
│                                      │
│  Name:                               │
│  ┌────────────────────────────────┐ │
│  │ DOCKER_USERNAME                │ │ ← Digite
│  └────────────────────────────────┘ │
│                                      │
│  Secret:                             │
│  ┌────────────────────────────────┐ │
│  │ seu-username-docker-hub        │ │ ← Digite seu username
│  └────────────────────────────────┘ │
│                                      │
│  [Add secret]  ← Clique              │
└──────────────────────────────────────┘
```

**Esperado após clicar**:
```
✓ DOCKER_USERNAME    Added
```

### Passo 2.5: Criar Segundo Secret (DOCKER_PASSWORD)

Clique novamente em "New repository secret":

```
┌──────────────────────────────────────┐
│  New Repository Secret               │
│                                      │
│  Name:                               │
│  ┌────────────────────────────────┐ │
│  │ DOCKER_PASSWORD                │ │ ← Digite
│  └────────────────────────────────┘ │
│                                      │
│  Secret:                             │
│  ┌────────────────────────────────┐ │
│  │ dckr_pat_XXXXXXXXXXXXXXXXXXXXX │ │ ← Cola o token
│  └────────────────────────────────┘ │
│                                      │
│  [Add secret]  ← Clique              │
└──────────────────────────────────────┘
```

**Esperado após clicar**:
```
✓ DOCKER_PASSWORD    Added
```

---

## ✅ ETAPA 3: Verificação (1 min)

Na página de Actions secrets, você deve ver:

```
┌──────────────────────────────────────┐
│  Action Secrets                      │
│                                      │
│  ✓ DOCKER_PASSWORD     Updated now   │
│  ✓ DOCKER_USERNAME     Updated now   │
└──────────────────────────────────────┘
```

---

## 🚀 ETAPA 4: Testar (5 min)

### Opção A: Fazer Novo Push

No seu terminal PowerShell:

```powershell
cd C:\Users\Daniel Pontes\source\repos\AgroSolution

git status
git add .
git commit -m "fix: adicionar docker hub secrets"
git push origin master
```

### Opção B: Fazer Push Vazio

Se não tem mudanças:

```powershell
git commit --allow-empty -m "retry: docker hub login"
git push origin master
```

---

## 👁️ MONITORAR EXECUÇÃO

1. Vá para: **https://github.com/dtpontes/AgroSolution/actions**
2. Procure pelo workflow **"Build and Push Docker Images"**
3. Clique nele

**Esperado**:
```
Build and Push Docker Images  ⏳ In progress

├─ setup
│  ├─ Checkout code               ✅
│  ├─ Free up disk space          ✅
│  ├─ Set up Docker Buildx        ✅
│  ├─ Login to Docker Hub         ✅ (Agora funciona!)
│  ├─ Extract version from tag    ✅
│  └─ Build and push [service]    ⏳ In progress...
```

---

## 🎉 SUCESSO

Quando o workflow completar com ✅, você verá:

```
✓ Build and Push Docker Images   Success
```

E as imagens estarão no Docker Hub! 🐳

---

## 📸 Visual Rápido

```
Docker Hub                          GitHub
├─ Gerar Token                      ├─ Settings
│  dckr_pat_...                     │
│         │                         │
│         └────────────────────────→│ Secrets
│                                   │
│                                   ├─ DOCKER_USERNAME
│                                   └─ DOCKER_PASSWORD
│                                          │
│                                          ↓
│                                   GitHub Actions
│                                   ├─ Login ✅
│                                   ├─ Build ✅
│                                   └─ Push ✅
│                                          │
│                                          ↓
│                                   Docker Hub
│                                   ├─ agrosolution-identity-api:latest
│                                   ├─ agrosolution-properties-api:latest
│                                   ├─ agrosolution-sensors-api:latest
│                                   └─ agrosolution-alerts-api:latest
```

---

**Pronto! Você conseguiu!** ✨

*Guia criado em: 2026-02-26*
