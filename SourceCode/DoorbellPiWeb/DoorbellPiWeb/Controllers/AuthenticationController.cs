using DoorbellPiWeb.Models;
using DoorbellPiWeb.Models.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace DoorbellPiWeb.Controllers
{
    /// <summary>
    /// https://code-maze.com/authentication-aspnetcore-jwt-1/ - Used to understand logging in verification and providing a JWT back if successful.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    public class AuthenticationController : ControllerBase
    {

        private readonly string jwtKey;

        private readonly string serverPassword; 

        public AuthenticationController(IConfiguration config)
        {
            jwtKey = config["JWTServerKey"];
            serverPassword = config["ServerPassword"];
        }
        
        [HttpPost("login")]
        public IActionResult Login([FromBody] DeviceLoginModel deviceLoginInfo)
        {
            if (deviceLoginInfo is null)
            {
                return BadRequest("Device login information is missing");
            }
            if (userdeviceLoginInfo.UserName == "johndoe" && deviceLoginInfo.Password == "def@123")
            {
                var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("superSecretKey@345"));
                var signinCredentials = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256);
                var tokeOptions = new JwtSecurityToken(
                    issuer: "https://localhost:5001",
                    audience: "https://localhost:5001",
                    claims: new List<Claim>(),
                    expires: DateTime.Now.AddDays(1),
                    signingCredentials: signinCredentials
                );
                var tokenString = new JwtSecurityTokenHandler().WriteToken(tokeOptions);
                return Ok(new DeviceLoginToken { Token = tokenString });
            }
            return Unauthorized();
        }
    }
}
