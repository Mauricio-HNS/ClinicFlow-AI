namespace GarageSales.Api.Contracts;

public record RegisterRequest(string Name, string Email, string Phone, string Password);

public record LoginRequest(string Email, string Password);

public record AuthUserDto(string Id, string Name, string Email, string Phone);

public record AuthResponse(string Token, AuthUserDto User);
