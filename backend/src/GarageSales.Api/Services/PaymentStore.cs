using System.Text.Json;
using GarageSales.Api.Models;

namespace GarageSales.Api.Services;

public class PaymentStore
{
    private readonly string _filePath;
    private readonly SemaphoreSlim _mutex = new(1, 1);
    private readonly JsonSerializerOptions _jsonOptions = new() { WriteIndented = true };

    public PaymentStore(IHostEnvironment environment)
    {
        var dataDir = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDir);
        _filePath = Path.Combine(dataDir, "payments.json");
    }

    public async Task<PaymentRecord> CreateAsync(PaymentRecord item)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            items.Add(item);
            await WriteAllInternalAsync(items);
            return item;
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<PaymentRecord?> FindByIdAsync(string paymentId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            return items.FirstOrDefault(x => x.Id == paymentId);
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<PaymentRecord?> FindByProviderReferenceAsync(string providerReference)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            return items.FirstOrDefault(x => x.ProviderReference == providerReference);
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<IReadOnlyList<PaymentRecord>> GetByOwnerAsync(string ownerUserId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            return items
                .Where(x => x.OwnerUserId == ownerUserId)
                .OrderByDescending(x => x.CreatedAtUtc)
                .ToList();
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<PaymentRecord?> MarkPaidAsync(string paymentId)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            var item = items.FirstOrDefault(x => x.Id == paymentId);
            if (item is null)
            {
                return null;
            }
            item.Status = "paid";
            item.UpdatedAtUtc = DateTime.UtcNow;
            await WriteAllInternalAsync(items);
            return item;
        }
        finally
        {
            _mutex.Release();
        }
    }

    public async Task<PaymentRecord?> SetProviderReferenceAsync(string paymentId, string? providerReference)
    {
        await _mutex.WaitAsync();
        try
        {
            var items = await ReadAllInternalAsync();
            var item = items.FirstOrDefault(x => x.Id == paymentId);
            if (item is null)
            {
                return null;
            }
            item.ProviderReference = providerReference;
            item.UpdatedAtUtc = DateTime.UtcNow;
            await WriteAllInternalAsync(items);
            return item;
        }
        finally
        {
            _mutex.Release();
        }
    }

    private async Task<List<PaymentRecord>> ReadAllInternalAsync()
    {
        if (!File.Exists(_filePath))
        {
            return new List<PaymentRecord>();
        }

        await using var stream = File.OpenRead(_filePath);
        var items = await JsonSerializer.DeserializeAsync<List<PaymentRecord>>(stream);
        return items ?? new List<PaymentRecord>();
    }

    private async Task WriteAllInternalAsync(List<PaymentRecord> items)
    {
        await using var stream = File.Create(_filePath);
        await JsonSerializer.SerializeAsync(stream, items, _jsonOptions);
    }
}
