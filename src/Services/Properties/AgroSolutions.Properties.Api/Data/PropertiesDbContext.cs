using AgroSolutions.Properties.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Properties.Api.Data;

public class PropertiesDbContext : DbContext
{
    public PropertiesDbContext(DbContextOptions<PropertiesDbContext> options) : base(options)
    {
    }

    public DbSet<Propriedade> Propriedades => Set<Propriedade>();
    public DbSet<Talhao> Talhoes => Set<Talhao>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Propriedade>(entity =>
        {
            entity.ToTable("Propriedades");
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.ProdutorId);

            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(e => e.Localizacao)
                .HasMaxLength(500);

            entity.Property(e => e.AreaTotal)
                .HasPrecision(18, 2);

            entity.Property(e => e.DataCadastro)
                .HasDefaultValueSql("NOW()");

            entity.HasMany(e => e.Talhoes)
                .WithOne(t => t.Propriedade)
                .HasForeignKey(t => t.PropriedadeId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Talhao>(entity =>
        {
            entity.ToTable("Talhoes");
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.PropriedadeId);

            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(120);

            entity.Property(e => e.Cultura)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.Status)
                .HasMaxLength(50);

            entity.Property(e => e.Area)
                .HasPrecision(18, 2);

            entity.Property(e => e.DataCadastro)
                .HasDefaultValueSql("NOW()");
        });
    }
}
