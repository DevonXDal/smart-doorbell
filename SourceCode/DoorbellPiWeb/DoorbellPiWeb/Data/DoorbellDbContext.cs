﻿using System;
using System.Collections.Generic;
using System.Text;
using DoorbellPiWeb.Models.Db;
using Microsoft.EntityFrameworkCore;

namespace DoorbellPiWeb.Data
{
    /// <summary>
    /// Provides access to the database for the main data used in the system.
    /// </summary>
    public class DoorbellDbContext : DbContext
    {

        public DbSet<AppConnection> AppConnections { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DoorbellDbContext"/> and migrates the database if needed.
        /// </summary>
        /// <param name="options">The options used to configure the DBContext.</param>
        public DoorbellDbContext(DbContextOptions<DoorbellDbContext> options) : base(options)
        {
            try
            {
                Database.Migrate();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }


        /// <summary>
        /// Creates the tables for the database and sets some constraints on the models.
        /// </summary>
        /// <param name="modelBuilder">The builder being used to construct the model for this context. Databases (and other extensions) typically
        /// define extension methods on this object that allow you to configure aspects of the model that are specific
        /// to a given database.
        /// </param>
        /// <remarks>
        /// This forces the use of the numeric data type using a specific precision and scale so that money paid is handled correctly.
        /// </remarks>
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {

            base.OnModelCreating(modelBuilder);

            // ----- Table Names -----

            modelBuilder.Entity<AppConnection>().ToTable("AppConnections"); 

        }
    }
}
