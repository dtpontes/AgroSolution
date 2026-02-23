# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar apenas os arquivos de projeto primeiro (para cache de dependências)
COPY ["src/Services/Identity/AgroSolutions.Identity.Api/AgroSolutions.Identity.Api.csproj", "Services/Identity/AgroSolutions.Identity.Api/"]
COPY ["src/Shared/AgroSolutions.Shared/AgroSolutions.Shared.csproj", "Shared/AgroSolutions.Shared/"]

# Restaurar dependências
RUN dotnet restore "Services/Identity/AgroSolutions.Identity.Api/AgroSolutions.Identity.Api.csproj"

# Copiar todo o código fonte
COPY src/ .

# Build do projeto
WORKDIR "/src/Services/Identity/AgroSolutions.Identity.Api"
RUN dotnet build "AgroSolutions.Identity.Api.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "AgroSolutions.Identity.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Criar usuário não-root para segurança
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .

EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "AgroSolutions.Identity.Api.dll"]
