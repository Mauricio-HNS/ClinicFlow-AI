using System.Text.Json;
using GarageSales.Api.Models;

namespace GarageSales.Api.Services;

public class MessageStore
{
    private readonly string _filePath;
    private readonly SemaphoreSlim _mutex = new(1, 1);
    private readonly JsonSerializerOptions _jsonOptions = new() { WriteIndented = true };

    public MessageStore(IHostEnvironment environment)
    {
        var dataDir = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDir);
        _filePath = Path.Combine(dataDir, "messages.json");
    }

    public async Task<IReadOnlyList<MessageThread>> GetByOwnerAsync(string ownerUserId)
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

    public async Task<MessageThread> CreateAsync(MessageThread thread)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            items.Add(thread);
            await WriteAllInternalAsync(items);
            return thread;
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<MessageThread?> MarkOpenedAsync(string ownerUserId, string messageId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            var item = items.FirstOrDefault(x => x.OwnerUserId == ownerUserId && x.Id == messageId);
            if (item is null)
            {
                return null;
            }

            item.Opened = true;
            item.UpdatedAtUtc = DateTime.UtcNow;
            await WriteAllInternalAsync(items);
            return item;
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<bool> DeleteAsync(string ownerUserId, string messageId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            var removed = items.RemoveAll(x => x.OwnerUserId == ownerUserId && x.Id == messageId);
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

    public async Task DeleteAllAsync(string ownerUserId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            items.RemoveAll(x => x.OwnerUserId == ownerUserId);
            await WriteAllInternalAsync(items);
        }
        finally
        {
            _mutex.Release();
        }
    }

    private async Task<List<MessageThread>> ReadAllInternalAsync()
    {
        if (!File.Exists(_filePath))
        {
            return new List<MessageThread>();
        }

        await using var stream = File.OpenRead(_filePath);
        var items = await JsonSerializer.DeserializeAsync<List<MessageThread>>(stream);
        return items ?? new List<MessageThread>();
    }

    private async Task WriteAllInternalAsync(List<MessageThread> items)
    {
        await using var stream = File.Create(_filePath);
        await JsonSerializer.SerializeAsync(stream, items, _jsonOptions);
    }
}
