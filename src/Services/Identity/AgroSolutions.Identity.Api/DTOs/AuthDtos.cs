namespace AgroSolutions.Identity.Api.DTOs;

/// <summary>
/// Requisição para registro de novo usuário
/// </summary>
public record RegisterRequest(
    string Nome,
    string Email,
    string Password,
    string? Telefone = null,
    string? Cpf = null
);

/// <summary>
/// Requisição para login de usuário
/// </summary>
public record LoginRequest(
    string Email,
    string Password
);

/// <summary>
/// Resposta de autenticação com token JWT
/// </summary>
public record AuthResponse(
    Guid Id,
    string Nome,
    string Email,
    string Token,
    DateTime ExpiresAt
);

/// <summary>
/// Resposta de dados do usuário
/// </summary>
public record UserResponse(
    Guid Id,
    string Nome,
    string Email,
    string? Telefone,
    string? Cpf,
    DateTime DataCadastro,
    bool Ativo
);
