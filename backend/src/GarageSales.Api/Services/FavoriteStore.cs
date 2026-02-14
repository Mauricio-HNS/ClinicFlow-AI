using GarageSales.Api.Data;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace GarageSales.Api.Services;

public class FavoriteStore
{
    private readonly AppDbContext _db;

    public FavoriteStore(AppDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<FavoriteItem>> GetByOwnerAsync(string ownerUserId)
    {
        return await _db.Favorites
            .AsNoTracking()
            .Where(item => item.OwnerUserId == ownerUserId)
            .OrderByDescending(item => item.CreatedAtUtc)
            .ToListAsync();
    }

    public async Task AddAsync(string ownerUserId, string listingId)
    {
        var exists = await _db.Favorites.AnyAsync(item => item.OwnerUserId == ownerUserId && item.ListingId == listingId);
        if (exists)
        {
            return;
        }

        _db.Favorites.Add(new FavoriteItem
        {
            OwnerUserId = ownerUserId,
            ListingId = listingId,
            CreatedAtUtc = DateTime.UtcNow
        });

        await _db.SaveChangesAsync();
    }

    public async Task RemoveAsync(string ownerUserId, string listingId)
    {
        var existing = await _db.Favorites.FirstOrDefaultAsync(item => item.OwnerUserId == ownerUserId && item.ListingId == listingId);
        if (existing is null)
        {
            return;
        }

        _db.Favorites.Remove(existing);
        await _db.SaveChangesAsync();
    }
}
