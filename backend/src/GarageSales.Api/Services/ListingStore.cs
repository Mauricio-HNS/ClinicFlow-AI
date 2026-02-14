using GarageSales.Api.Data;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace GarageSales.Api.Services;

public class ListingStore
{
    private readonly AppDbContext _db;

    public ListingStore(AppDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<ListingItem>> GetByOwnerAsync(string ownerUserId)
    {
        return await _db.Listings
            .AsNoTracking()
            .Where(item => item.OwnerUserId == ownerUserId)
            .OrderByDescending(item => item.UpdatedAtUtc)
            .ToListAsync();
    }

    public async Task<ListingItem> CreateAsync(ListingItem listing)
    {
        _db.Listings.Add(listing);
        await _db.SaveChangesAsync();
        return listing;
    }

    public async Task<ListingItem?> UpdateAsync(string ownerUserId, string listingId, Action<ListingItem> patch)
    {
        var existing = await _db.Listings.FirstOrDefaultAsync(
            item => item.Id == listingId && item.OwnerUserId == ownerUserId);
        if (existing is null)
        {
            return null;
        }

        patch(existing);
        existing.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(string ownerUserId, string listingId)
    {
        var existing = await _db.Listings.FirstOrDefaultAsync(
            item => item.Id == listingId && item.OwnerUserId == ownerUserId);
        if (existing is null)
        {
            return false;
        }

        _db.Listings.Remove(existing);
        await _db.SaveChangesAsync();
        return true;
    }
}
