using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Json;
using DoorbellPiWeb.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DoorbellPiWeb.Controllers
{
    /// <summary>
    /// This AppController class handles API calls coming from the app. It returns information for Twilio and connected doorbells.
    /// 
    /// Author: Devon X. Dalrymple
    /// Version 2022-06-26
    /// </summary>
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class AppController : ControllerBase
    {
        private readonly ILogger<WeatherForecastController> _logger;
        private UnitOfWork _unitOfWork;
        private readonly DoorbellAPIHandler _doorbellAPIHandler;

        public AppController(ILogger<WeatherForecastController> logger, UnitOfWork unitOfWork, DoorbellAPIHandler doorbellAPIHandler)
        {
            _logger = logger;
            _unitOfWork = unitOfWork;
            _doorbellAPIHandler = doorbellAPIHandler;
        }

        [HttpGet(Name = "GetDoorbells")]
        public async Task<IActionResult> GetDoorbells()
        {
            ICollection<DoorbellConnection> doorbells = _unitOfWork.DoorbellConnectionRepo.Get(d => !d.IsBanned).ToList();

            List<DoorbellUpdateData> doorbellListData = new();
            foreach (DoorbellConnection doorbell in doorbells)
            {
                doorbellListData.Add(await GetDoorbellUpdateData(doorbell));
            }

            return Ok(doorbellListData);
        }

        [HttpGet(Name = "GetDoorbellUpdate")]
        public async Task<IActionResult> GetDoorbell([FromBody] string doorbellDisplayName)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();

            if (doorbell == null)
            {
                return BadRequest(); // The doorbell with the display name is not on this server (or it is banned)
            }

            return Ok(await GetDoorbellUpdateData(doorbell));
        }

        private async Task<DoorbellUpdateData> GetDoorbellUpdateData(DoorbellConnection doorbell)
        {
            DoorbellStatus? mostRecentStatus = _unitOfWork.DoorbellStatusRepo.Get().OrderByDescending(s => s.LastModified).FirstOrDefault();

            if (mostRecentStatus == null || mostRecentStatus.LastModified < DateTime.UtcNow.AddSeconds(-20))
            {
                mostRecentStatus = await _doorbellAPIHandler.RequestDoorbellUpdate(doorbell);
            }

            string state = "";
            switch (mostRecentStatus.State)
            {
                case DoorbellState.Idle:
                    state = "Idle";
                    break;
                case DoorbellState.UnreachableOrOff:
                    state = "Disconnected or Off";
                    break;
                case DoorbellState.ButtonRecentlyActivated:
                    state = "Awaiting Doorbell Answer";
                    break;
                case DoorbellState.InCall:
                    state = "In Call";
                    break;
                default:
                    state = "Unknown State";
                    break;
            }

            DoorbellUpdateData updateData = new DoorbellUpdateData()
            {
                DisplayName = doorbell.DisplayName,
                DoorbellStatus = state,
                LastTurnedOn = (new DateTimeOffset(doorbell.LastLoginTime)).ToUnixTimeSeconds(),
                LastActivationUnix = (new DateTimeOffset(doorbell.PreviousActivationTime)).ToUnixTimeSeconds(),
            };

            return updateData;
        }
    }
}