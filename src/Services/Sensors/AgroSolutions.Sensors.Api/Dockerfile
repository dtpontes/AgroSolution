# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["src/Services/Sensors/AgroSolutions.Sensors.Api/AgroSolutions.Sensors.Api.csproj", "Services/Sensors/AgroSolutions.Sensors.Api/"]
COPY ["src/Shared/AgroSolutions.Shared/AgroSolutions.Shared.csproj", "Shared/AgroSolutions.Shared/"]
RUN dotnet restore "Services/Sensors/AgroSolutions.Sensors.Api/AgroSolutions.Sensors.Api.csproj"

COPY src/ .
WORKDIR "/src/Services/Sensors/AgroSolutions.Sensors.Api"
RUN dotnet build "AgroSolutions.Sensors.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AgroSolutions.Sensors.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .

EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "AgroSolutions.Sensors.Api.dll"]
