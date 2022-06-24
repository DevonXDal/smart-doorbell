﻿// <auto-generated />
using System;
using DoorbellPiWeb.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

#nullable disable

namespace DoorbellPiWeb.Migrations
{
    [DbContext(typeof(DoorbellDbContext))]
    partial class DoorbellDbContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "6.0.6")
                .HasAnnotation("Relational:MaxIdentifierLength", 64);

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.AppConnection", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    b.Property<DateTime>("Created")
                        .HasColumnType("datetime(6)");

                    b.Property<string>("DisplayName")
                        .IsRequired()
                        .HasColumnType("longtext");

                    b.Property<bool>("IsBanned")
                        .HasColumnType("tinyint(1)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("tinyint(1)");

                    b.Property<DateTime>("LastLoginTime")
                        .HasColumnType("datetime(6)");

                    b.Property<DateTime>("LastModified")
                        .HasColumnType("datetime(6)");

                    b.Property<string>("UUID")
                        .IsRequired()
                        .HasColumnType("longtext");

                    b.HasKey("Id");

                    b.ToTable("AppConnections", (string)null);
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.DoorbellConnection", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    b.Property<DateTime>("Created")
                        .HasColumnType("datetime(6)");

                    b.Property<string>("DisplayName")
                        .IsRequired()
                        .HasColumnType("longtext");

                    b.Property<string>("IPAddress")
                        .IsRequired()
                        .HasColumnType("longtext");

                    b.Property<bool>("IsBanned")
                        .HasColumnType("tinyint(1)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("tinyint(1)");

                    b.Property<DateTime>("LastLoginTime")
                        .HasColumnType("datetime(6)");

                    b.Property<DateTime>("LastModified")
                        .HasColumnType("datetime(6)");

                    b.Property<int>("PortNumber")
                        .HasColumnType("int");

                    b.Property<string>("UUID")
                        .IsRequired()
                        .HasColumnType("longtext");

                    b.HasKey("Id");

                    b.ToTable("DoorbellConnections", (string)null);
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.DoorbellStatus", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    b.Property<DateTime>("Created")
                        .HasColumnType("datetime(6)");

                    b.Property<int>("DoorbellConnectionId")
                        .HasColumnType("int");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("tinyint(1)");

                    b.Property<DateTime>("LastModified")
                        .HasColumnType("datetime(6)");

                    b.Property<int>("State")
                        .HasColumnType("int");

                    b.HasKey("Id");

                    b.HasIndex("DoorbellConnectionId");

                    b.ToTable("DoorbellStatuses", (string)null);
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.MtoM.AppConnectionToVideoChat", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    b.Property<int?>("AppConnectionId")
                        .HasColumnType("int");

                    b.Property<DateTime>("Created")
                        .HasColumnType("datetime(6)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("tinyint(1)");

                    b.Property<DateTime>("LastModified")
                        .HasColumnType("datetime(6)");

                    b.Property<int?>("VideoChatId")
                        .HasColumnType("int");

                    b.HasKey("Id");

                    b.HasIndex("AppConnectionId");

                    b.HasIndex("VideoChatId");

                    b.ToTable("AppConnectionToVideoChats", (string)null);
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.RelatedFile", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    b.Property<DateTime>("Created")
                        .HasColumnType("datetime(6)");

                    b.Property<int>("DoorbellConnectionId")
                        .HasColumnType("int");

                    b.Property<string>("FileName")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("varchar(255)");

                    b.Property<string>("FilePath")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("varchar(255)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("tinyint(1)");

                    b.Property<DateTime>("LastModified")
                        .HasColumnType("datetime(6)");

                    b.HasKey("Id");

                    b.HasIndex("DoorbellConnectionId");

                    b.ToTable("RelatedFiles", (string)null);
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.VideoChat", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    b.Property<DateTime>("Created")
                        .HasColumnType("datetime(6)");

                    b.Property<int>("DoorbellConnectionId")
                        .HasColumnType("int");

                    b.Property<bool>("HasAnyoneAppUserAnswered")
                        .HasColumnType("tinyint(1)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("tinyint(1)");

                    b.Property<DateTime>("LastModified")
                        .HasColumnType("datetime(6)");

                    b.HasKey("Id");

                    b.HasIndex("DoorbellConnectionId");

                    b.ToTable("VideoChats", (string)null);
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.DoorbellStatus", b =>
                {
                    b.HasOne("DoorbellPiWeb.Models.Db.DoorbellConnection", "DoorbellConnection")
                        .WithMany("DoorbellStatuses")
                        .HasForeignKey("DoorbellConnectionId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("DoorbellConnection");
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.MtoM.AppConnectionToVideoChat", b =>
                {
                    b.HasOne("DoorbellPiWeb.Models.Db.AppConnection", "AppConnection")
                        .WithMany()
                        .HasForeignKey("AppConnectionId");

                    b.HasOne("DoorbellPiWeb.Models.Db.VideoChat", "VideoChat")
                        .WithMany("AppConnections")
                        .HasForeignKey("VideoChatId");

                    b.Navigation("AppConnection");

                    b.Navigation("VideoChat");
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.RelatedFile", b =>
                {
                    b.HasOne("DoorbellPiWeb.Models.Db.DoorbellConnection", "DoorbellConnection")
                        .WithMany("RelatedFiles")
                        .HasForeignKey("DoorbellConnectionId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("DoorbellConnection");
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.VideoChat", b =>
                {
                    b.HasOne("DoorbellPiWeb.Models.Db.DoorbellConnection", "DoorbellConnection")
                        .WithMany()
                        .HasForeignKey("DoorbellConnectionId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("DoorbellConnection");
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.DoorbellConnection", b =>
                {
                    b.Navigation("DoorbellStatuses");

                    b.Navigation("RelatedFiles");
                });

            modelBuilder.Entity("DoorbellPiWeb.Models.Db.VideoChat", b =>
                {
                    b.Navigation("AppConnections");
                });
#pragma warning restore 612, 618
        }
    }
}
