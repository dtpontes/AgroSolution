using AgroSolutions.Identity.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Identity.Api.Data;

/// <summary>
/// Contexto do banco de dados do serviço de identidade
/// </summary>
public class IdentityDbContext : DbContext
{
    public IdentityDbContext(DbContextOptions<IdentityDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("Users");
            entity.HasKey(e => e.Id);

            // Índices
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Cpf).IsUnique().HasFilter("\"Cpf\" IS NOT NULL");

            // Propriedades obrigatórias
            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(e => e.Email)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(e => e.PasswordHash)
                .IsRequired()
                .HasMaxLength(500);

            // Propriedades opcionais
            entity.Property(e => e.Telefone)
                .HasMaxLength(20);

            entity.Property(e => e.Cpf)
                .HasMaxLength(14);

            // Defaults
            entity.Property(e => e.DataCadastro)
                .HasDefaultValueSql("NOW()");

            entity.Property(e => e.Ativo)
                .HasDefaultValue(true);
        });
    }
}
