namespace AgroSolutions.Properties.Api.DTOs;

public record CreatePropriedadeRequest(
    string Nome,
    string Localizacao,
    decimal AreaTotal
);

public record CreateTalhaoRequest(
    string Nome,
    decimal Area,
    string Cultura
);

public record TalhaoResponse(
    Guid Id,
    Guid PropriedadeId,
    string Nome,
    decimal Area,
    string Cultura,
    string Status,
    DateTime DataCadastro
);

public record PropriedadeResponse(
    Guid Id,
    string Nome,
    string Localizacao,
    decimal AreaTotal,
    DateTime DataCadastro,
    IReadOnlyCollection<TalhaoResponse> Talhoes
);
