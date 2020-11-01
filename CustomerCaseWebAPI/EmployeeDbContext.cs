using CustomerCaseWebAPI.Models;
using CustomerCaseWebAPI.Providers.Repositories;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CustomerCaseWebAPI
{
    public class EmployeeDbContext : DbContext
    {
        public DbSet<Employee> Employee { get; set; }
        public EmployeeDbContext(DbContextOptions<EmployeeDbContext> options) : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Employee>().ToTable("Employee");
        }
    }
}
