namespace AgroSolutions.Identity.Api.Models;

/// <summary>
/// Representa um usuário (Produtor Rural) no sistema
/// </summary>
public class User
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public DateTime DataCadastro { get; set; }
    public bool Ativo { get; set; } = true;
    public string? Telefone { get; set; }
    public string? Cpf { get; set; }
}
