# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["src/Services/Properties/AgroSolutions.Properties.Api/AgroSolutions.Properties.Api.csproj", "Services/Properties/AgroSolutions.Properties.Api/"]
RUN dotnet restore "Services/Properties/AgroSolutions.Properties.Api/AgroSolutions.Properties.Api.csproj"

COPY src/ .
WORKDIR "/src/Services/Properties/AgroSolutions.Properties.Api"
RUN dotnet build "AgroSolutions.Properties.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AgroSolutions.Properties.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "AgroSolutions.Properties.Api.dll"]
