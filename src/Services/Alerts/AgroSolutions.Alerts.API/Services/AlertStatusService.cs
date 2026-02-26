using AgroSolutions.Alerts.API.Data;
using AgroSolutions.Alerts.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Alerts.API.Services;

public interface IAlertStatusService
{
    Task<AlertStatusResponse> GetStatusAsync(Guid talhaoId);
    Task<DashboardResponse> GetDashboardAsync(Guid talhaoId, DateTime? start, DateTime? end);
}

public class AlertStatusService : IAlertStatusService
{
    private readonly AlertsDbContext _alertsDb;

    public AlertStatusService(AlertsDbContext alertsDb)
    {
        _alertsDb = alertsDb;
    }

    public async Task<AlertStatusResponse> GetStatusAsync(Guid talhaoId)
    {
        var alerts = await GetActiveAlertsAsync(talhaoId);
        var status = ResolveStatus(alerts);

        return new AlertStatusResponse(
            talhaoId,
            status,
            alerts,
            DateTime.UtcNow
        );
    }

    public async Task<DashboardResponse> GetDashboardAsync(Guid talhaoId, DateTime? start, DateTime? end)
    {
        var alerts = await GetActiveAlertsAsync(talhaoId);
        var status = ResolveStatus(alerts);

        var query = _alertsDb.SensorDataCache.AsNoTracking()
            .Where(s => s.TalhaoId == talhaoId);

        if (start.HasValue)
        {
            query = query.Where(s => s.Timestamp >= start.Value);
        }

        if (end.HasValue)
        {
            query = query.Where(s => s.Timestamp <= end.Value);
        }

        var readings = await query
            .OrderByDescending(s => s.Timestamp)
            .Take(1000)
            .Select(s => new SensorDataPoint(
                s.Id,
                s.TalhaoId,
                s.Timestamp,
                s.UmidadeSolo,
                s.Temperatura,
                s.Precipitacao))
            .ToListAsync();

        return new DashboardResponse(talhaoId, status, alerts, readings);
    }

    private async Task<List<AlertSummary>> GetActiveAlertsAsync(Guid talhaoId)
    {
        return await _alertsDb.Alerts
            .AsNoTracking()
            .Where(a => a.TalhaoId == talhaoId && !a.Resolvido)
            .OrderByDescending(a => a.DataCriacao)
            .Select(a => new AlertSummary(a.Id, a.Tipo, a.Mensagem, a.DataCriacao))
            .ToListAsync();
    }

    private static string ResolveStatus(IReadOnlyCollection<AlertSummary> alerts)
    {
        if (alerts.Any(a => a.Tipo == "Seca"))
        {
            return "Alerta de Seca";
        }

        if (alerts.Any(a => a.Tipo == "Praga"))
        {
            return "Risco de Praga";
        }

        if (alerts.Any(a => a.Tipo == "TemperaturaAlta"))
        {
            return "Alerta de Temperatura";
        }

        if (alerts.Any(a => a.Tipo == "ChuvaExcessiva"))
        {
            return "Alerta de Chuva";
        }

        return "Normal";
    }
}
