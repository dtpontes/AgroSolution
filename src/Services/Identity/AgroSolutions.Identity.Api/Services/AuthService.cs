using AgroSolutions.Identity.Api.Data;
using AgroSolutions.Identity.Api.DTOs;
using AgroSolutions.Identity.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AgroSolutions.Identity.Api.Services;

/// <summary>
/// Interface para o serviço de autenticação
/// </summary>
public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
    Task<AuthResponse?> LoginAsync(LoginRequest request);
    Task<UserResponse?> GetUserByIdAsync(Guid userId);
}

/// <summary>
/// Serviço de autenticação e gerenciamento de usuários
/// </summary>
public class AuthService : IAuthService
{
    private readonly IdentityDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IdentityDbContext context,
        IConfiguration configuration,
        ILogger<AuthService> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request)
    {
        try
        {
            // Validar se o email já existe
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                _logger.LogWarning("Tentativa de registro com email já existente: {Email}", request.Email);
                return null;
            }

            // Validar se o CPF já existe (se fornecido)
            if (!string.IsNullOrEmpty(request.Cpf) &&
                await _context.Users.AnyAsync(u => u.Cpf == request.Cpf))
            {
                _logger.LogWarning("Tentativa de registro com CPF já existente: {Cpf}", request.Cpf);
                return null;
            }

            // Criar novo usuário
            var user = new User
            {
                Id = Guid.NewGuid(),
                Nome = request.Nome,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Telefone = request.Telefone,
                Cpf = request.Cpf,
                DataCadastro = DateTime.UtcNow,
                Ativo = true
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Novo usuário registrado: {UserId} - {Email}", user.Id, user.Email);

            // Gerar token JWT
            var token = GenerateJwtToken(user);
            var expiresAt = DateTime.UtcNow.AddHours(8);

            return new AuthResponse(user.Id, user.Nome, user.Email, token, expiresAt);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao registrar usuário: {Email}", request.Email);
            return null;
        }
    }

    public async Task<AuthResponse?> LoginAsync(LoginRequest request)
    {
        try
        {
            // Buscar usuário por email
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email && u.Ativo);

            if (user == null)
            {
                _logger.LogWarning("Tentativa de login com email não encontrado: {Email}", request.Email);
                return null;
            }

            // Verificar senha
            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                _logger.LogWarning("Tentativa de login com senha incorreta: {Email}", request.Email);
                return null;
            }

            _logger.LogInformation("Login bem-sucedido: {UserId} - {Email}", user.Id, user.Email);

            // Gerar token JWT
            var token = GenerateJwtToken(user);
            var expiresAt = DateTime.UtcNow.AddHours(8);

            return new AuthResponse(user.Id, user.Nome, user.Email, token, expiresAt);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao realizar login: {Email}", request.Email);
            return null;
        }
    }

    public async Task<UserResponse?> GetUserByIdAsync(Guid userId)
    {
        try
        {
            var user = await _context.Users
                .Where(u => u.Id == userId && u.Ativo)
                .Select(u => new UserResponse(
                    u.Id,
                    u.Nome,
                    u.Email,
                    u.Telefone,
                    u.Cpf,
                    u.DataCadastro,
                    u.Ativo
                ))
                .FirstOrDefaultAsync();

            return user;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar usuário: {UserId}", userId);
            return null;
        }
    }

    private string GenerateJwtToken(User user)
    {
        var jwtKey = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key não configurada");
        var jwtIssuer = _configuration["Jwt:Issuer"] ?? "AgroSolutions";
        var jwtAudience = _configuration["Jwt:Audience"] ?? "AgroSolutions";

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.Nome),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim(JwtRegisteredClaimNames.Iat, DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(8),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
