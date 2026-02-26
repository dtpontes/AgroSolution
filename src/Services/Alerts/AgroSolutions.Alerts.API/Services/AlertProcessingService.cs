using AgroSolutions.Alerts.API.Data;
using AgroSolutions.Shared.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Alerts.API.Services;

public interface IAlertProcessingService
{
    Task ProcessAsync(CancellationToken stoppingToken);
}

public class AlertProcessingService : IAlertProcessingService
{
    private readonly AlertsDbContext _alertsDb;
    private readonly ILogger<AlertProcessingService> _logger;

    public AlertProcessingService(
        AlertsDbContext alertsDb,
        ILogger<AlertProcessingService> logger)
    {
        _alertsDb = alertsDb;
        _logger = logger;
    }

    public async Task ProcessAsync(CancellationToken stoppingToken)
    {
        var now = DateTime.UtcNow;
        var start24h = now.AddHours(-24);

        var recentData = await _alertsDb.SensorDataCache
            .AsNoTracking()
            .Where(s => s.Timestamp >= start24h)
            .ToListAsync(stoppingToken);

        var groups = recentData
            .GroupBy(s => s.TalhaoId)
            .ToList();

        foreach (var group in groups)
        {
            if (stoppingToken.IsCancellationRequested)
            {
                return;
            }

            var talhaoId = group.Key;

            await EvaluateDrynessAsync(talhaoId, group, stoppingToken);
            await EvaluateHighTemperatureAsync(talhaoId, group, stoppingToken);
            await EvaluateHighRainfallAsync(talhaoId, group, stoppingToken);
        }
    }

    private async Task EvaluateDrynessAsync(Guid talhaoId, IEnumerable<SensorData> readings, CancellationToken ct)
    {
        var readingsList = readings.ToList();
        var lowHumidityReadings = readingsList.Where(r => r.UmidadeSolo < 30).ToList();
        var isDry = lowHumidityReadings.Count >= 24 && lowHumidityReadings.All(r => r.UmidadeSolo < 30);

        if (isDry)
        {
            var avg = lowHumidityReadings.Average(r => r.UmidadeSolo);
            await EnsureAlertAsync(talhaoId, "Seca", $"Alerta de Seca: umidade media {avg:F1}% nas ultimas 24h", ct);
        }
        else
        {
            await ResolveAlertAsync(talhaoId, "Seca", ct);
        }
    }

    private async Task EvaluateHighTemperatureAsync(Guid talhaoId, IEnumerable<SensorData> readings, CancellationToken ct)
    {
        var maxTemp = readings.Max(r => r.Temperatura);
        if (maxTemp > 35)
        {
            await EnsureAlertAsync(talhaoId, "TemperaturaAlta", $"Alerta de Temperatura: {maxTemp:F1}°C", ct);
        }
        else
        {
            await ResolveAlertAsync(talhaoId, "TemperaturaAlta", ct);
        }
    }

    private async Task EvaluateHighRainfallAsync(Guid talhaoId, IEnumerable<SensorData> readings, CancellationToken ct)
    {
        var total = readings.Sum(r => r.Precipitacao);
        if (total > 50)
        {
            await EnsureAlertAsync(talhaoId, "ChuvaExcessiva", $"Alerta de Chuva: {total:F1}mm nas ultimas 24h", ct);
        }
        else
        {
            await ResolveAlertAsync(talhaoId, "ChuvaExcessiva", ct);
        }
    }

    private async Task EnsureAlertAsync(Guid talhaoId, string tipo, string mensagem, CancellationToken ct)
    {
        var exists = await _alertsDb.Alerts
            .AnyAsync(a => a.TalhaoId == talhaoId && a.Tipo == tipo && !a.Resolvido, ct);

        if (exists)
        {
            return;
        }

        var alert = new Alert
        {
            Id = Guid.NewGuid(),
            TalhaoId = talhaoId,
            Tipo = tipo,
            Mensagem = mensagem,
            DataCriacao = DateTime.UtcNow,
            Resolvido = false
        };

        _alertsDb.Alerts.Add(alert);
        await _alertsDb.SaveChangesAsync(ct);

        _logger.LogWarning("Alerta criado: {Tipo} - Talhao {TalhaoId}", tipo, talhaoId);
    }

    private async Task ResolveAlertAsync(Guid talhaoId, string tipo, CancellationToken ct)
    {
        var activeAlerts = await _alertsDb.Alerts
            .Where(a => a.TalhaoId == talhaoId && a.Tipo == tipo && !a.Resolvido)
            .ToListAsync(ct);

        if (activeAlerts.Count == 0)
        {
            return;
        }

        foreach (var alert in activeAlerts)
        {
            alert.Resolvido = true;
        }

        await _alertsDb.SaveChangesAsync(ct);

        _logger.LogInformation("Alerta resolvido: {Tipo} - Talhao {TalhaoId}", tipo, talhaoId);
    }
}
