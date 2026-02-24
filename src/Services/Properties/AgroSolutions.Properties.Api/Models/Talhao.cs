namespace AgroSolutions.Properties.Api.Models;

public class Talhao
{
    public Guid Id { get; set; }
    public Guid PropriedadeId { get; set; }
    public string Nome { get; set; } = string.Empty;
    public decimal Area { get; set; }
    public string Cultura { get; set; } = string.Empty;
    public string Status { get; set; } = "Normal";
    public DateTime DataCadastro { get; set; }

    public Propriedade? Propriedade { get; set; }
}
