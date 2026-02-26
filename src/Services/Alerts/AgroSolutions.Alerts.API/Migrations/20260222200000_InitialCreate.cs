using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AgroSolutions.Alerts.API.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Alerts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TalhaoId = table.Column<Guid>(type: "uuid", nullable: false),
                    Tipo = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Mensagem = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()"),
                    Resolvido = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Alerts", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Alerts_TalhaoId",
                table: "Alerts",
                column: "TalhaoId");

            migrationBuilder.CreateIndex(
                name: "IX_Alerts_TalhaoId_Tipo_Resolvido",
                table: "Alerts",
                columns: new[] { "TalhaoId", "Tipo", "Resolvido" });

            migrationBuilder.CreateIndex(
                name: "IX_Alerts_DataCriacao",
                table: "Alerts",
                column: "DataCriacao");

            migrationBuilder.CreateTable(
                name: "SensorDataCache",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TalhaoId = table.Column<Guid>(type: "uuid", nullable: false),
                    Temperatura = table.Column<decimal>(type: "numeric(5,2)", precision: 5, scale: 2, nullable: false),
                    UmidadeSolo = table.Column<decimal>(type: "numeric(5,2)", precision: 5, scale: 2, nullable: false),
                    Precipitacao = table.Column<decimal>(type: "numeric(8,2)", precision: 8, scale: 2, nullable: false),
                    Timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SensorDataCache", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SensorDataCache_TalhaoId",
                table: "SensorDataCache",
                column: "TalhaoId");

            migrationBuilder.CreateIndex(
                name: "IX_SensorDataCache_Timestamp",
                table: "SensorDataCache",
                column: "Timestamp");

            migrationBuilder.CreateIndex(
                name: "IX_SensorDataCache_TalhaoId_Timestamp",
                table: "SensorDataCache",
                columns: new[] { "TalhaoId", "Timestamp" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Alerts");

            migrationBuilder.DropTable(
                name: "SensorDataCache");
        }
    }
}
