namespace AgroSolutions.Alerts.API.DTOs;

public record AlertSummary(
    Guid Id,
    string Tipo,
    string Mensagem,
    DateTime DataCriacao
);

public record AlertStatusResponse(
    Guid TalhaoId,
    string Status,
    IReadOnlyCollection<AlertSummary> AlertasAtivos,
    DateTime AtualizadoEm
);

public record SensorDataPoint(
    Guid Id,
    Guid TalhaoId,
    DateTime Timestamp,
    decimal UmidadeSolo,
    decimal Temperatura,
    decimal Precipitacao
);

public record DashboardResponse(
    Guid TalhaoId,
    string Status,
    IReadOnlyCollection<AlertSummary> AlertasAtivos,
    IReadOnlyCollection<SensorDataPoint> Leituras
);
