using Debezium.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace Debezium.Data;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers { get; set; }
}