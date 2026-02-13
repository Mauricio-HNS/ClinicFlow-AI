using GarageSales.Api.Contracts;
using GarageSales.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserStore _userStore;
    private readonly AuthTokenService _tokenService;

    public AuthController(UserStore userStore, AuthTokenService tokenService)
    {
        _userStore = userStore;
        _tokenService = tokenService;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name) ||
            string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Phone) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest("Name, email, phone and password are required.");
        }

        if (request.Password.Length < 6)
        {
            return BadRequest("Password must have at least 6 characters.");
        }

        try
        {
            var user = await _userStore.CreateAsync(
                request.Name,
                request.Email,
                request.Phone,
                PasswordHasher.Hash(request.Password));

            var token = _tokenService.CreateToken(user.Id, user.Email, user.Name);
            return Ok(new AuthResponse(token, ToUserDto(user.Id, user.Name, user.Email, user.Phone)));
        }
        catch (InvalidOperationException ex) when (ex.Message == "EMAIL_EXISTS")
        {
            return Conflict("Email already in use.");
        }
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest("Email and password are required.");
        }

        var user = await _userStore.FindByEmailAsync(request.Email);
        if (user is null || !PasswordHasher.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized("Invalid credentials.");
        }

        var token = _tokenService.CreateToken(user.Id, user.Email, user.Name);
        return Ok(new AuthResponse(token, ToUserDto(user.Id, user.Name, user.Email, user.Phone)));
    }

    [HttpGet("me")]
    public async Task<ActionResult<AuthUserDto>> Me()
    {
        var authHeader = Request.Headers.Authorization.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(authHeader) || !authHeader.StartsWith("Bearer "))
        {
            return Unauthorized();
        }

        var token = authHeader["Bearer ".Length..].Trim();
        var principal = _tokenService.ValidateToken(token);
        if (principal is null)
        {
            return Unauthorized();
        }

        var user = await _userStore.FindByIdAsync(principal.UserId);
        if (user is null)
        {
            return Unauthorized();
        }

        return Ok(ToUserDto(user.Id, user.Name, user.Email, user.Phone));
    }

    private static AuthUserDto ToUserDto(string id, string name, string email, string phone)
    {
        return new AuthUserDto(id, name, email, phone);
    }
}
