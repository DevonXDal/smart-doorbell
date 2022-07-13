using DoorbellPiWeb.Data;
using DoorbellPiWeb.Models;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Db.NotMapped;
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

        private readonly string _jwtKey;

        private readonly string _serverPassword;

        private readonly string _serverURL;

        private UnitOfWork _unitOfWork;

        public AuthenticationController(IConfiguration config, UnitOfWork unitOfWork)
        {
            _jwtKey = config["JWTServerKey"];
            _serverPassword = config["ServerPassword"];
            _serverURL = config["WebServerURL"];
            _unitOfWork = unitOfWork;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] DeviceLoginModel deviceLoginInfo)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest("Device login information is missing: 'DeviceUUID', 'DisplayName', 'Password', and 'DeviceType' ('App' or 'Doorbell'). " +
                    "Additionally, 'IPAddress' and 'Port' are required for doorbells.");
            } else if (!deviceLoginInfo.Password.Equals(_serverPassword))
            {
                return Unauthorized();
            } else if (deviceLoginInfo.DeviceType.Equals("App"))
            {
                AppConnection? appConnection = _unitOfWork.AppConnectionRepo.Get(c => c.UUID == deviceLoginInfo.DeviceUUID).FirstOrDefault();
                if (appConnection is null)
                {
                    appConnection = new AppConnection
                    {
                        UUID = deviceLoginInfo.DeviceUUID,
                        DisplayName = FindAvailableDisplayName(deviceLoginInfo.DisplayName),
                        LastLoginTime = DateTime.UtcNow,
                        IsBanned = false,

                    };

                    _unitOfWork.AppConnectionRepo.Insert(appConnection);
                }
                else if (appConnection.IsBanned)
                {
                    return Forbid();
                }
                else
                {
                    appConnection.DisplayName = (deviceLoginInfo.DisplayName == appConnection.DisplayName)
                        ? deviceLoginInfo.DisplayName : FindAvailableDisplayName(deviceLoginInfo.DisplayName);
                    appConnection.LastLoginTime = DateTime.UtcNow;
                    _unitOfWork.AppConnectionRepo.Update(appConnection);
                }

                return GenerateJWT();
            } else if (deviceLoginInfo.DeviceType.Equals("Doorbell"))
            {
                if (deviceLoginInfo.IPAddress is null || deviceLoginInfo.Port is null || deviceLoginInfo.IPAddress.Length < 7) // 1.1.1.1 - 7 characters
                {
                    return BadRequest("'IPAddress' and 'Port' must be provided for doorbell connections to be established.");
                }

                DoorbellConnection? doorbellConnection = _unitOfWork.DoorbellConnectionRepo.Get(c => c.UUID == deviceLoginInfo.DeviceUUID).FirstOrDefault();
                if (doorbellConnection is null)
                {
                    doorbellConnection = new DoorbellConnection
                    {
                        UUID = deviceLoginInfo.DeviceUUID,
                        DisplayName = FindAvailableDisplayName(deviceLoginInfo.DisplayName),
                        LastLoginTime = DateTime.UtcNow,
                        IPAddress = deviceLoginInfo.IPAddress,
                        PortNumber = (int)deviceLoginInfo.Port,
                        IsBanned = false,

                    };

                    _unitOfWork.DoorbellConnectionRepo.Insert(doorbellConnection);
                }
                else if (doorbellConnection.IsBanned)
                {
                    return Forbid();
                }
                else
                {
                    doorbellConnection.DisplayName = (deviceLoginInfo.DisplayName == doorbellConnection.DisplayName)
                        ? deviceLoginInfo.DisplayName : FindAvailableDisplayName(deviceLoginInfo.DisplayName);
                    doorbellConnection.LastLoginTime = DateTime.UtcNow;
                    doorbellConnection.LastTurnedOn = (deviceLoginInfo.LastTurnedOn != null) // If the turn on time was supplied
                        ? (new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc)).AddSeconds(Convert.ToDouble(deviceLoginInfo.LastTurnedOn)) // Then convert the UTC Unix timestamp to Datetime
                        : DateTime.UtcNow.AddMinutes(-5); // Else just use five minutes ago
                    doorbellConnection.PreviousActivationTime = DateTime.UtcNow.AddDays(-1); // Done to prevent instant notifications
                    doorbellConnection.IPAddress = deviceLoginInfo.IPAddress;
                    doorbellConnection.PortNumber = (int)deviceLoginInfo.Port;
                    _unitOfWork.DoorbellConnectionRepo.Update(doorbellConnection);
                }

                return GenerateJWT();
            }
            return Unauthorized();
        }

        // Generate a JSON Web token that will last a day and return it to the mobile app or doorbell that has successfully logged in.
        private IActionResult GenerateJWT()
        {
            var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var signinCredentials = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256);
            var tokenOptions = new JwtSecurityToken(
                issuer: _serverURL,
                audience: _serverURL,
                claims: new List<Claim>(),
                expires: DateTime.Now.AddDays(3),
                signingCredentials: signinCredentials
            );
            var tokenString = new JwtSecurityTokenHandler().WriteToken(tokenOptions);
            return Ok(new DeviceLoginToken { Token = tokenString });
        }

        // Return the name with a number appended if it is already taken, so that names are unique
        private string FindAvailableDisplayName(string attemptedName)
        {
            string currentName = attemptedName.ToString();
            int addedNumber = 1;

            while (_unitOfWork.AppConnectionRepo.Get(app => app.DisplayName == currentName).Any() 
                || _unitOfWork.DoorbellConnectionRepo.Get(doorbell => doorbell.DisplayName == currentName).Any())
            {
                currentName = $"{attemptedName} ({addedNumber++})";
            }

            return currentName;
        }
    }
}
