using AgroSolutions.Sensors.Api.DTOs;
using AgroSolutions.Sensors.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AgroSolutions.Sensors.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class SensorsController : ControllerBase
{
    private readonly ISensorDataService _sensorDataService;

    public SensorsController(ISensorDataService sensorDataService)
    {
        _sensorDataService = sensorDataService;
    }

    [HttpPost("ingest")]
    [ProducesResponseType(typeof(SensorDataResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Ingest([FromBody] SensorDataRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (request.TalhaoId == Guid.Empty)
        {
            return BadRequest(new { error = "TalhaoId e obrigatorio" });
        }

        if (request.UmidadeSolo < 0 || request.UmidadeSolo > 100)
        {
            return BadRequest(new { error = "UmidadeSolo deve estar entre 0 e 100" });
        }

        var result = await _sensorDataService.AddSensorDataAsync(request);
        return CreatedAtAction(nameof(GetByTalhao), new { talhaoId = result.TalhaoId }, result);
    }

    [HttpGet("talhao/{talhaoId:guid}")]
    [ProducesResponseType(typeof(IReadOnlyCollection<SensorDataResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByTalhao(Guid talhaoId, [FromQuery] DateTime? start, [FromQuery] DateTime? end)
    {
        if (talhaoId == Guid.Empty)
        {
            return BadRequest(new { error = "TalhaoId e obrigatorio" });
        }

        var results = await _sensorDataService.GetSensorDataAsync(talhaoId, start, end);
        return Ok(results);
    }

    [HttpGet("health")]
    [AllowAnonymous]
    public IActionResult Health()
    {
        return Ok(new { service = "Sensors API", status = "Healthy", timestamp = DateTime.UtcNow });
    }
}
