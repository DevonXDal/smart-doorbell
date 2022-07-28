using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Helpers.Services;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.RequestResponseData;
using DoorbellPiWeb.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DoorbellPiWeb.Controllers
{
    /// <summary>
    /// This AppController class handles API calls coming from the app. It returns information for Twilio and connected doorbells.
    /// 
    /// Author: Devon X. Dalrymple
    /// Version 2022-07-18
    /// </summary>
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class AppController : ControllerBase
    {
        private readonly ILogger<AppController> _logger;
        private UnitOfWork _unitOfWork;
        private readonly DoorbellAPIHandler _doorbellAPIHandler;
        private readonly FileHandler _fileHandler;

        public AppController(ILogger<AppController> logger, UnitOfWork unitOfWork, DoorbellAPIHandler doorbellAPIHandler, FileHandler fileHandler)
        {
            _logger = logger;
            _unitOfWork = unitOfWork;
            _doorbellAPIHandler = doorbellAPIHandler;
            _fileHandler = fileHandler;
        }

        [HttpGet("GetDoorbells")]
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

        [HttpGet("GetDoorbellUpdate")]
        public async Task<IActionResult> GetDoorbellUpdate([FromQuery] string doorbellDisplayName)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();

            if (doorbell == null)
            {
                return BadRequest(); // The doorbell with the display name is not on this server (or it is banned)
            }

            return Ok(await GetDoorbellUpdateData(doorbell));
        }

        [HttpGet("GetImageFromLastDoorbellPress")]
        public async Task<IActionResult> GetImageFromLastDoorbellPress([FromQuery] string doorbellDisplayName)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();
            if (doorbell == null)
            {
                return BadRequest("Doorbell Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            RelatedFile? lastImageFile = _unitOfWork.RelatedFileRepo.Get(f => f.DoorbellConnectionId == doorbell.Id).OrderByDescending(f => f.Created).FirstOrDefault();
            if (lastImageFile == null)
            {
                return StatusCode(500, "No previous image file");
            }

            return _fileHandler.GetFile(lastImageFile);
        }

        private async Task<DoorbellUpdateData> GetDoorbellUpdateData(DoorbellConnection doorbell)
        {
            DoorbellStatus? mostRecentStatus = _unitOfWork.DoorbellStatusRepo.Get().OrderByDescending(s => s.Created).FirstOrDefault();

            if (mostRecentStatus == null || mostRecentStatus.Created.CompareTo(DateTime.UtcNow.AddSeconds(-20)) < 0)
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