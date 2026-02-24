using AgroSolutions.Properties.Api.DTOs;
using AgroSolutions.Properties.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AgroSolutions.Properties.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class PropriedadesController : ControllerBase
{
    private readonly IPropertiesService _propertiesService;
    private readonly ILogger<PropriedadesController> _logger;

    public PropriedadesController(IPropertiesService propertiesService, ILogger<PropriedadesController> logger)
    {
        _propertiesService = propertiesService;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyCollection<PropriedadeResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPropriedades()
    {
        var produtorId = GetProdutorId();
        if (produtorId == null)
        {
            return Unauthorized(new { error = "Token invalido" });
        }

        var propriedades = await _propertiesService.GetPropriedadesAsync(produtorId.Value);
        return Ok(propriedades);
    }

    [HttpPost]
    [ProducesResponseType(typeof(PropriedadeResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreatePropriedade([FromBody] CreatePropriedadeRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (string.IsNullOrWhiteSpace(request.Nome))
        {
            return BadRequest(new { error = "Nome da propriedade e obrigatorio" });
        }

        if (request.AreaTotal <= 0)
        {
            return BadRequest(new { error = "Area total deve ser maior que zero" });
        }

        var produtorId = GetProdutorId();
        if (produtorId == null)
        {
            return Unauthorized(new { error = "Token invalido" });
        }

        var propriedade = await _propertiesService.CreatePropriedadeAsync(produtorId.Value, request);
        if (propriedade == null)
        {
            return BadRequest(new { error = "Falha ao criar propriedade" });
        }

        _logger.LogInformation("Propriedade criada para produtor {ProdutorId}", produtorId.Value);
        return CreatedAtAction(nameof(GetPropriedades), new { id = propriedade.Id }, propriedade);
    }

    [HttpPost("{propriedadeId:guid}/talhoes")]
    [ProducesResponseType(typeof(TalhaoResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AddTalhao(Guid propriedadeId, [FromBody] CreateTalhaoRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (string.IsNullOrWhiteSpace(request.Nome))
        {
            return BadRequest(new { error = "Nome do talhao e obrigatorio" });
        }

        if (request.Area <= 0)
        {
            return BadRequest(new { error = "Area do talhao deve ser maior que zero" });
        }

        if (string.IsNullOrWhiteSpace(request.Cultura))
        {
            return BadRequest(new { error = "Cultura e obrigatoria" });
        }

        var produtorId = GetProdutorId();
        if (produtorId == null)
        {
            return Unauthorized(new { error = "Token invalido" });
        }

        var talhao = await _propertiesService.AddTalhaoAsync(produtorId.Value, propriedadeId, request);
        if (talhao == null)
        {
            return NotFound(new { error = "Propriedade nao encontrada" });
        }

        _logger.LogInformation("Talhao criado para propriedade {PropriedadeId}", propriedadeId);
        return CreatedAtAction(nameof(GetTalhoes), new { propriedadeId }, talhao);
    }

    [HttpGet("{propriedadeId:guid}/talhoes")]
    [ProducesResponseType(typeof(IReadOnlyCollection<TalhaoResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetTalhoes(Guid propriedadeId)
    {
        var produtorId = GetProdutorId();
        if (produtorId == null)
        {
            return Unauthorized(new { error = "Token invalido" });
        }

        var talhoes = await _propertiesService.GetTalhoesAsync(produtorId.Value, propriedadeId);
        return Ok(talhoes);
    }

    private Guid? GetProdutorId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.TryParse(claim, out var produtorId) ? produtorId : null;
    }
}
