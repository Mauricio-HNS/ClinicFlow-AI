using GarageSales.Api.Data;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace GarageSales.Api.Services;

public class JobApplicationStore
{
    private readonly AppDbContext _db;

    public JobApplicationStore(AppDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<JobApplicationItem>> GetByOwnerAsync(string ownerUserId)
    {
        return await _db.JobApplications
            .AsNoTracking()
            .Where(item => item.OwnerUserId == ownerUserId)
            .OrderByDescending(item => item.CreatedAtUtc)
            .ToListAsync();
    }

    public async Task<JobApplicationItem> CreateAsync(JobApplicationItem item)
    {
        _db.JobApplications.Add(item);
        await _db.SaveChangesAsync();
        return item;
    }
}
