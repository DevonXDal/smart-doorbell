using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Json;
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

        public AppController(ILogger<WeatherForecastController> logger, UnitOfWork unitOfWork)
        {
            _logger = logger;
            _unitOfWork = unitOfWork;
        }

        [HttpGet(Name = "GetDoorbells")]
        public IActionResult GetDoorbells()
        {
            ICollection<DoorbellConnection> doorbells = _unitOfWork.DoorbellConnectionRepo.Get().ToList();

            List<DoorbellUpdateData> doorbellListData = new();
            foreach (DoorbellConnection doorbell in doorbells)
            {
                doorbellListData.Add(GetDoorbellUpdateData(doorbell));
            }

            return Ok(doorbellListData);
        }

        private DoorbellUpdateData GetDoorbellUpdateData(DoorbellConnection doorbell)
        {
            DoorbellStatus? mostRecentStatus = _unitOfWork.DoorbellStatusRepo.Get().OrderByDescending(s => s.LastModified).FirstOrDefault();

            if (mostRecentStatus == null || mostRecentStatus.LastModified < DateTime.UtcNow.AddSeconds(-20))
            {
                // Process a status update
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