using GarageSales.Api.Data;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace GarageSales.Api.Services;

public class MessageStore
{
    private readonly AppDbContext _db;

    public MessageStore(AppDbContext db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<MessageThread>> GetByOwnerAsync(string ownerUserId)
    {
        return await _db.Messages
            .AsNoTracking()
            .Where(item => item.OwnerUserId == ownerUserId)
            .OrderByDescending(item => item.UpdatedAtUtc)
            .ToListAsync();
    }

    public async Task<MessageThread> CreateAsync(MessageThread thread)
    {
        _db.Messages.Add(thread);
        await _db.SaveChangesAsync();
        return thread;
    }

    public async Task<MessageThread?> MarkOpenedAsync(string ownerUserId, string messageId)
    {
        var item = await _db.Messages.FirstOrDefaultAsync(x => x.OwnerUserId == ownerUserId && x.Id == messageId);
        if (item is null)
        {
            return null;
        }

        item.Opened = true;
        item.UpdatedAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return item;
    }

    public async Task<bool> DeleteAsync(string ownerUserId, string messageId)
    {
        var item = await _db.Messages.FirstOrDefaultAsync(x => x.OwnerUserId == ownerUserId && x.Id == messageId);
        if (item is null)
        {
            return false;
        }

        _db.Messages.Remove(item);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task DeleteAllAsync(string ownerUserId)
    {
        var items = await _db.Messages.Where(x => x.OwnerUserId == ownerUserId).ToListAsync();
        if (items.Count == 0)
        {
            return;
        }

        _db.Messages.RemoveRange(items);
        await _db.SaveChangesAsync();
    }
}
