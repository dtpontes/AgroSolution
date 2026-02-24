using AgroSolutions.Sensors.Api.Data;
using AgroSolutions.Sensors.Api.DTOs;
using AgroSolutions.Shared.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Sensors.Api.Services;

public interface ISensorDataService
{
    Task<SensorDataResponse> AddSensorDataAsync(SensorDataRequest request);
    Task<IReadOnlyCollection<SensorDataResponse>> GetSensorDataAsync(Guid talhaoId, DateTime? start, DateTime? end);
}

public class SensorDataService : ISensorDataService
{
    private readonly SensorsDbContext _context;
    private readonly ILogger<SensorDataService> _logger;

    public SensorDataService(SensorsDbContext context, ILogger<SensorDataService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<SensorDataResponse> AddSensorDataAsync(SensorDataRequest request)
    {
        var sensorData = new SensorData
        {
            Id = Guid.NewGuid(),
            TalhaoId = request.TalhaoId,
            Timestamp = DateTime.UtcNow,
            UmidadeSolo = request.UmidadeSolo,
            Temperatura = request.Temperatura,
            Precipitacao = request.Precipitacao
        };

        _context.SensorData.Add(sensorData);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Dados de sensor registrados: {SensorDataId} - Talhao {TalhaoId}", sensorData.Id, sensorData.TalhaoId);

        return Map(sensorData);
    }

    public async Task<IReadOnlyCollection<SensorDataResponse>> GetSensorDataAsync(Guid talhaoId, DateTime? start, DateTime? end)
    {
        var query = _context.SensorData.AsNoTracking()
            .Where(s => s.TalhaoId == talhaoId);

        if (start.HasValue)
        {
            query = query.Where(s => s.Timestamp >= start.Value);
        }

        if (end.HasValue)
        {
            query = query.Where(s => s.Timestamp <= end.Value);
        }

        var results = await query
            .OrderByDescending(s => s.Timestamp)
            .ToListAsync();

        return results.Select(Map).ToList();
    }

    private static SensorDataResponse Map(SensorData data)
        => new(
            data.Id,
            data.TalhaoId,
            data.Timestamp,
            data.UmidadeSolo,
            data.Temperatura,
            data.Precipitacao
        );
}
