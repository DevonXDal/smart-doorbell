using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DoorbellPiWeb.Migrations
{
    public partial class missingcolumns : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastTurnedOn",
                table: "DoorbellConnections",
                type: "datetime(6)",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastTurnedOn",
                table: "DoorbellConnections");
        }
    }
}
