using AgroSolutions.Shared.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Alerts.Worker.Data;

public class SensorsReadDbContext : DbContext
{
    public SensorsReadDbContext(DbContextOptions<SensorsReadDbContext> options) : base(options)
    {
    }

    public DbSet<SensorData> SensorData => Set<SensorData>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<SensorData>(entity =>
        {
            entity.ToTable("SensorData");
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
