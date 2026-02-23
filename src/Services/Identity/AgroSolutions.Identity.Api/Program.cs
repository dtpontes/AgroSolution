using AgroSolutions.Identity.Api.Data;
using AgroSolutions.Identity.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ===== DATABASE =====
builder.Services.AddDbContext<IdentityDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseNpgsql(connectionString);
});

// ===== SERVICES =====
builder.Services.AddScoped<IAuthService, AuthService>();

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
var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key não configurada");
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
        Title = "AgroSolutions Identity API",
        Version = "v1",
        Description = "API de autenticação e gerenciamento de usuários da plataforma AgroSolutions",
        Contact = new OpenApiContact
        {
            Name = "AgroSolutions Team",
            Email = "contato@agrosolutions.com"
        }
    });

    // Configurar JWT no Swagger
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
    .AddNpgSql(builder.Configuration.GetConnectionString("DefaultConnection")!);

var app = builder.Build();

// ===== MIGRATIONS =====
// Aplicar migrations automaticamente em desenvolvimento
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
    try
    {
        await dbContext.Database.MigrateAsync();
        app.Logger.LogInformation("✅ Migrations aplicadas com sucesso!");
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "❌ Erro ao aplicar migrations");
    }
}

// ===== MIDDLEWARE =====
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Identity API v1");
        options.RoutePrefix = string.Empty; // Swagger na raiz
    });
}

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Logger.LogInformation("🚀 Identity API iniciada!");
app.Logger.LogInformation("📍 Swagger disponível em: http://localhost:{0}", app.Configuration["ASPNETCORE_HTTP_PORTS"] ?? "5001");

app.Run();
