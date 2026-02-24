namespace AgroSolutions.Sensors.Api.DTOs;

public record SensorDataRequest(
    Guid TalhaoId,
    decimal UmidadeSolo,
    decimal Temperatura,
    decimal Precipitacao
);

public record SensorDataResponse(
    Guid Id,
    Guid TalhaoId,
    DateTime Timestamp,
    decimal UmidadeSolo,
    decimal Temperatura,
    decimal Precipitacao
);
