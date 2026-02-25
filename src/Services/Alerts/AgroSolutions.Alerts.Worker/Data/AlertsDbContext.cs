using AgroSolutions.Shared.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSolutions.Alerts.Worker.Data;

public class AlertsDbContext : DbContext
{
    public AlertsDbContext(DbContextOptions<AlertsDbContext> options) : base(options)
    {
    }

    public DbSet<Alert> Alerts => Set<Alert>();

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
    }
}
