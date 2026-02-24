namespace AgroSolutions.Properties.Api.Models;

public class Propriedade
{
    public Guid Id { get; set; }
    public Guid ProdutorId { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Localizacao { get; set; } = string.Empty;
    public decimal AreaTotal { get; set; }
    public DateTime DataCadastro { get; set; }

    public List<Talhao> Talhoes { get; set; } = [];
}
