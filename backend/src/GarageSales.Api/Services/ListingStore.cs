using System.Text.Json;
using GarageSales.Api.Models;

namespace GarageSales.Api.Services;

public class ListingStore
{
    private readonly string _filePath;
    private readonly SemaphoreSlim _mutex = new(1, 1);
    private readonly JsonSerializerOptions _jsonOptions = new() { WriteIndented = true };

    public ListingStore(IHostEnvironment environment)
    {
        var dataDir = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDir);
        _filePath = Path.Combine(dataDir, "listings.json");
    }

    public async Task<IReadOnlyList<ListingItem>> GetByOwnerAsync(string ownerUserId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            return items
                .Where(item => item.OwnerUserId == ownerUserId)
                .OrderByDescending(item => item.UpdatedAtUtc)
                .ToList();
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<ListingItem> CreateAsync(ListingItem listing)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            items.Add(listing);
            await WriteAllInternalAsync(items);
            return listing;
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<ListingItem?> UpdateAsync(string ownerUserId, string listingId, Action<ListingItem> patch)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            var existing = items.FirstOrDefault(item => item.Id == listingId && item.OwnerUserId == ownerUserId);
            if (existing is null)
            {
                return null;
            }

            patch(existing);
            existing.UpdatedAtUtc = DateTime.UtcNow;
            await WriteAllInternalAsync(items);
            return existing;
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<bool> DeleteAsync(string ownerUserId, string listingId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            var removed = items.RemoveAll(item => item.Id == listingId && item.OwnerUserId == ownerUserId);
            if (removed <= 0)
            {
                return false;
            }

            await WriteAllInternalAsync(items);
            return true;
        }
        finally
        {
            _mutex.Release();
        }
    }

    private async Task<List<ListingItem>> ReadAllInternalAsync()
    {
        if (!File.Exists(_filePath))
        {
            return new List<ListingItem>();
        }

        await using var stream = File.OpenRead(_filePath);
        var items = await JsonSerializer.DeserializeAsync<List<ListingItem>>(stream);
        return items ?? new List<ListingItem>();
    }

    private async Task WriteAllInternalAsync(List<ListingItem> items)
    {
        await using var stream = File.Create(_filePath);
        await JsonSerializer.SerializeAsync(stream, items, _jsonOptions);
    }
}
