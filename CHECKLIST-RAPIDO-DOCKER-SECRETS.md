# ⚡ CHECKLIST RÁPIDO - Docker Hub Secrets (2 minutos)

## Erro Recebido
```
Run docker/login-action@v3
Error: Password required
```

---

## ✅ Resolução Rápida

### [ ] Passo 1: Gerar Token
```
1. Abra: https://hub.docker.com
2. Clique no avatar → Account Settings → Security
3. Clique em "New Access Token"
4. Descrição: "github-actions"
5. Clique em "Generate"
6. COPIE o token: dckr_pat_XXXXX...
7. SALVE em lugar seguro
```

### [ ] Passo 2: Adicionar Secret #1
```
1. Abra: https://github.com/dtpontes/AgroSolution
2. Vá para: Settings → Secrets and variables → Actions
3. Clique em "New repository secret"
4. Name:  DOCKER_USERNAME
5. Value: seu-username-docker-hub
6. Clique em "Add secret"
```

### [ ] Passo 3: Adicionar Secret #2
```
1. Clique em "New repository secret" novamente
2. Name:  DOCKER_PASSWORD
3. Value: dckr_pat_XXXXX... (cole o token)
4. Clique em "Add secret"
```

### [ ] Passo 4: Fazer Push
```bash
cd C:\Users\Daniel Pontes\source\repos\AgroSolution

git commit --allow-empty -m "retry: docker hub login"
git push origin master
```

---

## ✨ Verificação

```
GitHub → Actions → Build and Push Docker Images
├─ Free up disk space      ✅
├─ Set up Docker Buildx    ✅
├─ Login to Docker Hub     ✅ ← Deve estar aqui
├─ Build services          ✅
└─ post-build              ✅
```

---

## 🎯 Tempo Total
- Gerar token: ~1 min
- Adicionar secrets: ~2 min
- Push: ~1 min
- Build: ~4-5 min

**Total: ~8-10 minutos**

---

**Pronto!** Seu GitHub Actions conseguirá fazer login no Docker Hub! 🚀

*Checklist criado em: 2026-02-26*
