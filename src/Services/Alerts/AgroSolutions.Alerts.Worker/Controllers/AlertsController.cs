using AgroSolutions.Alerts.Worker.DTOs;
using AgroSolutions.Alerts.Worker.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AgroSolutions.Alerts.Worker.Controllers;

[Authorize]
[ApiController]
[Route("api/alerts")]
public class AlertsController : ControllerBase
{
    private readonly IAlertStatusService _statusService;

    public AlertsController(IAlertStatusService statusService)
    {
        _statusService = statusService;
    }

    [HttpGet("talhoes/{talhaoId:guid}/status")]
    [ProducesResponseType(typeof(AlertStatusResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStatus(Guid talhaoId)
    {
        if (talhaoId == Guid.Empty)
        {
            return BadRequest(new { error = "TalhaoId e obrigatorio" });
        }

        var status = await _statusService.GetStatusAsync(talhaoId);
        return Ok(status);
    }

    [HttpGet("talhoes/{talhaoId:guid}/dashboard")]
    [ProducesResponseType(typeof(DashboardResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDashboard(Guid talhaoId, [FromQuery] DateTime? start, [FromQuery] DateTime? end)
    {
        if (talhaoId == Guid.Empty)
        {
            return BadRequest(new { error = "TalhaoId e obrigatorio" });
        }

        var dashboard = await _statusService.GetDashboardAsync(talhaoId, start, end);
        return Ok(dashboard);
    }

    [HttpGet("health")]
    [AllowAnonymous]
    public IActionResult Health()
    {
        return Ok(new { service = "Alerts API", status = "Healthy", timestamp = DateTime.UtcNow });
    }
}
