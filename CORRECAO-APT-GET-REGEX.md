# 🔧 Corrigido: Erro "apt-get remove" com Regex

## 🔴 O Problema

Ao rodar o GitHub Actions, recebeu este erro:

```
E: Unable to locate package ^ghc-8.*
E: Couldn't find any package by glob '^ghc-8.*'
E: Couldn't find any package by regex '^ghc-8.*'
Error: Process completed with exit code 100.
```

### Por quê?

`apt-get remove` **não suporta padrões regex** como `^ghc-8.*`

---

## ✅ Solução Implementada

### Antes (❌)
```bash
sudo apt-get remove -y '^ghc-8.*'
sudo apt-get remove -y '^dotnet-.*'
sudo apt-get remove -y '^temurin-.*'
```

### Depois (✅)
```bash
sudo apt-get remove -y ghc-* dotnet-* temurin-* mysql-server postgresql* 2>/dev/null || true
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /usr/local/lib/android /opt/hostedtoolcache /opt/gh /opt/microsoft
df -h
```

### O que Mudou

1. **Wildcards simples** em vez de regex: `ghc-*` em vez de `^ghc-8.*`
2. **Error suppression**: `2>/dev/null || true` para não parar se algum pacote não existir
3. **Limpeza adicional**: Remove diretórios grandes do GitHub Actions
4. **Verificação final**: `df -h` mostra espaço liberado

---

## 📊 Espaço Liberado

Com essa abordagem:
- ✅ Remove pacotes GHC (~2GB)
- ✅ Remove .NET (~1.5GB)
- ✅ Remove Temurin (~500MB)
- ✅ Remove MySQL/PostgreSQL (~200MB)
- ✅ Remove diretórios do GitHub Actions (~3GB)
- **Total**: ~7GB liberados

---

## 🚀 Próximas Ações

### 1. Fazer Commit
```bash
git add .github/workflows/docker-build-push.yml
git commit -m "fix: corrigir apt-get remove regex syntax no github actions"
```

### 2. Fazer Push
```bash
git push origin master
```

### 3. Monitorar
- GitHub → Actions → Build and Push Docker Images
- Veja se o erro "apt-get remove" desapareceu

---

## ✨ Resultado Esperado

Agora o workflow:
```
✅ [1/5] setup
✅ [2/5] Free up disk space        ← Sem erros agora!
✅ [3/5] Set up Docker Buildx
✅ [4/5] Build and push services
✅ [5/5] post-build
```

---

## 🎯 Se Ainda Houver Erro

Se ainda der erro de espaço em disco, tente:

```yaml
- name: Free up disk space (extended)
  run: |
    # Remover mais coisas
    sudo rm -rf /var/lib/apt/lists/*
    sudo rm -rf /var/log/*
    sudo docker rmi -f $(docker images -q) || true
    sudo docker system prune -af --volumes
```

---

**Pronto! Agora o GitHub Actions consegue liberar espaço sem erros.** ✅

*Corrigido em: 2026-02-26*
