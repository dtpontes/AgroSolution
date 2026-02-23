namespace AgroSolutions.Shared.Models;

/// <summary>
/// Alerta gerado pelo sistema de monitoramento
/// </summary>
public class Alert
{
    public Guid Id { get; set; }
    public Guid TalhaoId { get; set; }
    public string Tipo { get; set; } = string.Empty; // "Seca", "TemperaturaAlta", "ChuvaExcessiva", "Praga"
    public string Mensagem { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
    public bool Resolvido { get; set; }
}
