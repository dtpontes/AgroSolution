namespace AgroSolutions.Shared.Models;

/// <summary>
/// Dados capturados dos sensores de campo
/// </summary>
public class SensorData
{
    public Guid Id { get; set; }
    public Guid TalhaoId { get; set; }
    public DateTime Timestamp { get; set; }
    public decimal UmidadeSolo { get; set; } // Percentual (0-100%)
    public decimal Temperatura { get; set; } // Celsius
    public decimal Precipitacao { get; set; } // Milímetros
}
