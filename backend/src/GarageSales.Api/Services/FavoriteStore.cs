using System.Text.Json;
using GarageSales.Api.Models;

namespace GarageSales.Api.Services;

public class FavoriteStore
{
    private readonly string _filePath;
    private readonly SemaphoreSlim _mutex = new(1, 1);
    private readonly JsonSerializerOptions _jsonOptions = new() { WriteIndented = true };

    public FavoriteStore(IHostEnvironment environment)
    {
        var dataDir = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDir);
        _filePath = Path.Combine(dataDir, "favorites.json");
    }

    public async Task<IReadOnlyList<FavoriteItem>> GetByOwnerAsync(string ownerUserId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            return items
                .Where(item => item.OwnerUserId == ownerUserId)
                .OrderByDescending(item => item.CreatedAtUtc)
                .ToList();
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task AddAsync(string ownerUserId, string listingId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            if (items.Any(item => item.OwnerUserId == ownerUserId && item.ListingId == listingId))
            {
                return;
            }

            items.Add(new FavoriteItem
            {
                OwnerUserId = ownerUserId,
                ListingId = listingId,
                CreatedAtUtc = DateTime.UtcNow
            });

            await WriteAllInternalAsync(items);
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task RemoveAsync(string ownerUserId, string listingId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            items.RemoveAll(item => item.OwnerUserId == ownerUserId && item.ListingId == listingId);
            await WriteAllInternalAsync(items);
        }
        finally
        {
            _mutex.Release();
        }
    }

    private async Task<List<FavoriteItem>> ReadAllInternalAsync()
    {
        if (!File.Exists(_filePath))
        {
            return new List<FavoriteItem>();
        }

        await using var stream = File.OpenRead(_filePath);
        var items = await JsonSerializer.DeserializeAsync<List<FavoriteItem>>(stream);
        return items ?? new List<FavoriteItem>();
    }

    private async Task WriteAllInternalAsync(List<FavoriteItem> items)
    {
        await using var stream = File.Create(_filePath);
        await JsonSerializer.SerializeAsync(stream, items, _jsonOptions);
    }
}
