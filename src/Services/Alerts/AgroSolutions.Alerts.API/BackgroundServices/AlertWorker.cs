using AgroSolutions.Alerts.API.Services;

namespace AgroSolutions.Alerts.API.BackgroundServices;

public class AlertWorker : BackgroundService
{
    private readonly ILogger<AlertWorker> _logger;
    private readonly IServiceProvider _serviceProvider;

    public AlertWorker(ILogger<AlertWorker> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Alerts Worker iniciado em {time}", DateTimeOffset.Now);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var processingService = scope.ServiceProvider.GetRequiredService<IAlertProcessingService>();
                await processingService.ProcessAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao processar alertas");
            }

            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}
