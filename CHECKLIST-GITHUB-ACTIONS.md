# ✅ GitHub Actions Setup - Checklist Interativo

## 🎯 Objetivo
Automatizar o build e push de imagens Docker para o Docker Hub quando há merge na master.

---

## 📋 FASE 1: Preparação (5-10 minutos)

### 1.1 Verificar Conta GitHub
- [ ] Você tem uma conta no GitHub
- [ ] Você é owner ou tem permissão de admin no repositório
- [ ] O repositório é `dtpontes/AgroSolution`

### 1.2 Verificar Conta Docker Hub
- [ ] Você tem uma conta no [Docker Hub](https://hub.docker.com)
- [ ] Você está logado no Docker Hub

**Se não tem conta**: [Criar agora](https://hub.docker.com/signup)

### 1.3 Verificar Dockerfiles
```bash
# Verifique se todos os 4 Dockerfiles existem:
ls -la src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile
ls -la src/Services/Properties/AgroSolutions.Properties.Api/Dockerfile
ls -la src/Services/Sensors/AgroSolutions.Sensors.Api/Dockerfile
ls -la src/Services/Alerts/AgroSolutions.Alerts.API/Dockerfile
```

- [ ] Todos os 4 Dockerfiles existem
- [ ] Todos fazem build sem erros localmente

---

## 📋 FASE 2: Gerar Credenciais Docker Hub (5 minutos)

### 2.1 Acessar Docker Hub
1. [ ] Vá para https://hub.docker.com
2. [ ] Clique no seu avatar (canto superior direito)
3. [ ] Clique em **Account Settings**

### 2.2 Gerar Access Token
1. [ ] No menu lateral, clique em **Security**
2. [ ] Clique em **New Access Token**
3. [ ] Preencha:
   ```
   Access Token Description: github-actions
   Permissions: Read & Write (padrão)
   ```
4. [ ] Clique em **Generate**
5. [ ] **COPIE o token** que aparecerá
   ```
   Seu token será como: dckr_pat_xxxxxxxxxxxxxx
   ```
6. [ ] **SALVE em um lugar seguro** (será deletado após sair da página!)

- [ ] Access Token gerado e copiado
- [ ] Token salvo em um arquivo seguro (não git!)

---

## 📋 FASE 3: Adicionar Secrets no GitHub (5 minutos)

### 3.1 Acessar Settings do Repositório
1. [ ] Vá para https://github.com/dtpontes/AgroSolution
2. [ ] Clique na aba **Settings**
3. [ ] No menu lateral, procure **Security**
4. [ ] Clique em **Secrets and variables**
5. [ ] Clique em **Actions**

### 3.2 Adicionar Secret #1: DOCKER_USERNAME
1. [ ] Clique em **New repository secret**
2. [ ] Preencha:
   ```
   Name:  DOCKER_USERNAME
   Value: seu-username-docker-hub
   ```
3. [ ] Clique em **Add secret**

Resultado esperado:
```
✓ DOCKER_USERNAME    Added secrets/actions/DOCKER_USERNAME
```

### 3.3 Adicionar Secret #2: DOCKER_PASSWORD
1. [ ] Clique novamente em **New repository secret**
2. [ ] Preencha:
   ```
   Name:  DOCKER_PASSWORD
   Value: dckr_pat_xxxxxxxxxxxxxx
   ```
3. [ ] Clique em **Add secret**

Resultado esperado:
```
✓ DOCKER_PASSWORD    Added secrets/actions/DOCKER_PASSWORD
```

- [ ] Ambos os secrets adicionados e visíveis na lista

---

## 📋 FASE 4: Verificar Arquivos do Workflow (2 minutos)

Verifique se os seguintes arquivos existem no repositório:

```bash
# Deve existir:
ls .github/workflows/docker-build-push.yml

# Deve existir (scripts locais para testar):
ls scripts/docker-build-push.ps1
ls scripts/docker-build-push.sh
```

- [ ] `.github/workflows/docker-build-push.yml` existe
- [ ] `scripts/docker-build-push.ps1` existe
- [ ] `scripts/docker-build-push.sh` existe

---

## 📋 FASE 5: Teste Local (OPCIONAL - 5 minutos)

### 5.1 Teste no Windows (PowerShell)
```powershell
# Abra o terminal PowerShell na raiz do projeto

# Teste 1: Apenas build (sem push)
.\scripts\docker-build-push.ps1 -DockerUsername "seu-username-docker"

# Se passou ✅, tente fazer push:
# .\scripts\docker-build-push.ps1 -DockerUsername "seu-username-docker" -Push
```

### 5.2 Teste no Linux/Mac (Bash)
```bash
# Abra o terminal na raiz do projeto

# Teste 1: Apenas build (sem push)
chmod +x ./scripts/docker-build-push.sh
./scripts/docker-build-push.sh -u "seu-username-docker"

# Se passou ✅, tente fazer push:
# ./scripts/docker-build-push.sh -u "seu-username-docker" -p
```

Resultado esperado:
```
✅ Build: 4/4 sucessos
✅ Imagens: identity-api, properties-api, sensors-api, alerts-api
✅ Pronto para usar
```

- [ ] Build local funcionou
- [ ] Nenhum erro ao executar scripts

---

## 📋 FASE 6: Fazer Push na Master (2 minutos)

### 6.1 Commit dos Arquivos do Workflow
```bash
# Na raiz do seu repositório:
git add .github/workflows/docker-build-push.yml
git add scripts/docker-build-push.ps1
git add scripts/docker-build-push.sh
git add GITHUB-ACTIONS-*.md
git add README-GITHUB-ACTIONS.md

git commit -m "chore: add github actions for docker hub push"

git push origin master
```

- [ ] Arquivos commitados
- [ ] Push enviado para master

### 6.2 Monitorar Workflow no GitHub
1. [ ] Vá para https://github.com/dtpontes/AgroSolution/actions
2. [ ] Procure pelo workflow **Build and Push Docker Images**
3. [ ] Clique para abrir e ver detalhes

Status esperado:
```
✅ Workflow run - All jobs completed successfully

Jobs:
  ✅ build-and-push [identity-api]      - Success
  ✅ build-and-push [properties-api]    - Success
  ✅ build-and-push [sensors-api]       - Success
  ✅ build-and-push [alerts-api]        - Success
  ✅ post-build                          - Success
```

**Se não aparecer**: Aguarde 1-2 minutos e recarregue a página.

- [ ] Workflow apareceu na aba Actions
- [ ] Status: ✅ Sucesso (badges verdes)
- [ ] Todos os 4 jobs completaram com sucesso

---

## 📋 FASE 7: Verificar Imagens no Docker Hub (3 minutos)

### 7.1 Acessar Docker Hub Repositories
1. [ ] Vá para https://hub.docker.com/repositories
2. [ ] Procure por seus repositórios:
   ```
   agrosolution-identity-api
   agrosolution-properties-api
   agrosolution-sensors-api
   agrosolution-alerts-api
   ```

### 7.2 Verificar Tags
Para cada repositório, clique e veja as tags:
- [ ] `:latest` deve estar presente
- [ ] `:xxxxxx` (commit SHA) deve estar presente
- [ ] Data de push atual

Exemplo:
```
agrosolution-identity-api
├─ latest         (a few seconds ago)
└─ a1b2c3d        (a few seconds ago)
```

- [ ] Todas as 4 imagens aparecem no Docker Hub
- [ ] Cada uma tem as tags `:latest` e `:SHORT_SHA`

---

## 📋 FASE 8: Testar Pull da Imagem (3 minutos)

### 8.1 Fazer Pull Local
```bash
# Escolha uma imagem
docker pull seu-username/agrosolution-identity-api:latest

# Ou com versão específica
docker pull seu-username/agrosolution-identity-api:a1b2c3d
```

Status esperado:
```
latest: Pulling from seu-username/agrosolution-identity-api
Digest: sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Status: Downloaded newer image for seu-username/agrosolution-identity-api:latest
```

### 8.2 Verificar Imagem Local
```bash
docker images | grep agrosolution-identity-api
```

Status esperado:
```
seu-username/agrosolution-identity-api   latest   abc1234   5 minutes ago   500MB
seu-username/agrosolution-identity-api   a1b2c3d  abc1234   5 minutes ago   500MB
```

- [ ] Conseguiu fazer pull da imagem
- [ ] Imagem aparece em `docker images`

---

## 📋 FASE 9: Atualizar docker-compose.yml (OPCIONAL - 5 minutos)

Se quiser usar as imagens do Docker Hub em produção:

### 9.1 Editar docker-compose.yml
```yaml
# Antes (build local):
services:
  identity-api:
    build:
      context: .
      dockerfile: src/Services/Identity/AgroSolutions.Identity.Api/Dockerfile

# Depois (pull do Docker Hub):
services:
  identity-api:
    image: seu-username/agrosolution-identity-api:latest
```

- [ ] docker-compose.yml atualizado (OPCIONAL)
- [ ] Todas as 4 APIs apontam para Docker Hub

---

## ✅ VERIFICAÇÃO FINAL - Checklist Resumido

Antes de considerar concluído, confirme:

### Credenciais
- [ ] Access Token gerado no Docker Hub
- [ ] `DOCKER_USERNAME` adicionado no GitHub Secrets
- [ ] `DOCKER_PASSWORD` adicionado no GitHub Secrets

### Código
- [ ] Arquivo `.github/workflows/docker-build-push.yml` existe
- [ ] Scripts `docker-build-push.ps1` e `docker-build-push.sh` existem
- [ ] Todos os Dockerfiles são válidos

### Execução
- [ ] Workflow foi disparado após push na master
- [ ] Workflow completou com ✅ sucesso
- [ ] Todas as 4 imagens foram buildadas
- [ ] Todas as 4 imagens foram pushadas para Docker Hub

### Validação
- [ ] Imagens aparecem no Docker Hub com `:latest`
- [ ] Imagens têm tag `:SHORT_SHA`
- [ ] Consegue fazer `docker pull` da imagem
- [ ] Imagem roda sem erros

---

## 🎯 Próximas Melhorias (OPCIONAL)

Depois que tudo estiver funcionando:

- [ ] Adicionar notificações Slack/Discord ao workflow
- [ ] Adicionar scan de segurança (Trivy)
- [ ] Usar versioning semântico (git tags v1.0.0)
- [ ] Deploy automático após push
- [ ] Gerar release notes automaticamente

---

## 🆘 Problemas? Consulte

1. **Erro de credenciais?** → `GITHUB-ACTIONS-SETUP-PASSO-A-PASSO.md`
2. **Workflow não apareceu?** → Verifique branch (deve ser `master`)
3. **Build falhou?** → Veja logs no GitHub Actions
4. **Dockerfile inválido?** → Teste localmente: `docker build -f ...`
5. **Dúvidas gerais?** → Leia `README-GITHUB-ACTIONS.md`

---

## 🎉 Parabéns!

Quando todos os checkboxes acima estiverem ✅, você completou com sucesso!

Seu pipeline de CI/CD com GitHub Actions está funcionando perfeitamente! 🚀

**Agora sempre que você fazer push na master:**
1. GitHub Actions é disparado automaticamente
2. Suas imagens Docker são buildadas
3. São enviadas automaticamente para Docker Hub
4. Você pode usar em qualquer lugar com `docker pull`

---

## 📞 Suporte

Se tiver dúvidas:
- Consulte os arquivos README-* neste repositório
- Verifique documentação oficial: https://docs.github.com/en/actions
- Abra uma issue no GitHub

---

*Atualizado em: 2026-02-26*
*Status: ✅ Pronto para uso*
