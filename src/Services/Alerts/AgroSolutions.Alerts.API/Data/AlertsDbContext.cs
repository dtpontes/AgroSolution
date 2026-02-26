using AgroSolutions.Shared.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Alerts.API.Data;

public class AlertsDbContext : DbContext
{
    public AlertsDbContext(DbContextOptions<AlertsDbContext> options) : base(options)
    {
    }

    public DbSet<Alert> Alerts => Set<Alert>();
    public DbSet<SensorData> SensorDataCache => Set<SensorData>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Alert>(entity =>
        {
            entity.ToTable("Alerts");
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => e.TalhaoId);
            entity.HasIndex(e => new { e.TalhaoId, e.Tipo, e.Resolvido });
            entity.HasIndex(e => e.DataCriacao);

            entity.Property(e => e.Tipo)
                .IsRequired()
                .HasMaxLength(50);

            entity.Property(e => e.Mensagem)
                .IsRequired()
                .HasMaxLength(1000);

            entity.Property(e => e.DataCriacao)
                .HasDefaultValueSql("NOW()");

            entity.Property(e => e.Resolvido)
                .HasDefaultValue(false);
        });

        modelBuilder.Entity<SensorData>(entity =>
        {
            entity.ToTable("SensorDataCache");
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.TalhaoId);
            entity.HasIndex(e => e.Timestamp);
            entity.HasIndex(e => new { e.TalhaoId, e.Timestamp });

            entity.Property(e => e.UmidadeSolo)
                .HasPrecision(5, 2);

            entity.Property(e => e.Temperatura)
                .HasPrecision(5, 2);

            entity.Property(e => e.Precipitacao)
                .HasPrecision(8, 2);
        });
    }
}
