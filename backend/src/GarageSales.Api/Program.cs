using System.Text.Json.Serialization;
using GarageSales.Api.Data;
using GarageSales.Api.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var dataDir = Path.Combine(builder.Environment.ContentRootPath, "App_Data");
Directory.CreateDirectory(dataDir);

builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHttpClient();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ??
    "Data Source=App_Data/garage_sales.db";

builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlite(connectionString));
builder.Services.AddScoped<UserStore>();
builder.Services.AddScoped<ListingStore>();
builder.Services.AddScoped<FavoriteStore>();
builder.Services.AddScoped<MessageStore>();
builder.Services.AddScoped<JobApplicationStore>();
builder.Services.AddScoped<PaymentStore>();
builder.Services.AddSingleton<StripeCheckoutService>();
builder.Services.AddSingleton<AuthTokenService>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("frontend", policy =>
    {
        policy
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowAnyOrigin();
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}

app.UseCors("frontend");
app.MapControllers();

app.MapGet("/health", () => Results.Ok(new
{
    service = "garage-sales-api",
    status = "ok",
    utc = DateTime.UtcNow
}));

app.Run();
