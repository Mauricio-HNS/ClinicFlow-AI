namespace ClinicFlow.Api.Infrastructure;

public static class TenantContext
{
    public const string HeaderName = "X-Tenant-Id";

    public static Guid ReadTenantId(HttpContext httpContext)
    {
        if (!httpContext.Request.Headers.TryGetValue(HeaderName, out var value) ||
            !Guid.TryParse(value.ToString(), out var tenantId))
        {
            throw new InvalidOperationException($"Missing or invalid {HeaderName} header.");
        }

        return tenantId;
    }
}
