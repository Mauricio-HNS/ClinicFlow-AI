using System.Text.Json;
using GarageSales.Api.Models;

namespace GarageSales.Api.Services;

public class JobApplicationStore
{
    private readonly string _filePath;
    private readonly SemaphoreSlim _mutex = new(1, 1);
    private readonly JsonSerializerOptions _jsonOptions = new() { WriteIndented = true };

    public JobApplicationStore(IHostEnvironment environment)
    {
        var dataDir = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDir);
        _filePath = Path.Combine(dataDir, "job_applications.json");
    }

    public async Task<IReadOnlyList<JobApplicationItem>> GetByOwnerAsync(string ownerUserId)
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

    public async Task<JobApplicationItem> CreateAsync(JobApplicationItem item)
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

    private async Task<List<JobApplicationItem>> ReadAllInternalAsync()
    {
        if (!File.Exists(_filePath))
        {
            return new List<JobApplicationItem>();
        }

        await using var stream = File.OpenRead(_filePath);
        var items = await JsonSerializer.DeserializeAsync<List<JobApplicationItem>>(stream);
        return items ?? new List<JobApplicationItem>();
    }

    private async Task WriteAllInternalAsync(List<JobApplicationItem> items)
    {
        await using var stream = File.Create(_filePath);
        await JsonSerializer.SerializeAsync(stream, items, _jsonOptions);
    }
}
