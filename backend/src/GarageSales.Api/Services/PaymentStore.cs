using GarageSales.Api.Data;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace GarageSales.Api.Services;

public class PaymentStore
{
    private readonly AppDbContext _db;

    public PaymentStore(AppDbContext db)
    {
        _db = db;
    }

    public async Task<PaymentRecord> CreateAsync(PaymentRecord item)
    {
        _db.Payments.Add(item);
        await _db.SaveChangesAsync();
        return item;
    }

    public async Task<PaymentRecord?> FindByIdAsync(string paymentId)
    {
        return await _db.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
    }

    public async Task<PaymentRecord?> FindByProviderReferenceAsync(string providerReference)
    {
        return await _db.Payments.FirstOrDefaultAsync(x => x.ProviderReference == providerReference);
    }

    public async Task<IReadOnlyList<PaymentRecord>> GetByOwnerAsync(string ownerUserId)
    {
        return await _db.Payments
            .AsNoTracking()
            .Where(x => x.OwnerUserId == ownerUserId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync();
    }

    public async Task<PaymentRecord?> MarkPaidAsync(string paymentId)
    {
        var item = await _db.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
        if (item is null)
        {
            return null;
        }

        item.Status = "paid";
        item.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return item;
    }

    public async Task<PaymentRecord?> SetProviderReferenceAsync(string paymentId, string? providerReference)
    {
        var item = await _db.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
        if (item is null)
        {
            return null;
        }

        item.ProviderReference = providerReference;
        item.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return item;
    }
}
