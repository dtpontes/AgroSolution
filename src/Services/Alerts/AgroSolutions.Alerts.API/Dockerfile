# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["src/Services/Alerts/AgroSolutions.Alerts.API/AgroSolutions.Alerts.API.csproj", "Services/Alerts/AgroSolutions.Alerts.API/"]
RUN dotnet restore "Services/Alerts/AgroSolutions.Alerts.API/AgroSolutions.Alerts.API.csproj"

COPY src/ .
WORKDIR "/src/Services/Alerts/AgroSolutions.Alerts.API"
RUN dotnet build "AgroSolutions.Alerts.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AgroSolutions.Alerts.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "AgroSolutions.Alerts.API.dll"]
