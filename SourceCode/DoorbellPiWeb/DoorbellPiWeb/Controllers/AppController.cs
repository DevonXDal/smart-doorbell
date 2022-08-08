using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Helpers.Services;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Db.MtoM;
using DoorbellPiWeb.Models.RequestResponseData;
using DoorbellPiWeb.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Twilio.Rest.Video.V1;

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
        private readonly TwilioAPIHandler _twilioAPIHandler;
        private readonly FileHandler _fileHandler;

        public AppController(ILogger<AppController> logger, UnitOfWork unitOfWork, DoorbellAPIHandler doorbellAPIHandler, TwilioAPIHandler twilioAPIHandler, FileHandler fileHandler)
        {
            _logger = logger;
            _unitOfWork = unitOfWork;
            _doorbellAPIHandler = doorbellAPIHandler;
            _twilioAPIHandler = twilioAPIHandler;
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
        [HttpGet("GetAccessToDoorbellVideoCallRoom")]
        public async Task<IActionResult> GetAccessToDoorbellVideoCallRoom([FromQuery] string doorbellDisplayName, [FromQuery] string appDeviceUUID)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();
            if (doorbell == null)
            {
                return BadRequest("Doorbell Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            AppConnection? connectingApp = _unitOfWork.AppConnectionRepo.Get(a => a.UUID == appDeviceUUID && !a.IsBanned).FirstOrDefault();
            if (connectingApp == null)
            {
                return Unauthorized("App Device Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            try
            {
                var connectionData = await HandleVideoCallConnection(doorbell, connectingApp);

                if (connectionData == null)
                {
                    return StatusCode(530); // The connection with the doorbell failed
                }
                return new JsonResult(connectionData);
            } catch (InvalidOperationException _) // Twilio problems or doorbell state is not correct for this operation
            {
                return StatusCode(500);
            }

            
        }

        [HttpGet("GetUsersInDoorbellsVideoChatRoom")]
        public IActionResult GetUsersInDoorbellsVideoChatRoom([FromQuery] string doorbellDisplayName, [FromQuery] string appDeviceUUID)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();
            if (doorbell == null)
            {
                return BadRequest("Doorbell Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            AppConnection? connectingApp = _unitOfWork.AppConnectionRepo.Get(a => a.UUID == appDeviceUUID && !a.IsBanned).FirstOrDefault();
            if (connectingApp == null)
            {
                return Unauthorized("App Device Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            // Checks if the most recent status was of the doorbell being in a call.
            if (_unitOfWork.DoorbellStatusRepo.Get(s => s.DoorbellConnectionId == doorbell.Id).OrderByDescending(s => s.Created).FirstOrDefault().State == DoorbellState.InCall)
            {
                var currentVideoChat = _unitOfWork.VideoChatRepo.Get(v => v.DoorbellConnectionId == doorbell.Id).OrderByDescending(v => v.Created).FirstOrDefault();
                var appConnectionsForVideoChat = _unitOfWork.AppConnectionToVideoChatRepo.Get(atv => atv.VideoChatId == currentVideoChat.Id);

                List<string> displayNamesOfConnectedAppUsers = new();
                foreach (var appUser in appConnectionsForVideoChat)
                {
                    var appConnectionInformation = _unitOfWork.AppConnectionRepo.GetByID(appUser.AppConnectionId);

                    displayNamesOfConnectedAppUsers.Add(appConnectionInformation.DisplayName);
                }

                return Ok(displayNamesOfConnectedAppUsers);
            }

            return StatusCode(409); // Not in a call.
        }

        private async Task<DoorbellUpdateData> GetDoorbellUpdateData(DoorbellConnection doorbell)
        {
            DoorbellStatus? mostRecentStatus = _unitOfWork.DoorbellStatusRepo.Get(s => s.DoorbellConnectionId == doorbell.Id).OrderByDescending(s => s.Created).FirstOrDefault();

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

            DateTime lastLoginTimeWithUtcKind = DateTime.SpecifyKind(doorbell.LastLoginTime, DateTimeKind.Utc);
            DateTime previousActivationTimeWithUtcKind = DateTime.SpecifyKind(doorbell.PreviousActivationTime, DateTimeKind.Utc);

            DoorbellUpdateData updateData = new DoorbellUpdateData()
            { 
                DisplayName = doorbell.DisplayName,
                DoorbellStatus = state,
                LastTurnedOn = (new DateTimeOffset(lastLoginTimeWithUtcKind)).ToUnixTimeSeconds(),
                LastActivationUnix = (new DateTimeOffset(previousActivationTimeWithUtcKind)).ToUnixTimeSeconds(),
            };

            return updateData;
        }

        // Holds the business logic for connecting an app user to a video call. 
        // Assumes doorbell has been null checked.
        // Helps to seperate the logic from the original method to keep the methods short.
        private async Task<Dictionary<String, dynamic>?> HandleVideoCallConnection(DoorbellConnection doorbell, AppConnection connectingApp) 
        {
            DoorbellState currentDoorbellState = _unitOfWork.DoorbellStatusRepo.Get().OrderByDescending(s => s.Created).FirstOrDefault().State;
            if (currentDoorbellState != DoorbellState.ButtonRecentlyActivated && currentDoorbellState != DoorbellState.InCall)
            {
                throw new InvalidOperationException("The doorbell is not waiting for or in a call");
            }

            string twilioAccessToken = _twilioAPIHandler.GetTwilioJwt(connectingApp.DisplayName);
            

            if (currentDoorbellState == DoorbellState.ButtonRecentlyActivated) // Doorbell needs notified and a room generated with the appropriate rules.
            {
                RoomResource room = await _twilioAPIHandler.CreateRoomAsync();

                VideoChat newVideoChat = new()
                {
                    DoorbellConnectionId = doorbell.Id,
                    HasAnyoneAppUserAnswered = true,
                    AssignedUniqueRoomName = room.UniqueName,
                };

                _unitOfWork.VideoChatRepo.Insert(newVideoChat);

                var connectionDataApp = FormatRoomConnectionData(twilioAccessToken, room.UniqueName); // App connection data
                var connectionDataDoorbell = FormatRoomConnectionData(_twilioAPIHandler.GetTwilioJwt(doorbell.DisplayName), room.UniqueName); // Doorbell connection data

                if (await _doorbellAPIHandler.NotifyDoorbellOfCall(doorbell, connectionDataDoorbell))
                {
                    _unitOfWork.DoorbellStatusRepo.Insert(new DoorbellStatus
                    {
                        DoorbellConnectionId = doorbell.Id,
                        State = DoorbellState.InCall
                    });

                    _unitOfWork.AppConnectionToVideoChatRepo.Insert(new AppConnectionToVideoChat
                    {
                        AppConnectionId = connectingApp.Id,
                        VideoChatId = newVideoChat.Id
                    });

                    return connectionDataApp;
                }

                return null;
            } 
            
            
            VideoChat videoChat = _unitOfWork.VideoChatRepo.Get(vc => vc.DoorbellConnectionId == doorbell.Id).OrderByDescending(s => s.Created).FirstOrDefault();
            var connectionData = FormatRoomConnectionData(twilioAccessToken, videoChat.AssignedUniqueRoomName); // App connection data

            _unitOfWork.AppConnectionToVideoChatRepo.Insert(new AppConnectionToVideoChat
            {
                AppConnectionId = connectingApp.Id,
                VideoChatId = videoChat.Id
            });

            return connectionData;
        }

        // Combines the data for connecting to a room into a JSON capable dictionary and returns it.
        private Dictionary<String, dynamic> FormatRoomConnectionData(string twilioToken, string roomName)
        {
            Dictionary<string, dynamic> connectionData = new();

            connectionData["Token"] = twilioToken;
            connectionData["RoomName"] = roomName;

            return connectionData;
        }
    }
}