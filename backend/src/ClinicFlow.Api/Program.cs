using ClinicFlow.Api.Infrastructure;
using ClinicFlow.Application.Abstractions;
using ClinicFlow.Application.Services;
using ClinicFlow.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddControllers(options => options.Filters.Add<ApiExceptionFilter>());
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSingleton<IClinicRepository, InMemoryClinicRepository>();
builder.Services.AddSingleton<IPlatformAdminStore, InMemoryPlatformAdminStore>();
builder.Services.AddScoped<ClinicFlowAppService>();
builder.Services.AddScoped<PlatformAdminService>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("frontend", policy =>
    {
        policy.AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors("frontend");
app.UseAuthorization();
app.MapControllers();

app.MapGet("/health", () => Results.Ok(new
{
    service = "clinicflow-api",
    status = "ok",
    utc = DateTime.UtcNow
}));

app.Run();
