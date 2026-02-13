using System.Text.Json.Serialization;
using GarageSales.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHttpClient();
builder.Services.AddSingleton<UserStore>();
builder.Services.AddSingleton<ListingStore>();
builder.Services.AddSingleton<FavoriteStore>();
builder.Services.AddSingleton<MessageStore>();
builder.Services.AddSingleton<JobApplicationStore>();
builder.Services.AddSingleton<PaymentStore>();
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

app.UseCors("frontend");
app.MapControllers();

app.MapGet("/health", () => Results.Ok(new
{
    service = "garage-sales-api",
    status = "ok",
    utc = DateTime.UtcNow
}));

app.Run();
