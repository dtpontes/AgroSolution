using AgroSolutions.Properties.Api.Data;
using AgroSolutions.Properties.Api.DTOs;
using AgroSolutions.Properties.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Properties.Api.Services;

public interface IPropertiesService
{
    Task<IReadOnlyCollection<PropriedadeResponse>> GetPropriedadesAsync(Guid produtorId);
    Task<PropriedadeResponse?> CreatePropriedadeAsync(Guid produtorId, CreatePropriedadeRequest request);
    Task<TalhaoResponse?> AddTalhaoAsync(Guid produtorId, Guid propriedadeId, CreateTalhaoRequest request);
    Task<IReadOnlyCollection<TalhaoResponse>> GetTalhoesAsync(Guid produtorId, Guid propriedadeId);
}

public class PropertiesService : IPropertiesService
{
    private readonly PropertiesDbContext _context;
    private readonly ILogger<PropertiesService> _logger;

    public PropertiesService(PropertiesDbContext context, ILogger<PropertiesService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<IReadOnlyCollection<PropriedadeResponse>> GetPropriedadesAsync(Guid produtorId)
    {
        var propriedades = await _context.Propriedades
            .AsNoTracking()
            .Include(p => p.Talhoes)
            .Where(p => p.ProdutorId == produtorId)
            .OrderBy(p => p.Nome)
            .ToListAsync();

        return propriedades.Select(MapPropriedade).ToList();
    }

    public async Task<PropriedadeResponse?> CreatePropriedadeAsync(Guid produtorId, CreatePropriedadeRequest request)
    {
        var propriedade = new Propriedade
        {
            Id = Guid.NewGuid(),
            ProdutorId = produtorId,
            Nome = request.Nome,
            Localizacao = request.Localizacao,
            AreaTotal = request.AreaTotal,
            DataCadastro = DateTime.UtcNow
        };

        _context.Propriedades.Add(propriedade);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Propriedade criada: {PropriedadeId} - Produtor {ProdutorId}", propriedade.Id, produtorId);

        return MapPropriedade(propriedade);
    }

    public async Task<TalhaoResponse?> AddTalhaoAsync(Guid produtorId, Guid propriedadeId, CreateTalhaoRequest request)
    {
        var propriedade = await _context.Propriedades
            .FirstOrDefaultAsync(p => p.Id == propriedadeId && p.ProdutorId == produtorId);

        if (propriedade == null)
        {
            return null;
        }

        var talhao = new Talhao
        {
            Id = Guid.NewGuid(),
            PropriedadeId = propriedadeId,
            Nome = request.Nome,
            Area = request.Area,
            Cultura = request.Cultura,
            Status = "Normal",
            DataCadastro = DateTime.UtcNow
        };

        _context.Talhoes.Add(talhao);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Talhao criado: {TalhaoId} - Propriedade {PropriedadeId}", talhao.Id, propriedadeId);

        return MapTalhao(talhao);
    }

    public async Task<IReadOnlyCollection<TalhaoResponse>> GetTalhoesAsync(Guid produtorId, Guid propriedadeId)
    {
        var propriedadeExists = await _context.Propriedades
            .AnyAsync(p => p.Id == propriedadeId && p.ProdutorId == produtorId);

        if (!propriedadeExists)
        {
            return [];
        }

        var talhoes = await _context.Talhoes
            .AsNoTracking()
            .Where(t => t.PropriedadeId == propriedadeId)
            .OrderBy(t => t.Nome)
            .ToListAsync();

        return talhoes.Select(MapTalhao).ToList();
    }

    private static PropriedadeResponse MapPropriedade(Propriedade propriedade)
        => new(
            propriedade.Id,
            propriedade.Nome,
            propriedade.Localizacao,
            propriedade.AreaTotal,
            propriedade.DataCadastro,
            propriedade.Talhoes.Select(MapTalhao).ToList()
        );

    private static TalhaoResponse MapTalhao(Talhao talhao)
        => new(
            talhao.Id,
            talhao.PropriedadeId,
            talhao.Nome,
            talhao.Area,
            talhao.Cultura,
            talhao.Status,
            talhao.DataCadastro
        );
}
