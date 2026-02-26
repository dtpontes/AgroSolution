# ⚡ QUICK REFERENCE - GitHub Actions + Docker Hub

## 🎯 TL;DR (Too Long; Didn't Read)

Quer setup rápido sem ler tudo? Aqui vai:

### 1. Gerar Token Docker Hub
```
hub.docker.com → Seu avatar → Account Settings → Security → New Access Token
Copie o token: dckr_pat_xxxxx...
```

### 2. Adicionar Secrets no GitHub
```
github.com/seu-repo → Settings → Secrets → Actions

DOCKER_USERNAME = seu-usuario
DOCKER_PASSWORD = dckr_pat_xxxxx...
```

### 3. Fazer Push
```bash
git push origin master
```

### 4. Ver Resultado
```
github.com/seu-repo → Actions → Build and Push Docker Images ✅
hub.docker.com → Repositories → Suas imagens lá!
```

**Fim!** 🚀

---

## 📚 Documentos por Tempo

- **5 min**: README-GITHUB-ACTIONS.md
- **10 min**: CHECKLIST-GITHUB-ACTIONS.md
- **15 min**: GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md
- **20 min**: GITHUB-ACTIONS-SETUP.md
- **30 min**: GITHUB-ACTIONS-ARCHITECTURE.md

---

## 🔍 Encontre Respostas Rápido

### "Como gero o token?"
→ GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md, Seção 2

### "Como adiciono secrets?"
→ GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md, Seção 3

### "Como monitoro o workflow?"
→ GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md, Seção 6

### "Como testo localmente?"
→ GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md, Seção 5

### "Como faço troubleshooting?"
→ GITHUB-ACTIONS-SETUP.md ou README-GITHUB-ACTIONS.md

### "Como funciona tudo?"
→ GITHUB-ACTIONS-ARCHITECTURE.md

---

## 🔧 Comandos Rápidos

### Testar Build Local (Windows)
```powershell
.\scripts\docker-build-push.ps1 -DockerUsername "seu-user"
```

### Testar Build Local (Linux/Mac)
```bash
./scripts/docker-build-push.sh -u "seu-user"
```

### Fazer Build + Push Local (Windows)
```powershell
.\scripts\docker-build-push.ps1 -DockerUsername "seu-user" -Push
```

### Fazer Build + Push Local (Linux/Mac)
```bash
./scripts/docker-build-push.sh -u "seu-user" -p
```

### Ver Logs do Workflow
```
GitHub → Actions → [Seu workflow] → [Seu job] → Expandir
```

### Puxar Imagem do Docker Hub
```bash
docker pull seu-user/agrosolution-identity-api:latest
```

---

## ✅ Checklist 2 Minutos

- [ ] Access Token gerado (Docker Hub)
- [ ] DOCKER_USERNAME adicionado (GitHub Secrets)
- [ ] DOCKER_PASSWORD adicionado (GitHub Secrets)
- [ ] `git push origin master` feito
- [ ] Workflow apareceu em GitHub → Actions
- [ ] Workflow completou com ✅
- [ ] Imagens aparecem em Docker Hub

Se tudo ✅, **PARABÉNS!** Está funcionando! 🎉

---

## 🚨 Erro Comum? Solução Rápida

| Erro | Solução |
|------|---------|
| `invalid username/password` | Verifica secrets no GitHub |
| `Dockerfile not found` | Verifica path do Dockerfile |
| Workflow não rodou | Fez push na `master`? Não em `develop`? |
| Build falhou | Vê logs no GitHub Actions |
| Push falhou | Token pode estar expirado, regenera |

---

## 📈 Fluxo Automático (Uma Linha)

```
Push na master → GitHub Actions → Build 4 imagens → Docker Hub → Docker pull!
```

---

## 🔐 Segurança - 30 Segundos

✅ Use **tokens de acesso**, não senhas  
✅ Secrets no GitHub são **criptografados**  
✅ **Nunca aparecem** em logs  
✅ **Regenere** tokens regularmente  

---

## 🎯 Próxima Vez Que Precisar

Quando precisar atualizar as imagens:

```bash
# Faz mudança no código
echo "novo código" >> src/...

# Push para master
git add .
git commit -m "update: nova feature"
git push origin master

# Pronto! GitHub Actions faz o resto automaticamente.
# Em ~4 minutos, imagens estão no Docker Hub com :latest
```

---

## 🎓 Aprender Mais

- GitHub Actions: https://docs.github.com/en/actions
- Docker BuildX: https://docs.docker.com/build/architecture/
- Docker Hub: https://docs.docker.com/docker-hub/

---

## 📞 Precisa de Ajuda?

1. Lê CHECKLIST-GITHUB-ACTIONS.md (checklist interativo)
2. Lê GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md (detalhado)
3. Google "github actions docker push"
4. Stack Overflow

---

## ✨ Pronto?

**Você está pronto para começar!** 🚀

Boa sorte! 🎉

---

*Reference Card - 2026-02-26*
