# 🌱 AgroSolution - Observabilidade, APIs e CI/CD

Este projeto contém múltiplas APIs .NET 9, bancos PostgreSQL, mensageria RabbitMQ, e observabilidade com Prometheus + Grafana, tudo orquestrado via Docker Compose. O pipeline CI/CD faz build e push automático das imagens para o Docker Hub usando GitHub Actions.

---

## 🚀 Como rodar tudo localmente

1. **Pré-requisitos:**
   - Docker e Docker Compose instalados
   - .NET 9 SDK (apenas se for rodar/testar fora do Docker)

2. **Subir toda a stack:**
   ```bash
   docker-compose up -d --build
   ```
   Isso irá:
   - Buildar as imagens das APIs
   - Subir bancos, RabbitMQ, Prometheus e Grafana

3. **Parar tudo:**
   ```bash
   docker-compose down
   ```

---

## 🌐 URLs dos Serviços

| Serviço         | URL/localhost         | Observações                  |
|----------------|----------------------|------------------------------|
| Identity API   | http://localhost:8081 | Swagger na raiz              |
| Properties API | http://localhost:8082 | Swagger na raiz              |
| Sensors API    | http://localhost:8083 | Swagger na raiz              |
| Alerts API     | http://localhost:8084 | Swagger na raiz              |
| RabbitMQ       | http://localhost:15672| guest/guest                  |
| Prometheus     | http://localhost:9091 | Dashboards de métricas       |
| Grafana        | http://localhost:3000 | admin/admin (primeiro acesso)|

- **Swagger:** basta acessar a raiz de cada API (ex: http://localhost:8081/)
- **Métricas Prometheus:** cada API expõe `/metrics` na porta 9090 (usado pelo Prometheus)

---

## 📊 Observabilidade

- **Prometheus** coleta métricas de todas as APIs automaticamente (veja `prometheus.yml`)
- **Grafana** já está configurado para conectar no Prometheus (importar dashboards .NET é opcional)
- Para criar dashboards .NET, use templates da comunidade ou importe pelo ID no Grafana

---

## 🐳 CI/CD com GitHub Actions + Docker Hub

- Push na branch `master` dispara build e push das imagens Docker para o Docker Hub
- Secrets necessários: `DOCKER_USERNAME` e `DOCKER_PASSWORD` (token do Docker Hub)
- Workflows principais:
  - `.github/workflows/docker-build-push.yml` (recomendado)
  - `.github/workflows/docker-build-push-advanced.yml` (opcional, com scan de segurança)

Veja instruções detalhadas de CI/CD nas seções abaixo.

---

## ⚡ Início Rápido do CI/CD (5 Minutos)

1. Adicione os Secrets no GitHub:
   - `DOCKER_USERNAME = seu-usuario-docker-hub`
   - `DOCKER_PASSWORD = dckr_pat_xxxxxxxxxxxxxxx`
2. Faça um push na master:
   ```bash
   git add .
   git commit -m "setup github actions"
   git push origin master
   ```
3. Monitore em GitHub → Actions
4. Veja as imagens no Docker Hub

---

## 📦 Estrutura dos Principais Arquivos

```
.github/workflows/
├── docker-build-push.yml          ← CI/CD principal
├── docker-build-push-advanced.yml ← CI/CD avançado

scripts/
├── docker-build-push.ps1          ← Build local (Windows)
├── docker-build-push.sh           ← Build local (Linux/Mac)

src/Services/
├── Identity/AgroSolutions.Identity.Api
├── Properties/AgroSolutions.Properties.Api
├── Sensors/AgroSolutions.Sensors.Api
├── Alerts/AgroSolutions.Alerts.API

prometheus.yml                     ← Configuração Prometheus
```

---

## 📝 Dicas e Troubleshooting

- Para ver logs de todos os serviços:
  ```bash
  docker-compose logs -f
  ```
- Para rebuildar tudo:
  ```bash
  docker-compose up -d --build
  ```
- Se algum serviço não sobe, veja os logs específicos:
  ```bash
  docker-compose logs <nome-do-serviço>
  ```
- Para limpar imagens antigas:
  ```bash
  docker image prune -a
  ```

---

## 📚 Documentação CI/CD

(Seções detalhadas do pipeline, troubleshooting, dicas de segurança, etc. permanecem como no README original)

---

*Última atualização: 2026-02-26*
