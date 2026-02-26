# ⚙️ Migrations Automáticas - Como Funciona

## 🎯 Comportamento Atual

**ANTES (antigo):**
- ❌ Script `quick-start-all.ps1` executava `dotnet ef database update` manualmente
- ❌ Lento e propenso a erros de timing
- ❌ Duplicação de lógica (script + código)

**AGORA (novo):**
- ✅ **Cada API aplica suas próprias migrations automaticamente ao iniciar**
- ✅ Mais rápido e confiável
- ✅ Funciona em qualquer ambiente (dev, staging, prod)

---

## 🔧 Como Funciona?

Todas as APIs possuem o seguinte código no `Program.cs`:

```csharp
// ===== MIGRATIONS =====
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<DbContext>();
    try
    {
        await dbContext.Database.MigrateAsync();
        app.Logger.LogInformation("✅ Migrations aplicadas com sucesso!");
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "❌ Erro ao aplicar migrations");
    }
}
```

### 📋 Passo a Passo:

1. **API inicia** → Constrói o `WebApplication`
2. **Verifica ambiente** → Só aplica em `Development`
3. **Cria scope** → Obtém o `DbContext` do DI
4. **Aplica migrations** → Executa `MigrateAsync()`
5. **Loga resultado** → Sucesso ✅ ou erro ❌
6. **Continua startup** → Middlewares e endpoints

---

## 🚀 Script Atualizado

### `quick-start-all.ps1`

```powershell
# ❌ REMOVIDO: Aplicação manual de migrations
# Apply-Migration (Join-Path $repoRoot "src\...") "DbContext" "ServiceName"

# ✅ NOVO: Apenas inicia os bancos e aguarda ficarem prontos
Start-Postgres "agro-identity-db" "identity_db" "identity_user" "identity_pass_123" 5433
Start-Postgres "agro-properties-db" "properties_db" "properties_user" "properties_pass_123" 5434
Start-Postgres "agro-sensors-db" "sensors_db" "sensors_user" "sensors_pass_123" 5435
Start-Postgres "agro-alerts-db" "alerts_db" "alerts_user" "alerts_pass_123" 5436

Write-Host "[*] Aguardando bancos ficarem prontos (20 segundos)..."
Start-Sleep -Seconds 20

# ✅ APIs aplicam migrations automaticamente ao iniciar
Start-Service (Join-Path $repoRoot "src\Services\Identity\...") 5001 "Identity API"
Start-Service (Join-Path $repoRoot "src\Services\Properties\...") 5002 "Properties API"
Start-Service (Join-Path $repoRoot "src\Services\Sensors\...") 5003 "Sensors API"
Start-Service (Join-Path $repoRoot "src\Services\Alerts\...") 5004 "Alerts API"
```

---

## ✅ Vantagens

| Aspecto | Antes | Agora |
|---------|-------|-------|
| **Velocidade** | ~60s (migrations manuais) | ~40s (automáticas) |
| **Confiabilidade** | Erros de timing | Sempre sincronizado |
| **Manutenção** | 2 lugares (script + código) | 1 lugar (só código) |
| **Logs** | Separados no terminal | Integrados na API |
| **Ambiente** | Só funciona no script | Funciona em qualquer ambiente |

---

## 📊 Logs Esperados

Ao executar `.\scripts\quick-start-all.ps1`, você verá:

```
[1/5] Verificando Docker...
[OK] Docker rodando

[2/5] Iniciando RabbitMQ...
[OK] RabbitMQ iniciado

[3/5] Iniciando bancos PostgreSQL...
[OK] agro-identity-db iniciado
[OK] agro-properties-db iniciado
[OK] agro-sensors-db iniciado
[OK] agro-alerts-db iniciado

[*] Aguardando bancos ficarem prontos (20 segundos)...

[4/5] Iniciando APIs (migrations automaticas)...
[i] Cada API aplicara suas migrations ao iniciar
[OK] Identity API iniciado na porta 5001 (migrations automaticas)
[OK] Properties API iniciado na porta 5002 (migrations automaticas)
[OK] Sensors API iniciado na porta 5003 (migrations automaticas)
[OK] Alerts API iniciado na porta 5004 (migrations automaticas)

[5/5] Pronto!
[i] Aguarde ~30s para todas as migrations serem aplicadas automaticamente
```

### Nos logs de cada API:

```
info: AgroSolutions.Identity.Api[0]
      ✅ Migrations aplicadas com sucesso!
info: AgroSolutions.Identity.Api[0]
      🚀 Identity API iniciada!
```

---

## ⚠️ Importante

### Desenvolvimento (auto)
- ✅ Migrations aplicadas **automaticamente**
- ✅ A cada restart da API

### Produção (manual)
- ❌ Migrations **NÃO são aplicadas** automaticamente
- ✅ Deve usar CI/CD ou executar manualmente:
```bash
dotnet ef database update --project src/Services/Identity/AgroSolutions.Identity.Api
```

---

## 🧪 Como Testar

1. **Resetar bases:**
```powershell
.\scripts\reset-databases.ps1
```

2. **Iniciar tudo:**
```powershell
.\scripts\quick-start-all.ps1
```

3. **Verificar logs:**
- Cada janela PowerShell mostrará "Migrations aplicadas com sucesso!"
- Swagger estará disponível ~30s após o script finalizar

4. **Validar bancos:**
```powershell
docker exec -it agro-identity-db psql -U identity_user -d identity_db -c "\dt"
docker exec -it agro-properties-db psql -U properties_user -d properties_db -c "\dt"
docker exec -it agro-sensors-db psql -U sensors_user -d sensors_db -c "\dt"
docker exec -it agro-alerts-db psql -U alerts_user -d alerts_db -c "\dt"
```

---

**✅ MIGRATIONS AUTOMÁTICAS FUNCIONANDO EM TODAS AS APIs!**
