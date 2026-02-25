using AgroSolutions.Alerts.Worker;
using AgroSolutions.Alerts.Worker.Data;
using AgroSolutions.Alerts.Worker.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ===== DATABASES =====
builder.Services.AddDbContext<AlertsDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("AlertsConnection");
    options.UseNpgsql(connectionString);
});

builder.Services.AddDbContext<SensorsReadDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("SensorsConnection");
    options.UseNpgsql(connectionString);
});

// ===== SERVICES =====
builder.Services.AddScoped<IAlertProcessingService, AlertProcessingService>();
builder.Services.AddScoped<IAlertStatusService, AlertStatusService>();

// ===== BACKGROUND WORKER =====
builder.Services.AddHostedService<Worker>();

// ===== CORS =====
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// ===== JWT AUTHENTICATION =====
var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key nao configurada");
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "AgroSolutions";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "AgroSolutions";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// ===== CONTROLLERS =====
builder.Services.AddControllers();

// ===== SWAGGER/OPENAPI =====
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "AgroSolutions Alerts API",
        Version = "v1",
        Description = "API de alertas e status de talhoes",
        Contact = new OpenApiContact
        {
            Name = "AgroSolutions Team",
            Email = "contato@agrosolutions.com"
        }
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header usando o esquema Bearer. Exemplo: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// ===== HEALTH CHECKS =====
builder.Services.AddHealthChecks()
    .AddNpgSql(builder.Configuration.GetConnectionString("AlertsConnection")!)
    .AddNpgSql(builder.Configuration.GetConnectionString("SensorsConnection")!, name: "sensors-db");

var app = builder.Build();

// ===== MIGRATIONS =====
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var alertsDb = scope.ServiceProvider.GetRequiredService<AlertsDbContext>();
    try
    {
        await alertsDb.Database.MigrateAsync();
        app.Logger.LogInformation("Migrations aplicadas no banco de alertas");
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Erro ao aplicar migrations no banco de alertas");
    }
}

// ===== MIDDLEWARE =====
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Alerts API v1");
        options.RoutePrefix = string.Empty;
    });
}

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Logger.LogInformation("Alerts API iniciada!");

app.Run();
