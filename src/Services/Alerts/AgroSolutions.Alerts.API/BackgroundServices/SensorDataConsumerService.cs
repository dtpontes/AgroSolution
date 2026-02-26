using AgroSolutions.Alerts.API.Data;
using AgroSolutions.Shared.Messaging;
using AgroSolutions.Shared.Models;

namespace AgroSolutions.Alerts.API.BackgroundServices;

public class SensorDataConsumerService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IMessageBus _messageBus;
    private readonly ILogger<SensorDataConsumerService> _logger;

    public SensorDataConsumerService(
        IServiceProvider serviceProvider,
        IMessageBus messageBus,
        ILogger<SensorDataConsumerService> logger)
    {
        _serviceProvider = serviceProvider;
        _messageBus = messageBus;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("SensorDataConsumer iniciado");

        await _messageBus.SubscribeAsync<SensorData>("sensor-data-queue", async (sensorData) =>
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<AlertsDbContext>();

            try
            {
                dbContext.SensorDataCache.Add(sensorData);
                await dbContext.SaveChangesAsync(stoppingToken);

                _logger.LogInformation("Dados de sensor armazenados: {SensorDataId} - Talhao {TalhaoId}",
                    sensorData.Id, sensorData.TalhaoId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao processar dados do sensor: {SensorDataId}", sensorData.Id);
                throw;
            }
        });

        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
        }
    }
}
