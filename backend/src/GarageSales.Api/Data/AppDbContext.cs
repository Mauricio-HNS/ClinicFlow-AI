using System.Text.Json;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace GarageSales.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<UserAccount> Users => Set<UserAccount>();
    public DbSet<ListingItem> Listings => Set<ListingItem>();
    public DbSet<FavoriteItem> Favorites => Set<FavoriteItem>();
    public DbSet<MessageThread> Messages => Set<MessageThread>();
    public DbSet<JobApplicationItem> JobApplications => Set<JobApplicationItem>();
    public DbSet<PaymentRecord> Payments => Set<PaymentRecord>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var stringListConverter = new ValueConverter<List<string>, string>(
            value => JsonSerializer.Serialize(value, (JsonSerializerOptions?)null),
            value => JsonSerializer.Deserialize<List<string>>(value, (JsonSerializerOptions?)null) ?? new List<string>());

        modelBuilder.Entity<UserAccount>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.Email).IsUnique();
            entity.Property(x => x.Email).IsRequired();
            entity.Property(x => x.Name).IsRequired();
            entity.Property(x => x.Phone).IsRequired();
            entity.Property(x => x.PasswordHash).IsRequired();
        });

        modelBuilder.Entity<ListingItem>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.OwnerUserId);
            entity.Property(x => x.OwnerUserId).IsRequired();
            entity.Property(x => x.Title).IsRequired();
            entity.Property(x => x.Category).IsRequired();
            entity.Property(x => x.Price).IsRequired();
            entity.Property(x => x.Distance).IsRequired();
            entity.Property(x => x.Date).IsRequired();
            entity.Property(x => x.PhotoPaths).HasConversion(stringListConverter);
        });

        modelBuilder.Entity<FavoriteItem>(entity =>
        {
            entity.HasKey(x => new { x.OwnerUserId, x.ListingId });
            entity.HasIndex(x => x.OwnerUserId);
        });

        modelBuilder.Entity<MessageThread>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.OwnerUserId);
            entity.Property(x => x.Title).IsRequired();
            entity.Property(x => x.Preview).IsRequired();
            entity.Property(x => x.TimeLabel).IsRequired();
        });

        modelBuilder.Entity<JobApplicationItem>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.OwnerUserId);
            entity.Property(x => x.JobId).IsRequired();
            entity.Property(x => x.JobTitle).IsRequired();
            entity.Property(x => x.Company).IsRequired();
            entity.Property(x => x.CandidateName).IsRequired();
            entity.Property(x => x.CandidatePhone).IsRequired();
        });

        modelBuilder.Entity<PaymentRecord>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.OwnerUserId);
            entity.HasIndex(x => x.ProviderReference);
            entity.Property(x => x.Status).IsRequired();
            entity.Property(x => x.Provider).IsRequired();
            entity.Property(x => x.Currency).IsRequired();
        });
    }
}
