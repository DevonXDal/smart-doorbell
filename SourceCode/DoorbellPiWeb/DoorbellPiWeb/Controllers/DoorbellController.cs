using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Helpers.Services;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.RequestResponseData.FromDoorbell;
using DoorbellPiWeb.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DoorbellPiWeb.Controllers
{
    /// <summary>
    /// This DoorbellController is responsible for handling incoming requests from connected doorbell systems.
    /// This allows the doorbells to notify of people at the door and also make requests relating to access tokens for video calls.
    /// 
    /// Author: Devon X. Dalrymple
    /// Version: 2022-07-27
    /// </summary>
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class DoorbellController : ControllerBase
    {
        private readonly ILogger<DoorbellController> _logger;
        private UnitOfWork _unitOfWork;
        private readonly DoorbellAPIHandler _doorbellAPIHandler;
        private readonly FileHandler _fileHandler;

        public DoorbellController(ILogger<DoorbellController> logger, UnitOfWork unitOfWork, DoorbellAPIHandler doorbellAPIHandler, FileHandler fileHandler)
        {
            _logger = logger;
            _unitOfWork = unitOfWork;
            _doorbellAPIHandler = doorbellAPIHandler;
            _fileHandler = fileHandler;
        }

        [HttpPost("DeclareAwaitingAnswer")]
        public IActionResult DeclareAwaitingAnswer([FromForm] DoorbellActivationData data)
        {
            if (!ModelState.IsValid || !_fileHandler.IsRelatedFileImage(data.DoorbellImageFormFile))
            {
                return BadRequest(ModelState);
            }

            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.UUID == data.UUID).FirstOrDefault();
            if (doorbell == null) return BadRequest("Doorbell was not found");

            doorbell.PreviousActivationTime = (new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc)).AddSeconds(Convert.ToDouble(data.ActivationTimeUnix));
            _unitOfWork.DoorbellConnectionRepo.Update(doorbell);

            _unitOfWork.DoorbellStatusRepo.Insert(new DoorbellStatus
            {
                DoorbellConnectionId = doorbell.Id,
                State = DoorbellState.ButtonRecentlyActivated
            });

            _fileHandler.CreateRelatedFile(data.DoorbellImageFormFile, doorbell.Id);

            return Ok();
        }
    }
}
