using AgroSolutions.Identity.Api.DTOs;
using AgroSolutions.Identity.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AgroSolutions.Identity.Api.Controllers;

/// <summary>
/// Controller para autenticação e gerenciamento de usuários
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    /// <summary>
    /// Registra um novo produtor rural no sistema
    /// </summary>
    /// <param name="request">Dados para registro</param>
    /// <returns>Token de autenticação e dados do usuário</returns>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Validações básicas
        if (string.IsNullOrWhiteSpace(request.Nome))
        {
            return BadRequest(new { error = "Nome é obrigatório" });
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return BadRequest(new { error = "Email é obrigatório" });
        }

        if (string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 6)
        {
            return BadRequest(new { error = "Senha deve ter no mínimo 6 caracteres" });
        }

        var result = await _authService.RegisterAsync(request);

        if (result == null)
        {
            return BadRequest(new { error = "Email ou CPF já cadastrado" });
        }

        _logger.LogInformation("Usuário registrado com sucesso: {Email}", request.Email);
        return CreatedAtAction(nameof(GetMe), new { id = result.Id }, result);
    }

    /// <summary>
    /// Realiza login no sistema
    /// </summary>
    /// <param name="request">Credenciais de login</param>
    /// <returns>Token de autenticação e dados do usuário</returns>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return BadRequest(new { error = "Email é obrigatório" });
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { error = "Senha é obrigatória" });
        }

        var result = await _authService.LoginAsync(request);

        if (result == null)
        {
            return Unauthorized(new { error = "Email ou senha inválidos" });
        }

        _logger.LogInformation("Login realizado com sucesso: {Email}", request.Email);
        return Ok(result);
    }

    /// <summary>
    /// Obtém os dados do usuário autenticado
    /// </summary>
    /// <returns>Dados do usuário</returns>
    [Authorize]
    [HttpGet("me")]
    [ProducesResponseType(typeof(UserResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMe()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new { error = "Token inválido" });
        }

        var user = await _authService.GetUserByIdAsync(userId);

        if (user == null)
        {
            return NotFound(new { error = "Usuário não encontrado" });
        }

        return Ok(user);
    }

    /// <summary>
    /// Health check do serviço de autenticação
    /// </summary>
    [HttpGet("health")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult Health()
    {
        return Ok(new
        {
            service = "Identity API",
            status = "Healthy",
            timestamp = DateTime.UtcNow
        });
    }
}
